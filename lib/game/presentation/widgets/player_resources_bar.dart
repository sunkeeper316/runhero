import 'package:flutter/material.dart';
import 'package:runhero/game/application/run_hero_state.dart';

class PlayerResourcesBar extends StatelessWidget {
  const PlayerResourcesBar({super.key, required this.state});

  final RunHeroState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 5),
      child: Row(
        children: [
          const Icon(
            Icons.monetization_on_rounded,
            color: Color(0xffffca4f),
            size: 20,
          ),
          Text(
            ' ${state.coins}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.auto_awesome, color: Color(0xff9fd8ff), size: 19),
          Text(
            ' Lv.${state.level}  ${state.experience}/${state.experienceToNextLevel} EXP',
          ),
          const Spacer(),
          Chip(
            avatar: const Icon(
              Icons.add_circle_rounded,
              size: 17,
              color: Color(0xffffd064),
            ),
            label: Text('能力點 ${state.statPoints}'),
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: '已自動開啟並裝備的寶箱',
            child: Row(
              children: [
                const Icon(Icons.inventory_2_rounded, size: 17),
                Text(' ${state.chestsOpened}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
