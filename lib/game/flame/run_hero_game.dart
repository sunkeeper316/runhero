import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:runhero/game/application/run_hero_state.dart';
import 'package:runhero/game/domain/models/battle_outcome.dart';
import 'package:runhero/game/domain/models/monster_type.dart';
import 'package:runhero/game/flame/renderers/battle_scene_renderer.dart';

class RunHeroGame extends FlameGame {
  RunHeroGame(this.state) : _renderer = BattleSceneRenderer(state);

  static const double _heroRunSpeed = 130;
  static const double _heroRunFrameDuration = .1;
  static const double heroAttackDuration = .6;
  static const double _heroAttackHitTime = .3;

  final RunHeroState state;
  final BattleSceneRenderer _renderer;

  double heroX = 0;
  double knockbackTime = 0;
  double pauseTime = .5;
  double hitFlashTime = 0;
  double walkAnimationTime = 0;
  double heroAttackTime = 0;
  double monsterHitTime = 0;
  double monsterAttackTime = 0;
  double monsterDefeatTime = 0;
  double victoryDelayTime = 0;
  bool _attackDamageApplied = false;
  int _seenMessage = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _renderer.heroImage = await images.load('characters/hero.png');
    for (var frame = 1; frame <= 4; frame++) {
      _renderer.heroWalkFrames.add(
        await images.load('characters/hero_walk/hero_walk_$frame.png'),
      );
    }
    for (var frame = 1; frame <= 4; frame++) {
      _renderer.heroAttackFrames.add(
        await images.load('characters/hero_attack/hero_attack_$frame.png'),
      );
    }
    for (final monster in MonsterType.values) {
      _renderer.monsterImages[monster] = await images.load(
        'characters/${monster.assetName}',
      );
    }
    for (var frame = 1; frame <= 4; frame++) {
      _renderer.goblinAttackFrames.add(
        await images.load('characters/goblin_attack_$frame.png'),
      );
    }
  }

  @override
  Color backgroundColor() => const Color(0xff172337);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    heroX = math.max(heroX, BattleSceneRenderer.heroStartX);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (size.x <= 0) return;
    hitFlashTime = math.max(0, hitFlashTime - dt);
    monsterHitTime = math.max(0, monsterHitTime - dt);
    monsterAttackTime = math.max(0, monsterAttackTime - dt);
    monsterDefeatTime = math.max(0, monsterDefeatTime - dt);
    if (_seenMessage != state.messageSerial) {
      _seenMessage = state.messageSerial;
      hitFlashTime = .18;
    }
    if (heroAttackTime > 0) {
      heroAttackTime = math.max(0, heroAttackTime - dt);
      final attackElapsed = heroAttackDuration - heroAttackTime;
      if (!_attackDamageApplied && attackElapsed >= _heroAttackHitTime) {
        _attackDamageApplied = true;
        final outcome = state.resolveBattle();
        monsterHitTime = .18;
        monsterAttackTime = .64;
        knockbackTime = .42;
        if (outcome == BattleOutcome.victory) {
          monsterDefeatTime = .42;
          victoryDelayTime = .55;
          knockbackTime = 0;
        } else if (outcome == BattleOutcome.defeat) {
          heroAttackTime = 0;
          heroX = BattleSceneRenderer.heroStartX;
          knockbackTime = 0;
          pauseTime = .8;
        }
      }
      return;
    }
    if (victoryDelayTime > 0) {
      victoryDelayTime -= dt;
      if (victoryDelayTime <= 0) {
        state.advanceFloor();
        heroX = BattleSceneRenderer.heroStartX;
        pauseTime = .8;
      }
      return;
    }
    if (pauseTime > 0) {
      pauseTime -= dt;
      return;
    }
    walkAnimationTime += dt;
    if (knockbackTime > 0) {
      heroX -= 155 * dt;
      knockbackTime -= dt;
      if (knockbackTime <= 0) pauseTime = .25;
      return;
    }

    final monsterX = size.x - BattleSceneRenderer.monsterRightPadding;
    heroX += _heroRunSpeed * dt;
    if (heroX + 27 < monsterX - 28) return;

    heroAttackTime = heroAttackDuration;
    _attackDamageApplied = false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _renderer.render(
      canvas: canvas,
      size: size,
      heroX: heroX,
      hitFlashTime: hitFlashTime,
      heroWalkFrame: (walkAnimationTime / _heroRunFrameDuration).floor() % 4,
      heroAttackTime: heroAttackTime,
      monsterHitTime: monsterHitTime,
      monsterAttackTime: monsterAttackTime,
      monsterDefeatTime: monsterDefeatTime,
    );
  }
}
