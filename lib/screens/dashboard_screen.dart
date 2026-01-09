import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/user_provider.dart';
import '../models/user_settings.dart';
import '../widgets/profile_card.dart';
import '../widgets/personal_goal_modal.dart';

/// Dashboard Screen
/// React의 Dashboard.tsx를 Flutter로 변환
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime? _currentTime;
  int? _lastCheckedTitleDays; // 마지막으로 체크한 타이틀 일수

  // 타이틀 목록 (titles_screen.dart와 동기화)
  static const List<Map<String, dynamic>> titles = [
    {'days': 1, 'name': '청정 혈류의 서막', 'emoji': '❤️'},
    {'days': 3, 'name': '신체 기능 재활자', 'emoji': '🔄'},
    {'days': 7, 'name': '감각 체계 복원가', 'emoji': '👃'},
    {'days': 14, 'name': '강인한 순환기계', 'emoji': '💪'},
    {'days': 30, 'name': '호흡기 정화 마스터', 'emoji': '🫁'},
    {'days': 90, 'name': '심혈관 리스크 관리자', 'emoji': '🩺'},
    {'days': 180, 'name': '폐 기능의 혁신가', 'emoji': '📈'},
    {'days': 365, 'name': '완전한 신체 독립', 'emoji': '🦅'},
    {'days': 1000, 'name': '불멸의 폐 건강', 'emoji': '🏆'},
  ];

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    // 초기 타이틀 체크
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTitleAchievement(_currentTime ?? DateTime.now());
    });
    // 1초마다 업데이트
    Future.delayed(Duration.zero, () {
      _startTimer();
    });
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
        _checkTitleAchievement(_currentTime ?? DateTime.now());
        _startTimer();
      }
    });
  }

  // 타이틀 달성 체크 및 알림
  void _checkTitleAchievement(DateTime now) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final settings = userProvider.settings;

    if (settings.startDate == null) return;

    final startDate = DateTime.parse(settings.startDate!);
    final daysSinceQuit = now.difference(startDate).inDays;

    // 새로운 타이틀 달성 체크
    for (final title in titles) {
      final titleDays = title['days'] as int;
      if (daysSinceQuit >= titleDays) {
        // 이전에 체크하지 않은 타이틀인 경우 알림 표시
        if (_lastCheckedTitleDays == null || _lastCheckedTitleDays! < titleDays) {
          _lastCheckedTitleDays = titleDays;
          _showTitleAchievementNotification(
            titleDays: titleDays,
            titleName: title['name'] as String,
            titleEmoji: title['emoji'] as String,
          );
          break; // 가장 최근 달성한 타이틀만 알림
        }
      }
    }
  }

  // 금연 진행 상황 공유
  void _shareQuitProgress(Duration duration, UserSettings settings) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    // 현재 타이틀 가져오기
    final currentTitle = _getCurrentTitle(days);
    final titleName = currentTitle != null ? currentTitle['name'] as String : '금연 중';
    final titleEmoji = currentTitle != null ? currentTitle['emoji'] as String : '💪';
    
    // 절약한 금액 계산
    final totalDays = duration.inSeconds / 86400.0;
    final cigarettesNotSmoked = (totalDays * settings.cigarettesPerDay).round();
    final pricePerCigarette = settings.pricePerPack / settings.cigarettesPerPack;
    final moneySaved = (cigarettesNotSmoked * pricePerCigarette).round();
    
    final numberFormat = NumberFormat.decimalPattern('ko');
    
    // 공유할 텍스트 생성
    String timeText;
    if (days > 0) {
      timeText = '$days일 $hours시간 $minutes분 $seconds초';
    } else if (hours > 0) {
      timeText = '$hours시간 $minutes분 $seconds초';
    } else if (minutes > 0) {
      timeText = '$minutes분 $seconds초';
    } else {
      timeText = '$seconds초';
    }
    
    final shareText = '''
🏆 금연 성과 공유

${titleEmoji} 현재 타이틀: $titleName

⏰ 금연 시간: $timeText
💰 절약한 금액: ${numberFormat.format(moneySaved)}원
🚭 피우지 않은 담배: ${numberFormat.format(cigarettesNotSmoked)}개비

건강한 선택, 멋진 성과입니다! 💪
''';

    Share.share(shareText);
  }

  // 현재 타이틀 가져오기
  Map<String, dynamic>? _getCurrentTitle(int daysSinceQuit) {
    for (int i = titles.length - 1; i >= 0; i--) {
      if (daysSinceQuit >= (titles[i]['days'] as int)) {
        return titles[i];
      }
    }
    return null;
  }

  // 타이틀 달성 알림 표시
  void _showTitleAchievementNotification({
    required int titleDays,
    required String titleName,
    required String titleEmoji,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              titleEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '새로운 타이틀 획득!',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$titleDays일 달성: $titleName',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981), // emerald-600
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final settings = userProvider.settings;

    if (settings.startDate == null) {
      return const SizedBox.shrink();
    }

    final startDate = DateTime.parse(settings.startDate!);
    final now = _currentTime ?? DateTime.now();
    
    // 정확한 시간 차이 계산 (일, 시간, 분, 초)
    final duration = now.difference(startDate);
    final daysSinceQuit = duration.inDays;
    
    // 실시간 담배 개비수 계산 (초 단위까지 정확하게)
    final totalSeconds = duration.inSeconds;
    final totalDays = totalSeconds / 86400.0; // 초를 일로 변환 (24시간 * 60분 * 60초)
    final cigarettesNotSmoked = (totalDays * settings.cigarettesPerDay).round();
    
    // 실시간 절약 금액 계산 (초 단위까지 정확하게)
    // 한 개비당 가격 계산
    final pricePerCigarette = settings.pricePerPack / settings.cigarettesPerPack;
    // 실시간 절약 금액 = 담배 개비수 * 한 개비당 가격
    final moneySaved = (cigarettesNotSmoked * pricePerCigarette).round();

    // 매일 변경되는 목표 아이템 시스템
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final todayItem = _getTodayItem(dayOfYear);

    // 선택된 아이템의 진행률 및 수량 계산
    final itemRawAmount = moneySaved / (todayItem['price'] as int);
    final itemAmount = itemRawAmount >= 0.01
        ? itemRawAmount.toStringAsFixed(2)
        : itemRawAmount.toStringAsFixed(4);

    // 개인 목표 진행률
    final personalGoalAmount = settings.personalGoalAmount > 0
        ? settings.personalGoalAmount
        : 1000000;
    final personalProgress = ((moneySaved / personalGoalAmount) * 100).clamp(0.0, 100.0);

    // 오늘의 동기부여 문구
    final todayMotivation = _getTodayMotivation(dayOfYear);

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
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _getReasonEmoji(settings.quitReason),
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '금연 여정',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937), // gray-800
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getMotivationMessage(settings.quitReason),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF4B5563), // gray-600
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 공유 버튼
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _shareQuitProgress(duration, settings),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          LucideIcons.share2,
                          size: 24,
                          color: Color(0xFF6B7280), // gray-500
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // RPG 프로필 카드
              ProfileCard(
                settings: settings,
                daysSinceQuit: daysSinceQuit,
                moneySaved: moneySaved,
                cigarettesNotSmoked: cigarettesNotSmoked,
                currentTime: now,
                startDate: startDate,
              ),

              // 통계 카드들
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildQuitTimeCard(
                                duration,
                                numberFormat,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildGoalItemCard(
                                todayItem,
                                itemAmount,
                                moneySaved,
                                numberFormat,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildPersonalGoalCard(
                                context,
                                userProvider,
                                settings,
                                personalProgress,
                                moneySaved,
                                personalGoalAmount,
                                numberFormat,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildQuitTimeCard(
                              duration,
                              numberFormat,
                            ),
                            const SizedBox(height: 16),
                            _buildGoalItemCard(
                              todayItem,
                              itemAmount,
                              moneySaved,
                              numberFormat,
                            ),
                            const SizedBox(height: 16),
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
                        );
                },
              ),

              const SizedBox(height: 16),

              // 오늘의 금연 동기부여 문구
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFAF5FF), // purple-50
                      Color(0xFFFDF2F8), // pink-50
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE9D5FF), // purple-100
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    '💡 $todayMotivation',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151), // gray-700
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 매일 변경되는 목표 아이템 시스템
  static List<Map<String, dynamic>> get _goalItems => [
        {
          'name': '테슬라 주식',
          'price': 520000,
          'unit': '주',
          'icon': LucideIcons.trendingUp,
          'bgColor': const Color(0xFFF3E8FF), // purple-100
          'textColor': const Color(0xFF9333EA), // purple-600
          'description': 'TSLA',
        },
        {
          'name': '엔비디아 주식',
          'price': 1560000,
          'unit': '주',
          'icon': LucideIcons.zap,
          'bgColor': const Color(0xFFDCFCE7), // green-100
          'textColor': const Color(0xFF16A34A), // green-600
          'description': 'NVDA',
        },
        {
          'name': '애플 주식',
          'price': 300000,
          'unit': '주',
          'icon': LucideIcons.smartphone,
          'bgColor': const Color(0xFFF3F4F6), // gray-100
          'textColor': const Color(0xFF4B5563), // gray-600
          'description': 'AAPL',
        },
        {
          'name': '페라리 488',
          'price': 350000000,
          'unit': '개',
          'icon': LucideIcons.car,
          'bgColor': const Color(0xFFFEE2E2), // red-100
          'textColor': const Color(0xFFDC2626), // red-600
          'description': '슈퍼카',
        },
        {
          'name': '아이폰 16 Pro',
          'price': 1550000,
          'unit': '개',
          'icon': LucideIcons.smartphone,
          'bgColor': const Color(0xFFDBEAFE), // blue-100
          'textColor': const Color(0xFF2563EB), // blue-600
          'description': '최신형',
        },
        {
          'name': '맥북 Pro',
          'price': 3200000,
          'unit': '개',
          'icon': LucideIcons.trendingUp,
          'bgColor': const Color(0xFFE0E7FF), // indigo-100
          'textColor': const Color(0xFF4F46E5), // indigo-600
          'description': '16인치',
        },
        {
          'name': '포르쉐 911',
          'price': 180000000,
          'unit': '개',
          'icon': LucideIcons.car,
          'bgColor': const Color(0xFFFEF9C3), // yellow-100
          'textColor': const Color(0xFFCA8A04), // yellow-600
          'description': '스포츠카',
        },
      ];

  // 오늘의 날짜를 기준으로 아이템 선택 (매일 변경)
  static Map<String, dynamic> _getTodayItem(int dayOfYear) {
    return _goalItems[dayOfYear % _goalItems.length];
  }

  // 하루마다 바뀌는 재미있는 금연 동기부여 문구
  static const List<String> _dailyMotivationMessages = [
    "담배를 끊으면 미각이 돌아옵니다. 음식이 진짜 맛있어요! 🍕",
    "금연하면 폐 기능이 30% 증가합니다. 계단이 쉬워져요! 💪",
    "담배 냄새로 인한 사회적 거리두기를 종료하세요! 😊",
    "금연 2주면 혈액순환이 개선됩니다. 손발이 따뜻해져요! 🔥",
    "담배 한 갑 대신 맛있는 점심을 드세요! 🍜",
    "금연하면 수명이 평균 10년 늘어납니다! ⏰",
    "아침에 일어나면 목이 개운합니다. 더 이상 가래 없어요! 🌅",
    "금연 3개월이면 폐활량이 눈에 띄게 좋아집니다! 🫁",
    "담배 값으로 매달 여행 저축하세요! ✈️",
    "금연하면 치아가 하얘집니다. 미소가 밝아져요! 😁",
    "호흡이 편해지면 숙면을 취할 수 있어요! 😴",
    "금연은 최고의 안티에이징 화장품입니다! 💆",
    "아이들에게 최고의 롤모델이 되세요! 👨‍👧‍👦",
    "담배를 끊으면 5년 후 심장병 위험이 절반으로! ❤️",
    "금연하면 피부가 좋아집니다. 주름이 줄어들어요! ✨",
    "운동 효과가 2배! 금연으로 체력 업그레이드! 🏃",
    "금연 1년이면 심장마비 위험 50% 감소! 💚",
    "커피 한 잔이 더 맛있어집니다! ☕",
    "담배 대신 취미에 투자하세요! 🎸",
    "금연하면 스트레스가 진짜로 줄어듭니다! 🧘",
    "담배 냄새 안 나는 차, 최고죠! 🚗",
    "금연 후 후각이 돌아옵니다. 향수가 살아요! 👃",
    "담배값으로 한 달에 신상 하나 겟! 🛍️",
    "금연하면 집중력이 올라갑니다! 📚",
    "아침 기침이 사라집니다. 상쾌한 하루! 🌞",
    "금연으로 면역력 업! 감기 안녕~ 🤧",
    "담배 대신 물을 마시세요. 디톡스 효과! 💧",
    "금연 5년이면 뇌졸중 위험이 비흡연자 수준! 🧠",
    "목소리가 맑아집니다. 노래방 가자! 🎤",
    "담배 없이도 충분히 멋져요! 😎"
  ];

  static String _getTodayMotivation(int dayOfYear) {
    return _dailyMotivationMessages[dayOfYear % _dailyMotivationMessages.length];
  }

  static String _getMotivationMessage(QuitReason quitReason) {
    switch (quitReason) {
      case QuitReason.health:
        return '매일 조금씩 건강해지고 있어요';
      case QuitReason.money:
        return '아낀 돈으로 행복을 만들어보세요';
      case QuitReason.family:
        return '소중한 사람들과의 시간이 더 많아져요';
      case QuitReason.selfImprovement:
        return '더 나은 나를 만들어가고 있어요';
    }
  }

  static String _getReasonEmoji(QuitReason quitReason) {
    switch (quitReason) {
      case QuitReason.health:
        return '🌱';
      case QuitReason.money:
        return '💰';
      case QuitReason.family:
        return '👨‍👩‍👧‍👦';
      case QuitReason.selfImprovement:
        return '⭐';
    }
  }

  Widget _buildQuitTimeCard(
    Duration duration,
    NumberFormat numberFormat,
  ) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7), // amber-100
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.clock,
              size: 20,
              color: Color(0xFFD97706), // amber-600
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '금연 시간',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF374151), // gray-700
            ),
          ),
          const Spacer(),
          // 실시간 금연 시간 표시 (한 줄)
          Text(
            days > 0
                ? '$days일 $hours시간 $minutes분 $seconds초'
                : hours > 0
                    ? '$hours시간 $minutes분 $seconds초'
                    : minutes > 0
                        ? '$minutes분 $seconds초'
                        : '$seconds초',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937), // gray-800
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItemCard(
    Map<String, dynamic> todayItem,
    String itemAmount,
    int moneySaved,
    NumberFormat numberFormat,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: todayItem['bgColor'] as Color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  todayItem['icon'] as IconData,
                  size: 24,
                  color: todayItem['textColor'] as Color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todayItem['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF374151),
                      ),
                    ),
                    Text(
                      todayItem['description'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280), // gray-500
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$itemAmount${todayItem['unit']}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '절약 금액: ${numberFormat.format(moneySaved)}원',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4B5563),
                ),
              ),
              Text(
                '1${todayItem['unit']} = ${numberFormat.format(todayItem['price'])}원',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE), // blue-100
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      LucideIcons.target,
                      size: 24,
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
                            fontSize: 16,
                            color: Color(0xFF374151),
                          ),
                        ),
                        if (settings.personalGoalType == PersonalGoalType.money &&
                            settings.personalGoalAmount > 0)
                          Text(
                            settings.personalGoal.isNotEmpty
                                ? settings.personalGoal
                                : '목표를 설정하세요',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF374151),
                            ),
                          )
                        else if (settings.personalGoalType == PersonalGoalType.healthFamily &&
                            settings.personalGoal.isNotEmpty)
                          const Text(
                            '건강·가족 목표',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF374151),
                            ),
                          )
                        else if (settings.personalGoalType == PersonalGoalType.none)
                          const Text(
                            '목표 없음',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF374151),
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (settings.personalGoalType == PersonalGoalType.money &&
                  settings.personalGoalAmount > 0) ...[
                // 진행률 바
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE), // blue-100
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: FractionallySizedBox(
                      widthFactor: personalProgress / 100,
                      child: Container(
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
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${numberFormat.format(moneySaved)}원',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    Text(
                      '${numberFormat.format(personalGoalAmount)}원',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ] else if (settings.personalGoalType == PersonalGoalType.healthFamily &&
                  settings.personalGoal.isNotEmpty) ...[
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF2F8), // rose-50
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFCE7F3), // rose-100
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    settings.personalGoal,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ] else if (settings.personalGoalType == PersonalGoalType.none) ...[
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB), // gray-50
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFF3F4F6), // gray-100
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Center(
                    child: Text(
                      '목표 없이도 충분히 잘하고 있어요! 🎉',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280), // gray-500
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF), // blue-50
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFDBEAFE), // blue-100
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    '클릭해서 목표를 설정하세요',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF374151),
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
}

