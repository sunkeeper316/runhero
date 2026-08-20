import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart'
    show Colors, FontWeight, TextPainter, TextSpan, TextStyle, TextDirection;
import 'package:runhero/game/application/run_hero_state.dart';
import 'package:runhero/game/domain/models/monster_type.dart';

class BattleSceneRenderer {
  BattleSceneRenderer(this.state);

  static const double heroStartX = 58;
  static const double monsterRightPadding = 60;

  final RunHeroState state;
  Image? heroImage;
  final List<Image> heroWalkFrames = [];
  final Map<MonsterType, Image> monsterImages = {};
  final List<Image> goblinAttackFrames = [];

  void render({
    required Canvas canvas,
    required Vector2 size,
    required double heroX,
    required double hitFlashTime,
    required int heroWalkFrame,
    required double monsterHitTime,
    required double monsterAttackTime,
    required double monsterDefeatTime,
  }) {
    final w = size.x;
    final h = size.y;
    if (w <= 0 || h <= 0) return;
    final groundY = h * .76;
    final paint = Paint();

    paint.color = const Color(0xff223859);
    canvas.drawCircle(Offset(w * .17, h * .18), 35, paint);
    canvas.drawCircle(Offset(w * .72, h * .14), 55, paint);
    paint.color = const Color(0xff293c35);
    canvas.drawRect(Rect.fromLTWH(0, groundY, w, h - groundY), paint);
    paint.color = const Color(0xff496451);
    canvas.drawRect(Rect.fromLTWH(0, groundY, w, 5), paint);

    _drawTopHud(canvas, w);
    final hero = heroImage;
    final hasWalkFrames = heroWalkFrames.length == 4;
    final monster = monsterImages[state.currentMonster];
    if ((hero == null && !hasWalkFrames) || monster == null) {
      _drawFallbackCharacter(canvas, Offset(heroX, groundY - 24), isHero: true);
      _drawFallbackCharacter(
        canvas,
        Offset(w - monsterRightPadding, groundY - 27),
        isHero: false,
      );
    } else {
      if (hasWalkFrames) {
        _drawWalkFrame(
          canvas,
          heroWalkFrames[heroWalkFrame],
          bottomCenter: Offset(heroX, groundY),
        );
      } else {
        _drawSprite(
          canvas,
          hero!,
          bottomCenter: Offset(heroX, groundY),
          maxSize: const Size(82, 112),
          faceLeft: false,
        );
      }
      final monsterX = w - monsterRightPadding;
      final monsterIsVisible = state.monsterHp > 0 || monsterDefeatTime > 0;
      if (monsterIsVisible) {
        final shakeX = monsterHitTime > 0
            ? math.sin(monsterHitTime * 95) * 4
            : 0.0;
        canvas.save();
        canvas.translate(shakeX, 0);
        if (state.monsterHp <= 0) {
          final defeatProgress = 1 - (monsterDefeatTime / .42).clamp(0, 1);
          canvas.translate(monsterX, groundY);
          canvas.rotate(-defeatProgress * 1.35);
          canvas.translate(-monsterX, -groundY);
        }
        if (state.currentMonster == MonsterType.goblin &&
            monsterAttackTime > 0 &&
            goblinAttackFrames.length == 4) {
          final elapsed = .64 - monsterAttackTime;
          final frame = (elapsed / .16).floor().clamp(0, 3);
          _drawSprite(
            canvas,
            goblinAttackFrames[frame],
            bottomCenter: Offset(monsterX, groundY),
            maxSize: const Size(94, 122),
            faceLeft: true,
            groundInset: 16,
          );
        } else {
          _drawSprite(
            canvas,
            monster,
            bottomCenter: Offset(monsterX, groundY),
            maxSize: const Size(94, 122),
            faceLeft: true,
            groundInset: 5,
          );
        }
        canvas.restore();
      }
    }
    _drawHealthBar(
      canvas,
      const Offset(18, 63),
      w * .36,
      state.heroHp / state.heroMaxHp,
      const Color(0xff4ee18b),
    );
    _drawHealthBar(
      canvas,
      Offset(w - 18 - w * .36, 63),
      w * .36,
      state.monsterHp / state.monsterMaxHp,
      const Color(0xffff5d68),
    );

    if (hitFlashTime > 0) {
      paint.color = Colors.white.withValues(alpha: hitFlashTime * 1.8);
      canvas.drawRect(Offset.zero & Size(w, h), paint);
    }
  }

  void _drawTopHud(Canvas canvas, double width) {
    _text(
      canvas,
      '勇者 Lv.${state.level}',
      const Offset(18, 14),
      16,
      Colors.white,
      FontWeight.bold,
    );
    _text(
      canvas,
      '第 ${state.floor} 層',
      Offset(width / 2 - 30, 13),
      18,
      const Color(0xffffcf5a),
      FontWeight.w900,
    );
    _text(
      canvas,
      state.currentMonster.label,
      Offset(width - 130, 14),
      16,
      Colors.white,
      FontWeight.bold,
    );
    _text(
      canvas,
      state.message,
      Offset(width / 2, 96),
      14,
      Colors.white70,
      FontWeight.w600,
      center: true,
    );
  }

  void _drawSprite(
    Canvas canvas,
    Image image, {
    required Offset bottomCenter,
    required Size maxSize,
    required bool faceLeft,
    double groundInset = 0,
  }) {
    final source = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final scale = math.min(
      maxSize.width / image.width,
      maxSize.height / image.height,
    );
    final size = Size(image.width * scale, image.height * scale);
    final groundedCenter = bottomCenter.translate(0, groundInset);
    final destination = Rect.fromCenter(
      center: groundedCenter.translate(0, -size.height / 2),
      width: size.width,
      height: size.height,
    );
    final paint = Paint()
      ..isAntiAlias = false
      ..filterQuality = FilterQuality.none;

    canvas.save();
    if (faceLeft) {
      canvas.translate(groundedCenter.dx * 2, 0);
      canvas.scale(-1, 1);
    }
    canvas.drawImageRect(image, source, destination, paint);
    canvas.restore();
  }

  void _drawWalkFrame(
    Canvas canvas,
    Image frame, {
    required Offset bottomCenter,
  }) {
    const maxSize = Size(84, 112);
    final source = Rect.fromLTWH(
      0,
      0,
      frame.width.toDouble(),
      frame.height.toDouble(),
    );
    final scale = math.min(
      maxSize.width / frame.width,
      maxSize.height / frame.height,
    );
    final size = Size(frame.width * scale, frame.height * scale);
    final destination = Rect.fromCenter(
      center: bottomCenter.translate(0, -size.height / 2),
      width: size.width,
      height: size.height,
    );
    canvas.drawImageRect(
      frame,
      source,
      destination,
      Paint()
        ..isAntiAlias = false
        ..filterQuality = FilterQuality.none,
    );
  }

  void _drawFallbackCharacter(
    Canvas canvas,
    Offset position, {
    required bool isHero,
  }) {
    final paint = Paint()
      ..color = isHero ? const Color(0xff4c9dff) : const Color(0xffde4d62);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: position, width: 36, height: 48),
        const Radius.circular(9),
      ),
      paint,
    );
    paint.color = isHero ? const Color(0xffffd3a1) : const Color(0xffb5e56d);
    canvas.drawCircle(position.translate(0, -29), 15, paint);
    paint.color = const Color(0xff152033);
    canvas.drawCircle(position.translate(isHero ? 5 : -5, -31), 2.5, paint);
    paint.color = isHero ? const Color(0xffe5edf8) : const Color(0xff7b2635);
    canvas.drawRect(
      Rect.fromCenter(
        center: position.translate(isHero ? 23 : -23, 0),
        width: 9,
        height: 38,
      ),
      paint,
    );
    paint.color = const Color(0xff111722);
    canvas.drawRect(
      Rect.fromLTWH(position.dx - 16, position.dy + 22, 12, 10),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(position.dx + 4, position.dy + 22, 12, 10),
      paint,
    );
  }

  void _drawHealthBar(
    Canvas canvas,
    Offset position,
    double width,
    double ratio,
    Color color,
  ) {
    final paint = Paint()..color = const Color(0xff080b10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(position.dx, position.dy, width, 13),
        const Radius.circular(6),
      ),
      paint,
    );
    paint.color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          position.dx + 2,
          position.dy + 2,
          (width - 4) * ratio.clamp(0, 1),
          9,
        ),
        const Radius.circular(5),
      ),
      paint,
    );
  }

  void _text(
    Canvas canvas,
    String value,
    Offset position,
    double size,
    Color color,
    FontWeight weight, {
    bool center = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(fontSize: size, color: color, fontWeight: weight),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center ? position.translate(-painter.width / 2, 0) : position,
    );
  }
}
