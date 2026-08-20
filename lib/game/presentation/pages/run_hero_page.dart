import 'dart:async';

import 'package:flutter/material.dart';
import 'package:runhero/game/application/run_hero_state.dart';
import 'package:runhero/game/flame/run_hero_game.dart';
import 'package:runhero/game/infrastructure/game_progress_store.dart';
import 'package:runhero/game/presentation/widgets/tower_battle_view.dart';
import 'package:runhero/game/presentation/widgets/upgrade_panel.dart';

class RunHeroPage extends StatefulWidget {
  const RunHeroPage({super.key});

  @override
  State<RunHeroPage> createState() => _RunHeroPageState();
}

class _RunHeroPageState extends State<RunHeroPage> with WidgetsBindingObserver {
  final GameProgressStore _progressStore = GameProgressStore();
  RunHeroState? state;
  RunHeroGame? game;
  Timer? _saveTimer;
  int _seenLootSerial = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProgress();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveTimer?.cancel();
    final currentState = state;
    if (currentState != null) {
      unawaited(_progressStore.save(currentState.toProgressJson()));
      currentState.removeListener(_onStateChanged);
      currentState.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final progress = await _progressStore.load();
    if (!mounted) return;

    final loadedState = RunHeroState();
    if (progress != null) loadedState.restoreProgress(progress);
    loadedState.addListener(_onStateChanged);
    setState(() {
      state = loadedState;
      game = RunHeroGame(loadedState);
    });
  }

  void _onStateChanged() {
    _showLootIfNeeded();
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 250), _saveProgress);
  }

  void _saveProgress() {
    final currentState = state;
    if (currentState == null) return;
    unawaited(_progressStore.save(currentState.toProgressJson()));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.inactive ||
        lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.detached) {
      _saveTimer?.cancel();
      _saveProgress();
    }
  }

  void _showLootIfNeeded() {
    final currentState = state;
    if (currentState == null ||
        _seenLootSerial == currentState.lootSerial ||
        currentState.lastLootSlot == null) {
      return;
    }
    _seenLootSerial = currentState.lootSerial;
    final slot = currentState.lastLootSlot!;
    final gearLevel = currentState.gear[slot]!;
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
    final currentState = state;
    final currentGame = game;
    if (currentState == null || currentGame == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TowerBattleView(state: currentState, game: currentGame),
            ),
            Expanded(child: UpgradePanel(state: currentState)),
          ],
        ),
      ),
    );
  }
}
