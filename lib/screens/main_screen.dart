import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'dashboard_screen.dart';
import 'milestones_screen.dart';
import 'titles_screen.dart';
import 'app_settings_screen.dart';

/// Main Screen with Bottom Navigation
/// React의 App.tsx의 하단 네비게이션을 Flutter로 변환
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MilestonesScreen(),
    const TitlesScreen(),
    const AppSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: LucideIcons.layoutDashboard,
                  label: '대시보드',
                  index: 0,
                ),
                _buildNavItem(
                  icon: LucideIcons.trendingUp,
                  label: '타임라인',
                  index: 1,
                ),
                _buildNavItem(
                  icon: LucideIcons.award,
                  label: '타이틀',
                  index: 2,
                ),
                _buildNavItem(
                  icon: LucideIcons.settings,
                  label: '설정',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFECFDF5) // emerald-50
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? const Color(0xFF10B981) // emerald-600
                  : const Color(0xFF6B7280), // gray-500
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? const Color(0xFF10B981) // emerald-600
                    : const Color(0xFF6B7280), // gray-500
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

