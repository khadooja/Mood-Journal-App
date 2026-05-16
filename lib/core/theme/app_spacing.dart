import 'package:flutter/material.dart';

/// Spacing constants — 8 px grid.
abstract final class AppSpacing {
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 20;
  static const double xxl  = 24;
  static const double xxxl = 32;
  static const double h    = 48;  // button height (secondary)
  static const double hLg  = 56;  // button height (primary)

  /// Standard horizontal page padding.
  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: xl);

  /// Standard card inner padding.
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
}

/// Border-radius tokens.
abstract final class AppRadius {
  static const double xs   = 8;
  static const double sm   = 12;
  static const double md   = 16;
  static const double lg   = 20;
  static const double xl   = 28;
  static const double full = 999;

  static BorderRadius get xsAll   => BorderRadius.circular(xs);
  static BorderRadius get smAll   => BorderRadius.circular(sm);
  static BorderRadius get mdAll   => BorderRadius.circular(md);
  static BorderRadius get lgAll   => BorderRadius.circular(lg);
  static BorderRadius get xlAll   => BorderRadius.circular(xl);
  static BorderRadius get fullAll => BorderRadius.circular(full);
}
