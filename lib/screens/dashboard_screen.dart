import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../providers/user_provider.dart';
import '../models/user_settings.dart';
import '../data/goal_items.dart';
import '../widgets/personal_goal_modal.dart';
import '../widgets/profile_card.dart';
import '../widgets/real_time_ticker.dart';
import '../widgets/real_time_item_amount_ticker.dart';
import 'goal_selection_screen.dart';

/// Dashboard Screen
/// React의 Dashboard.tsx를 Flutter로 변환
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final settings = userProvider.settings;

    if (settings.startDate == null) {
      return const SizedBox.shrink();
    }

    final startDate = DateTime.parse(settings.startDate!);
    final now = DateTime.now();
    final daysSinceQuit = now.difference(startDate).inDays;

    final cigarettesNotSmoked = daysSinceQuit * settings.cigarettesPerDay;
    final cigarettesPerPack = settings.cigarettesPerPack > 0 ? settings.cigarettesPerPack : 20;
    final moneySaved = ((cigarettesNotSmoked / cigarettesPerPack) * settings.pricePerPack).floor();

    // 목표 아이템 선택 (사용자 선택 우선, 없으면 날짜 기반)
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final todayItem = _getTodayItem(settings, dayOfYear);

    // 개인 목표 진행률
    final personalGoalAmount = settings.personalGoalAmount > 0
        ? settings.personalGoalAmount
        : 1000000;
    final personalProgress = ((moneySaved / personalGoalAmount) * 100).clamp(0.0, 100.0);

    final numberFormat = NumberFormat.decimalPattern('ko');

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0FDF4), // green-50
            Color(0xFFECFDF5), // emerald-50
            Color(0xFFF0FDFA), // teal-50
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더: 식물 표시 + "금연 현황"
              Row(
                children: [
                  const Text(
                    '🌱',
                    style: TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '금연 현황',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937), // gray-800
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // A. 상단: 프로필 영역 (Stack 디자인)
              _buildProfileSection(startDate, settings, daysSinceQuit, cigarettesNotSmoked, moneySaved),

              const SizedBox(height: 30), // 뱃지가 겹칠 공간 확보

              // B. 통계 리스트 섹션 (일관된 리스트)
              _buildStatsList(context, startDate, settings, todayItem, numberFormat),

              const SizedBox(height: 24),

              // C. 개인 목표 섹션
              _buildPersonalGoalCard(
                context,
                userProvider,
                settings,
                personalProgress,
                moneySaved,
                personalGoalAmount,
                numberFormat,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A. 프로필 섹션 빌더 (Stack 디자인 - ProfileCard + 실시간 타이머 뱃지)
  Widget _buildProfileSection(
    DateTime startDate,
    UserSettings settings,
    int daysSinceQuit,
    int cigarettesNotSmoked,
    int moneySaved,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Base Layer: ProfileCard
        ProfileCard(
          settings: settings,
          daysSinceQuit: daysSinceQuit,
          moneySaved: moneySaved,
          cigarettesNotSmoked: cigarettesNotSmoked,
          startDate: startDate,
          showStats: false,
        ),
        // Overlay Layer: 실시간 타이머 뱃지
        Positioned(
          bottom: -16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981), // emerald-600
                borderRadius: BorderRadius.circular(999), // StadiumBorder (캡슐 모양)
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: RealTimeTicker(
                startDate: startDate,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // B. 통계 리스트 섹션 빌더 (일관된 리스트 스타일)
  Widget _buildStatsList(
    BuildContext context,
    DateTime startDate,
    UserSettings settings,
    Map<String, dynamic> todayItem,
    NumberFormat numberFormat,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. 절약한 금액
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE).withOpacity(0.5), // blue-100
                borderRadius: BorderRadius.circular(20), // 원형
              ),
              child: const Icon(
                LucideIcons.dollarSign,
                size: 20,
                color: Color(0xFF2563EB), // blue-600
              ),
            ),
            title: const Text(
              '절약한 금액',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151), // gray-700
              ),
            ),
            trailing: RealTimeMoneyTicker(
              startDate: startDate,
              cigarettesPerDay: settings.cigarettesPerDay,
              cigarettesPerPack: settings.cigarettesPerPack,
              pricePerPack: settings.pricePerPack,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937), // gray-800
                fontFeatures: [FontFeature.tabularFigures()],
              ),
              numberFormat: numberFormat,
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            indent: 80,
            endIndent: 20,
            color: const Color(0xFFE5E7EB), // gray-200
          ),
          // 2. 목표 아이템 (탭 가능)
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GoalSelectionScreen(),
                ),
              );
            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (todayItem['bgColor'] as Color).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20), // 원형
                ),
                child: Icon(
                  todayItem['icon'] as IconData,
                  size: 20,
                  color: todayItem['textColor'] as Color,
                ),
              ),
              title: Text(
                todayItem['name'] as String,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151), // gray-700
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RealTimeItemAmountTicker(
                    startDate: startDate,
                    settings: settings,
                    todayItem: todayItem,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: todayItem['textColor'] as Color,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 20,
                    color: (todayItem['textColor'] as Color).withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            indent: 80,
            endIndent: 20,
            color: const Color(0xFFE5E7EB), // gray-200
          ),
          // 3. 참은 담배
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2).withOpacity(0.5), // red-100
                borderRadius: BorderRadius.circular(20), // 원형
              ),
              child: const Icon(
                LucideIcons.ban,
                size: 20,
                color: Color(0xFFDC2626), // red-600
              ),
            ),
            title: const Text(
              '참은 담배',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151), // gray-700
              ),
            ),
            trailing: _RealTimeCigarettesTicker(
              startDate: startDate,
              settings: settings,
              numberFormat: numberFormat,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937), // gray-800
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            indent: 80,
            endIndent: 20,
            color: const Color(0xFFE5E7EB), // gray-200
          ),
          // 4. 절약한 시간
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7).withOpacity(0.5), // amber-100
                borderRadius: BorderRadius.circular(20), // 원형
              ),
              child: const Icon(
                LucideIcons.clock,
                size: 20,
                color: Color(0xFFD97706), // amber-600
              ),
            ),
            title: const Text(
              '절약한 시간',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151), // gray-700
              ),
            ),
            trailing: RealTimeHoursTicker(
              startDate: startDate,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937), // gray-800
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // C. 개인 목표 카드 빌더
  Widget _buildPersonalGoalCard(
    BuildContext context,
    UserProvider userProvider,
    UserSettings settings,
    double personalProgress,
    int moneySaved,
    int personalGoalAmount,
    NumberFormat numberFormat,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          PersonalGoalModal.show(
            context: context,
            currentGoal: settings.personalGoal,
            onSave: (goal) async {
              await userProvider.updatePersonalGoal(goal);
            },
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE).withOpacity(0.5), // blue-100
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.target,
                      size: 20,
                      color: Color(0xFF2563EB), // blue-600
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '개인 목표',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151), // gray-700
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          settings.personalGoal.isNotEmpty
                              ? settings.personalGoal
                              : '목표를 설정하세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: settings.personalGoal.isNotEmpty
                                ? const Color(0xFF1F2937)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (settings.personalGoalType == PersonalGoalType.money &&
                      settings.personalGoalAmount > 0)
                    Text(
                      '${personalProgress.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                ],
              ),
              if (settings.personalGoalType == PersonalGoalType.money &&
                  settings.personalGoalAmount > 0) ...[
                const SizedBox(height: 16),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB), // gray-200
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: FractionallySizedBox(
                        widthFactor: (personalProgress / 100).clamp(0.0, 1.0),
                        child: Container(
                          height: 8,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF60A5FA), // blue-400
                                Color(0xFF06B6D4), // cyan-500
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${numberFormat.format(moneySaved)}원',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280), // gray-500
                      ),
                    ),
                    Text(
                      '${numberFormat.format(personalGoalAmount)}원',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280), // gray-500
                      ),
                    ),
                  ],
                ),
              ] else if (settings.personalGoalType == PersonalGoalType.healthFamily &&
                  settings.personalGoal.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF2F8).withOpacity(0.5), // rose-50
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFCE7F3).withOpacity(0.5), // rose-100
                    ),
                  ),
                  child: Text(
                    settings.personalGoal,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ] else if (settings.personalGoalType == PersonalGoalType.none) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB), // gray-50
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF3F4F6), // gray-100
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '목표 없이도 충분히 잘하고 있어요! 🎉',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280), // gray-500
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF).withOpacity(0.5), // blue-50
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFDBEAFE).withOpacity(0.5), // blue-100
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '목표를 설정해보세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280), // gray-500
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 목표 아이템 선택 (사용자 선택 우선, 없으면 날짜 기반)
  static Map<String, dynamic> _getTodayItem(UserSettings settings, int dayOfYear) {
    // 사용자가 선택한 목표가 있으면 해당 아이템 반환
    if (settings.selectedGoalId != null) {
      final selectedItem = GoalItems.findById(settings.selectedGoalId!);
      if (selectedItem != null) {
        return selectedItem;
      }
    }

    // 선택한 목표가 없으면 날짜 기반으로 선택
    return GoalItems.getByDayOfYear(dayOfYear);
  }
}

/// 실시간 담배 개수 표시 위젯
class _RealTimeCigarettesTicker extends StatefulWidget {
  final DateTime startDate;
  final UserSettings settings;
  final NumberFormat numberFormat;
  final TextStyle? style;

  const _RealTimeCigarettesTicker({
    required this.startDate,
    required this.settings,
    required this.numberFormat,
    this.style,
  });

  @override
  State<_RealTimeCigarettesTicker> createState() => _RealTimeCigarettesTickerState();
}

class _RealTimeCigarettesTickerState extends State<_RealTimeCigarettesTicker> {
  Timer? _timer;
  int _cigarettesNotSmoked = 0;

  @override
  void initState() {
    super.initState();
    _updateCigarettes();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _updateCigarettes();
        });
      }
    });
  }

  void _updateCigarettes() {
    final now = DateTime.now();
    final elapsed = now.difference(widget.startDate);
    final daysSinceQuit = elapsed.inMilliseconds / (1000 * 60 * 60 * 24);

    _cigarettesNotSmoked = (daysSinceQuit * widget.settings.cigarettesPerDay).round();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${widget.numberFormat.format(_cigarettesNotSmoked)}개비',
      style: widget.style,
    );
  }
}