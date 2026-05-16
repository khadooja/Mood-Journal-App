import 'package:flutter/material.dart';

/// Central color palette for the MindTrack app.
///
/// All UI colors must reference this class — never use hardcoded
/// [Color] literals or [Colors] references outside of this file.
///
/// Organization:
///  - Brand / Primary
///  - Backgrounds & Surfaces
///  - Text
///  - Borders
///  - Status (error, warning)
///  - Mood-specific (used by chart / analytics)
///  - Premium / Wellness additions
abstract final class AppColors {
  // ─────────────────────────────────────────────────────────
  // Brand — Soft lavender purple. The app's identity color.
  // ─────────────────────────────────────────────────────────

  /// Soft purple — primary action color, app logo, FAB, highlights.
  static const Color primary = Color(0xFF7C6FCD);

  /// Slightly darker purple — used for the "days logged" card border, FAB.
  // (Same hue as [primary]; kept as an alias for semantic clarity.)
  static const Color primaryBorder = Color(0xFF7C6FCD);

  /// Deeper purple — used for gradient end points.
  static const Color primaryDeep = Color(0xFF5B4DB0);

  // ─────────────────────────────────────────────────────────
  // Backgrounds & Surfaces
  // ─────────────────────────────────────────────────────────

  /// Main scaffold / screen background — very light lavender.
  static const Color background = Color.fromARGB(255, 255, 255, 255);

  /// Top gradient start — warm blush white.
  static const Color backgroundGradientStart = Color(0xFFF7F5FF);

  /// Top gradient end — near white.
  static const Color backgroundGradientEnd = Color(0xFFFCFBFF);

  /// Pure white — card surfaces, text-field containers, chart background.
  static const Color surface = Colors.white;

  /// Light lavender tint — date badge background, "days logged" card.
  static const Color surfaceVariant = Color(0xFFECEAF8);

  /// Slightly lighter tint — mood-strip placeholder circles.
  static const Color surfaceLight = Color(0xFFF0EEF9);

  /// Glass card background — white with slight opacity.
  static const Color cardGlass = Color(0xFFFAF9FF);

  // ─────────────────────────────────────────────────────────
  // Premium Accent — Daily Prompt card gradient
  // ─────────────────────────────────────────────────────────

  /// Warm rose / blush — prompt card gradient end.
  static const Color accentRose = Color(0xFFFFD6E7);

  /// Soft lavender — prompt card gradient start.
  static const Color accentLavender = Color(0xFFE8E4FF);

  /// Warm peach — secondary accent.
  static const Color accentPeach = Color(0xFFFFEDD8);

  /// Soft mint — positive accent.
  static const Color accentMint = Color(0xFFD4F5E9);

  // ─────────────────────────────────────────────────────────
  // Stat card pastel backgrounds
  // ─────────────────────────────────────────────────────────

  /// Mood Today — soft lavender.
  static const Color statMoodBg = Color(0xFFEDE9FF);

  /// Mood Today — icon color.
  static const Color statMoodIcon = Color(0xFF7C6FCD);

  /// Entries This Week — soft blue.
  static const Color statEntriesBg = Color(0xFFE3EEFF);

  /// Entries icon.
  static const Color statEntriesIcon = Color(0xFF4A80D4);

  /// Current Streak — warm amber.
  static const Color statStreakBg = Color(0xFFFFF4E0);

  /// Streak icon.
  static const Color statStreakIcon = Color(0xFFE8960C);

  /// Longest Streak — soft rose.
  static const Color statLongestBg = Color(0xFFFFE8EF);

  /// Longest streak icon.
  static const Color statLongestIcon = Color(0xFFD4517A);

  // ─────────────────────────────────────────────────────────
  // Navigation
  // ─────────────────────────────────────────────────────────

  /// Floating nav bar background.
  static const Color navBackground = Color(0xFFFBFAFF);

  // ─────────────────────────────────────────────────────────
  // Text
  // ─────────────────────────────────────────────────────────

  /// Dark navy — headings, body text, section labels.
  static const Color textPrimary = Color(0xFF2D2B55);

  /// Muted purple — secondary / subtitle / icon labels.
  static const Color textSecondary = Color(0xFF9D95C7);

  /// Lighter muted purple — hints, char-counter, "start here" labels.
  static const Color textHint = Color(0xFFBBB7DF);

  /// Very light lavender — TextField placeholder text.
  static const Color textPlaceholder = Color(0xFFCDCAE8);

  // ─────────────────────────────────────────────────────────
  // Borders
  // ─────────────────────────────────────────────────────────

  /// Pale lavender — unselected card borders, input borders, dividers.
  static const Color borderLight = Color(0xFFE8E5F5);

  // ─────────────────────────────────────────────────────────
  // Status — Warning (streak at risk, char limit)
  // ─────────────────────────────────────────────────────────

  /// Amber — warning text, char-limit near-limit indicator, streak icon.
  static const Color warning = Color(0xFFFFB830);

  /// Very light amber — warning card background, streak badge background.
  static const Color warningLight = Color(0xFFFFF6E0);

  /// Dark gold — streak badge text.
  static const Color warningDark = Color(0xFFB8860B);

  // ─────────────────────────────────────────────────────────
  // Status — Error (AI failure card)
  // ─────────────────────────────────────────────────────────

  /// Light red — AI error card background.
  static const Color errorLight = Color(0xFFFFF0F0);

  /// Soft red border — AI error card border.
  static const Color errorBorder = Color(0xFFFFB3B3);

  /// Medium red icon — AI error icon.
  static const Color errorIcon = Color(0xFFE57373);

  /// Deep red text — AI error body text.
  static const Color errorText = Color(0xFFB71C1C);

  /// Material red accent — delete button, destructive actions.
  static const Color errorAccent = Colors.redAccent;

  // ─────────────────────────────────────────────────────────
  // Mood chart colors (ordered by moodIndex 0–4)
  // Used only in analytics_screen chart dots.
  // ─────────────────────────────────────────────────────────

  static const List<Color> moodChartColors = [
    Color(0xFF5B8DEF), // 0 – Rough  (blue)
    Color(0xFF9B6FDB), // 1 – Low    (violet)
    Color(0xFF7A8FA6), // 2 – Okay   (slate)
    Color(0xFF4CAF82), // 3 – Good   (green)
    Color(0xFFFFB830), // 4 – Great  (amber — reuses [warning])
  ];
}
