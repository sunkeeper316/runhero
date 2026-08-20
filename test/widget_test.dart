import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:runhero/main.dart';
import 'package:runhero/game/domain/models/gear_slot.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the battle and upgrade interface', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const RunHeroApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('能力點 0'), findsOneWidget);
    expect(find.text('傷害 30'), findsOneWidget);
    expect(find.text('防禦 8'), findsOneWidget);
    expect(find.text('生命 140/140'), findsOneWidget);
    expect(find.text('自動裝備（怪物寶箱隨機掉落）'), findsOneWidget);
  });

  test('damage never falls below one', () {
    final state = RunHeroState();
    expect(state.damage(10, 100), 1);
    expect(state.damage(100, 20), 80);
    state.dispose();
  });

  test('death returns the hero to floor one', () {
    final state = RunHeroState()
      ..floor = 8
      ..highestFloor = 8
      ..heroHp = 1
      ..monsterHp = 9999;

    state.resolveBattle();

    expect(state.floor, 1);
    expect(state.highestFloor, 8);
    expect(state.heroHp, state.heroMaxHp);
    expect(state.monsterHp, state.monsterMaxHp);
    state.dispose();
  });

  test('monster type rotates by floor', () {
    final state = RunHeroState();
    expect(state.currentMonster.label, '哥布林');
    state.floor = 2;
    expect(state.currentMonster.label, '史萊姆');
    state.floor = 3;
    expect(state.currentMonster.label, '獸人');
    state.floor = 6;
    expect(state.currentMonster.label, '哥布林');
    state.dispose();
  });

  test('next floor is created after the victory animation', () {
    final state = RunHeroState()..monsterHp = 1;

    state.resolveBattle();
    expect(state.floor, 1);
    expect(state.monsterHp, 0);

    state.advanceFloor();
    expect(state.floor, 2);
    expect(state.highestFloor, 2);
    expect(state.monsterHp, state.monsterMaxHp);
    state.dispose();
  });

  test('experience grants a stat point on level up', () {
    final state = RunHeroState()
      ..experience = 59
      ..monsterHp = 1;

    state.resolveBattle();

    expect(state.level, 2);
    expect(state.statPoints, 1);
    expect(state.experience, 29);
    state.dispose();
  });

  test('a dropped chest automatically equips random gear', () {
    final state = RunHeroState(random: _AlwaysDropRandom())..monsterHp = 1;

    state.resolveBattle();

    expect(state.chestsOpened, 1);
    expect(state.gear[GearSlot.weapon], 1);
    state.dispose();
  });

  test('coins upgrade owned gear and increase its stat', () {
    final state = RunHeroState(random: _AlwaysDropRandom())..monsterHp = 1;
    state.resolveBattle();
    state.coins = 200;
    final attackBeforeUpgrade = state.heroAttack;

    expect(state.upgradeGear(GearSlot.weapon), isTrue);

    expect(state.gear[GearSlot.weapon], 2);
    expect(state.heroAttack, attackBeforeUpgrade + 12);
    expect(state.coins, 95);
    state.dispose();
  });

  test('game progress restores permanent upgrades and resets the battle', () {
    final original = RunHeroState()
      ..floor = 4
      ..highestFloor = 7
      ..coins = 321
      ..experience = 22
      ..level = 3
      ..statPoints = 2
      ..attackLevel = 4
      ..defenseLevel = 3
      ..healthLevel = 2
      ..gear[GearSlot.weapon] = 5;
    final restored = RunHeroState()..restoreProgress(original.toProgressJson());

    expect(restored.floor, 4);
    expect(restored.highestFloor, 7);
    expect(restored.coins, 321);
    expect(restored.level, 3);
    expect(restored.attackLevel, 4);
    expect(restored.gear[GearSlot.weapon], 5);
    expect(restored.heroHp, restored.heroMaxHp);
    expect(restored.monsterHp, restored.monsterMaxHp);
    original.dispose();
    restored.dispose();
  });
}

class _AlwaysDropRandom implements Random {
  @override
  bool nextBool() => true;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => 0;
}
