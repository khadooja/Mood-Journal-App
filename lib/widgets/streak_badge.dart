import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StreakBadge extends StatelessWidget {
  final int streak;

  const StreakBadge({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    if (streak == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB830).withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '$streak ${streak == 1 ? 'day' : 'days'}',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFB8860B),
            ),
          ),
        ],
      ),
    );
  }
}