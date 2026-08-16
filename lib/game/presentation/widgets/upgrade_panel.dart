import 'package:flutter/material.dart';
import 'package:runhero/game/application/run_hero_state.dart';
import 'package:runhero/game/domain/models/gear_slot.dart';
import 'package:runhero/game/domain/models/upgrade_type.dart';
import 'package:runhero/game/presentation/widgets/gear_upgrade_card.dart';
import 'package:runhero/game/presentation/widgets/player_resources_bar.dart';
import 'package:runhero/game/presentation/widgets/stat_upgrade_card.dart';

class UpgradePanel extends StatelessWidget {
  const UpgradePanel({super.key, required this.state});

  final RunHeroState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => Container(
        decoration: const BoxDecoration(
          color: Color(0xff111724),
          border: Border(top: BorderSide(color: Color(0xff374257), width: 2)),
        ),
        child: Column(
          children: [
            PlayerResourcesBar(state: state),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _statCard(
                    context,
                    title: '傷害',
                    value: '${state.heroAttack.round()}',
                    icon: Icons.flash_on_rounded,
                    type: UpgradeType.attack,
                  ),
                  _statCard(
                    context,
                    title: '防禦',
                    value: '${state.heroDefense.round()}',
                    icon: Icons.shield_rounded,
                    type: UpgradeType.defense,
                  ),
                  _statCard(
                    context,
                    title: '生命',
                    value: '${state.heroHp.round()}/${state.heroMaxHp.round()}',
                    icon: Icons.favorite_rounded,
                    type: UpgradeType.health,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 8, 14, 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '自動裝備（怪物寶箱隨機掉落）',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 9),
                children: GearSlot.values.map((slot) {
                  return GearUpgradeCard(
                    slot: slot,
                    level: state.gear[slot]!,
                    cost: state.gearUpgradeCost(slot),
                    onTap: () => _upgradeGear(context, slot),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required UpgradeType type,
  }) {
    return StatUpgradeCard(
      title: title,
      value: value,
      icon: icon,
      hasPoint: state.statPoints > 0,
      onTap: () => _tryAction(context, () => state.upgrade(type)),
    );
  }

  void _tryAction(BuildContext context, bool Function() action) {
    if (action()) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('升級後才能獲得能力點！'),
          duration: Duration(milliseconds: 800),
        ),
      );
  }

  void _upgradeGear(BuildContext context, GearSlot slot) {
    if (state.upgradeGear(slot)) return;
    final message = state.gear[slot] == 0 ? '要先從寶箱取得這件裝備！' : '金幣不足！';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 800),
        ),
      );
  }
}
