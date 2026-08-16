import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:runhero/game/application/run_hero_state.dart';
import 'package:runhero/game/domain/models/monster_type.dart';
import 'package:runhero/game/flame/run_hero_game.dart';

/// 全畫面垂直塔樓：每次過關才加入下一層。
class TowerBattleView extends StatefulWidget {
  const TowerBattleView({super.key, required this.state, required this.game});

  final RunHeroState state;
  final RunHeroGame game;

  @override
  State<TowerBattleView> createState() => _TowerBattleViewState();
}

class _TowerBattleViewState extends State<TowerBattleView> {
  final ScrollController _controller = ScrollController();
  final GlobalKey _gameKey = GlobalKey();
  int _lastFloor = 1;
  double _floorHeight = 0;

  @override
  void initState() {
    super.initState();
    _lastFloor = widget.state.floor;
    widget.state.addListener(_onGameChanged);
  }

  @override
  void dispose() {
    widget.state.removeListener(_onGameChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onGameChanged() {
    if (_lastFloor == widget.state.floor) return;
    _lastFloor = widget.state.floor;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients || _floorHeight <= 0) return;
      final target = (_lastFloor - 1) * _floorHeight;
      _controller.animateTo(
        target.clamp(0, _controller.position.maxScrollExtent),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _floorHeight = constraints.maxHeight;
        return AnimatedBuilder(
          animation: widget.state,
          builder: (context, _) => ListView.builder(
            controller: _controller,
            reverse: true,
            physics: const BouncingScrollPhysics(),
            itemExtent: _floorHeight,
            itemCount: widget.state.highestFloor,
            itemBuilder: (context, index) {
              final floor = index + 1;
              if (floor == widget.state.floor) {
                return _ActiveFloor(
                  floor: floor,
                  gameWidget: GameWidget(key: _gameKey, game: widget.game),
                );
              }
              return _FloorRecord(
                floor: floor,
                isCleared: floor < widget.state.floor,
              );
            },
          ),
        );
      },
    );
  }
}

class _ActiveFloor extends StatelessWidget {
  const _ActiveFloor({required this.floor, required this.gameWidget});

  final int floor;
  final Widget gameWidget;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: gameWidget),
        Positioned(
          left: 0,
          right: 0,
          bottom: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 15,
                color: Colors.white54,
              ),
              Text(
                ' 上下滑動查看塔樓 · 第 $floor 層 ',
                style: const TextStyle(fontSize: 10, color: Colors.white54),
              ),
              const Icon(
                Icons.keyboard_arrow_up_rounded,
                size: 15,
                color: Colors.white54,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FloorRecord extends StatelessWidget {
  const _FloorRecord({required this.floor, required this.isCleared});

  final int floor;
  final bool isCleared;

  @override
  Widget build(BuildContext context) {
    final monster = MonsterType.values[(floor - 1) % MonsterType.values.length];
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff172337), Color(0xff293c35)],
        ),
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xff526477), width: 3),
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _StonePainter())),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 25,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xff293c35),
                border: Border(
                  top: BorderSide(color: Color(0xff496451), width: 5),
                ),
              ),
            ),
          ),
          Positioned(
            top: 13,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xaa111724),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '第 $floor 層',
                  style: const TextStyle(
                    color: Color(0xffffd064),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          if (!isCleared)
            Positioned(
              right: 25,
              bottom: 22,
              width: 115,
              height: 140,
              child: Transform.flip(
                flipX: true,
                child: Image.asset(
                  'assets/images/characters/${monster.assetName}',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StonePainter extends CustomPainter {
  const _StonePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x225f7891)
      ..style = PaintingStyle.stroke;
    const width = 58.0;
    const height = 28.0;
    for (var y = 0.0; y < size.height; y += height) {
      final start = (y / height).round().isEven ? 0.0 : -width / 2;
      for (var x = start; x < size.width; x += width) {
        canvas.drawRect(Rect.fromLTWH(x, y, width, height), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
