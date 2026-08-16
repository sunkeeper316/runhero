import 'package:flutter/material.dart';
import 'package:runhero/game/domain/models/gear_slot.dart';

class GearUpgradeCard extends StatelessWidget {
  const GearUpgradeCard({
    super.key,
    required this.slot,
    required this.level,
    required this.cost,
    required this.onTap,
  });

  final GearSlot slot;
  final int level;
  final int cost;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Card(
        margin: const EdgeInsets.fromLTRB(3, 0, 3, 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_icon, color: const Color(0xff91c9ff), size: 23),
              Text(slot.label, style: const TextStyle(fontSize: 11)),
              Text(
                '+$level',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                slot.effectLabel(level),
                maxLines: 1,
                style: const TextStyle(fontSize: 8, color: Colors.white60),
              ),
              Text(
                level > 0 ? '${cost}G 強化' : '等待寶箱',
                style: TextStyle(
                  fontSize: 9,
                  color: level > 0 ? const Color(0xffffd36b) : Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _icon => switch (slot) {
    GearSlot.weapon => Icons.gavel_rounded,
    GearSlot.helmet => Icons.sports_motorsports_rounded,
    GearSlot.armor => Icons.shield_rounded,
    GearSlot.shoes => Icons.ice_skating_rounded,
    GearSlot.ring => Icons.radio_button_checked_rounded,
  };
}
