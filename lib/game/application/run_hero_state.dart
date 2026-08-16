import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:runhero/game/domain/models/battle_outcome.dart';
import 'package:runhero/game/domain/models/gear_slot.dart';
import 'package:runhero/game/domain/models/monster_type.dart';
import 'package:runhero/game/domain/models/upgrade_type.dart';

class RunHeroState extends ChangeNotifier {
  RunHeroState({math.Random? random}) : _random = random ?? math.Random() {
    monsterHp = monsterMaxHp;
  }

  final math.Random _random;

  int floor = 1;
  int highestFloor = 1;
  int coins = 0;
  int experience = 0;
  int level = 1;
  int statPoints = 0;
  int chestsOpened = 0;
  int lootSerial = 0;
  GearSlot? lastLootSlot;
  int attackLevel = 1;
  int defenseLevel = 1;
  int healthLevel = 1;
  double heroHp = 140;
  double monsterHp = 0;
  String message = '英雄出發！';
  int messageSerial = 0;
  final Map<GearSlot, int> gear = {for (final slot in GearSlot.values) slot: 0};

  double get heroMaxHp =>
      120 +
      healthLevel * 20 +
      gear[GearSlot.armor]! * 12 +
      gear[GearSlot.ring]! * 18;
  double get heroAttack => 22 + attackLevel * 8 + gear[GearSlot.weapon]! * 12;
  double get heroDefense =>
      4 +
      defenseLevel * 4 +
      gear[GearSlot.helmet]! * 4 +
      gear[GearSlot.armor]! * 6 +
      gear[GearSlot.shoes]! * 2;
  double get monsterMaxHp => 70 + floor * 35 + math.pow(floor, 1.25) * 8;
  double get monsterAttack => 14 + floor * 5 + math.pow(floor, 1.15) * 2;
  double get monsterDefense => 3 + floor * 2.5;
  int get experienceToNextLevel => 60 + (level - 1) * 30;
  MonsterType get currentMonster =>
      MonsterType.values[(floor - 1) % MonsterType.values.length];
  int gearUpgradeCost(GearSlot slot) => 60 + gear[slot]! * 45;

  double damage(double attack, double defense) => math.max(1, attack - defense);

  BattleOutcome resolveBattle() {
    final dealt = damage(heroAttack, monsterDefense);
    final received = damage(monsterAttack, heroDefense);
    monsterHp = math.max(0, monsterHp - dealt);
    heroHp = math.max(0, heroHp - received);

    if (monsterHp <= 0) {
      final reward = 18 + floor * 7;
      coins += reward;
      final levelsGained = _gainExperience(25 + floor * 5);
      final droppedGear = _random.nextDouble() < .3 ? _equipRandomGear() : null;
      _say(
        '第 $floor 關通過！+$reward 金幣'
        '${levelsGained > 0 ? '、升級！能力點 +$levelsGained' : ''}'
        '${droppedGear != null ? '、寶箱：${droppedGear.label}自動裝備' : ''}',
      );
      notifyListeners();
      return BattleOutcome.victory;
    }

    if (heroHp <= 0) {
      floor = 1;
      monsterHp = monsterMaxHp;
      heroHp = heroMaxHp;
      _say('英雄倒下，從第 1 層重新挑戰！');
      notifyListeners();
      return BattleOutcome.defeat;
    }

    _say('造成 ${dealt.round()} 傷害，受到 ${received.round()} 傷害');
    notifyListeners();
    return BattleOutcome.exchange;
  }

  /// 怪物死亡動畫播完後才建立下一層，避免新怪物瞬間取代舊怪物。
  void advanceFloor() {
    if (monsterHp > 0) return;
    floor++;
    highestFloor = math.max(highestFloor, floor);
    monsterHp = monsterMaxHp;
    _say('進入第 $floor 層');
    notifyListeners();
  }

  bool upgrade(UpgradeType type) {
    if (statPoints <= 0) return false;
    statPoints--;
    switch (type) {
      case UpgradeType.attack:
        attackLevel++;
      case UpgradeType.defense:
        defenseLevel++;
      case UpgradeType.health:
        final oldMax = heroMaxHp;
        healthLevel++;
        heroHp += heroMaxHp - oldMax;
    }
    _say('能力提升！');
    notifyListeners();
    return true;
  }

  int _gainExperience(int amount) {
    experience += amount;
    var gained = 0;
    while (experience >= experienceToNextLevel) {
      experience -= experienceToNextLevel;
      level++;
      statPoints++;
      gained++;
    }
    return gained;
  }

  GearSlot _equipRandomGear() {
    chestsOpened++;
    final slot = GearSlot.values[_random.nextInt(GearSlot.values.length)];
    final oldMax = heroMaxHp;
    gear[slot] = gear[slot]! + 1;
    heroHp += heroMaxHp - oldMax;
    lastLootSlot = slot;
    lootSerial++;
    return slot;
  }

  bool upgradeGear(GearSlot slot) {
    final cost = gearUpgradeCost(slot);
    if (coins < cost || gear[slot] == 0) return false;
    coins -= cost;
    final oldMax = heroMaxHp;
    gear[slot] = gear[slot]! + 1;
    heroHp += heroMaxHp - oldMax;
    _say('${slot.label}強化至 +${gear[slot]}：${slot.effectLabel(gear[slot]!)}');
    notifyListeners();
    return true;
  }

  void _say(String value) {
    message = value;
    messageSerial++;
  }
}
