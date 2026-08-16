import 'package:flutter/material.dart';
import 'package:runhero/game/application/run_hero_state.dart';
import 'package:runhero/game/flame/run_hero_game.dart';
import 'package:runhero/game/presentation/widgets/tower_battle_view.dart';
import 'package:runhero/game/presentation/widgets/upgrade_panel.dart';

class RunHeroPage extends StatefulWidget {
  const RunHeroPage({super.key});

  @override
  State<RunHeroPage> createState() => _RunHeroPageState();
}

class _RunHeroPageState extends State<RunHeroPage> {
  late final RunHeroState state;
  late final RunHeroGame game;
  int _seenLootSerial = 0;

  @override
  void initState() {
    super.initState();
    state = RunHeroState();
    game = RunHeroGame(state);
    state.addListener(_showLootIfNeeded);
  }

  @override
  void dispose() {
    state.removeListener(_showLootIfNeeded);
    state.dispose();
    super.dispose();
  }

  void _showLootIfNeeded() {
    if (_seenLootSerial == state.lootSerial || state.lastLootSlot == null) {
      return;
    }
    _seenLootSerial = state.lootSerial;
    final slot = state.lastLootSlot!;
    final gearLevel = state.gear[slot]!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(
            Icons.inventory_2_rounded,
            color: Color(0xffffd064),
            size: 42,
          ),
          title: const Text('獲得裝備！', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${slot.label} +$gearLevel',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(slot.effectLabel(gearLevel)),
              const SizedBox(height: 6),
              const Text('已自動放入裝備欄', style: TextStyle(color: Colors.white60)),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('確認'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TowerBattleView(state: state, game: game),
            ),
            Expanded(child: UpgradePanel(state: state)),
          ],
        ),
      ),
    );
  }
}
