import 'package:flutter/material.dart';

class StatUpgradeCard extends StatelessWidget {
  const StatUpgradeCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.hasPoint,
    required this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool hasPoint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Column(
              children: [
                Icon(icon, size: 22, color: const Color(0xffffb84d)),
                Text(
                  '$title $value',
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  hasPoint ? '使用 1 能力點' : '需要能力點',
                  style: TextStyle(
                    fontSize: 10,
                    color: hasPoint ? const Color(0xffffd36b) : Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
