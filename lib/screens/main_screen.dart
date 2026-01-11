import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'dashboard_screen.dart';
import 'milestones_screen.dart';
import 'titles_screen.dart';
import 'social_screen.dart';
import 'settings_screen.dart';

/// Main Screen with Bottom Navigation
/// React의 App.tsx의 하단 네비게이션을 Flutter로 변환
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  DateTime? _lastBackPressedTime;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MilestonesScreen(),
    const SocialScreen(),
    const TitlesScreen(),
    const SettingsScreen(),
  ];

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressedTime == null ||
        now.difference(_lastBackPressedTime!) > const Duration(seconds: 2)) {
      _lastBackPressedTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('뒤로가기를 한 번 더 누르면 앱이 종료됩니다'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF6B7280),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
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
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: _buildNavItem(
                  icon: LucideIcons.layoutDashboard,
                  label: '대시보드',
                  index: 0,
                )),
                Expanded(child: _buildNavItem(
                  icon: LucideIcons.trendingUp,
                  label: '타임라인',
                  index: 1,
                )),
                Expanded(child: _buildNavItem(
                  icon: LucideIcons.users,
                  label: '커뮤니티',
                  index: 2,
                )),
                Expanded(child: _buildNavItem(
                  icon: LucideIcons.award,
                  label: '타이틀',
                  index: 3,
                )),
                Expanded(child: _buildNavItem(
                  icon: LucideIcons.settings,
                  label: '설정',
                  index: 4,
                )),
              ],
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
              size: 22,
              color: isSelected
                  ? const Color(0xFF10B981) // emerald-600
                  : const Color(0xFF6B7280), // gray-500
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? const Color(0xFF10B981) // emerald-600
                    : const Color(0xFF6B7280), // gray-500
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

