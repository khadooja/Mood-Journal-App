import 'home_screen.dart';
import 'analytics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_decorations.dart';
import 'package:google_fonts/google_fonts.dart';


/// Root shell that owns the floating [NavigationBar] and the FAB.
/// [HomeScreen] and [AnalyticsScreen] live as tabs in an [IndexedStack].
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.backgroundGradientStart,
        extendBody: true, // allows content to bleed under the nav bar
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            HomeScreen(),
            AnalyticsScreen(),
          ],
        ),
        // FAB only on the Home tab
        floatingActionButton: _selectedIndex == 0 ? null : null,
        bottomNavigationBar: _buildFloatingNavBar(),
      ),
    );
  }

  Widget _buildFloatingNavBar() {
    const items = [
      _NavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home'),
      _NavItem(icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart_rounded, label: 'Analytics'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.navBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.floating,
          border: Border.all(color: AppColors.borderLight, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final item      = items[i];
            final isSelected = _selectedIndex == i;

            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.10)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      size: 22,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: isSelected
                          ? Row(
                              children: [
                                const SizedBox(width: 8),
                                Text(
                                  item.label,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Simple data class for nav items — no logic, purely visual.
class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
