// Shared mood data — used by both HomeScreen and AddEntryScreen.
// Extracted here so both screens reference the same source of truth.
// Future: move to domain/entities when architecture layers are added.

import 'package:flutter/material.dart';

class MoodOption {
  final String emoji;
  final String label;
  final Color color;
  final Color lightColor;

  const MoodOption({
    required this.emoji,
    required this.label,
    required this.color,
    required this.lightColor,
  });
}

const List<MoodOption> kMoodOptions = [
  MoodOption(
    emoji: '😢',
    label: 'Rough',
    color: Color(0xFF5B8DEF),
    lightColor: Color(0xFFEAF0FD),
  ),
  MoodOption(
    emoji: '😟',
    label: 'Low',
    color: Color(0xFF9B6FDB),
    lightColor: Color(0xFFF2ECFB),
  ),
  MoodOption(
    emoji: '😐',
    label: 'Okay',
    color: Color(0xFF7A8FA6),
    lightColor: Color(0xFFEDF1F5),
  ),
  MoodOption(
    emoji: '😊',
    label: 'Good',
    color: Color(0xFF4CAF82),
    lightColor: Color(0xFFE8F7F0),
  ),
  MoodOption(
    emoji: '😄',
    label: 'Great',
    color: Color(0xFFFFB830),
    lightColor: Color(0xFFFFF6E0),
  ),
];
