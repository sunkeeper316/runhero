import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:runhero/game/application/run_hero_state.dart';
import 'package:runhero/game/domain/models/battle_outcome.dart';
import 'package:runhero/game/domain/models/monster_type.dart';
import 'package:runhero/game/flame/renderers/battle_scene_renderer.dart';

class RunHeroGame extends FlameGame {
  RunHeroGame(this.state) : _renderer = BattleSceneRenderer(state);

  final RunHeroState state;
  final BattleSceneRenderer _renderer;

  double heroX = 0;
  double knockbackTime = 0;
  double pauseTime = .5;
  double hitFlashTime = 0;
  double walkAnimationTime = 0;
  double monsterHitTime = 0;
  double monsterDefeatTime = 0;
  double victoryDelayTime = 0;
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
    for (final monster in MonsterType.values) {
      _renderer.monsterImages[monster] = await images.load(
        'characters/${monster.assetName}',
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
    monsterDefeatTime = math.max(0, monsterDefeatTime - dt);
    if (_seenMessage != state.messageSerial) {
      _seenMessage = state.messageSerial;
      hitFlashTime = .18;
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
    heroX += 85 * dt;
    if (heroX + 27 < monsterX - 28) return;

    final outcome = state.resolveBattle();
    monsterHitTime = .18;
    knockbackTime = .42;
    if (outcome == BattleOutcome.victory) {
      monsterDefeatTime = .42;
      victoryDelayTime = 1.05;
      knockbackTime = 0;
    } else if (outcome == BattleOutcome.defeat) {
      heroX = BattleSceneRenderer.heroStartX;
      knockbackTime = 0;
      pauseTime = .8;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _renderer.render(
      canvas: canvas,
      size: size,
      heroX: heroX,
      hitFlashTime: hitFlashTime,
      heroWalkFrame: (walkAnimationTime / .16).floor() % 4,
      monsterHitTime: monsterHitTime,
      monsterDefeatTime: monsterDefeatTime,
    );
  }
}
