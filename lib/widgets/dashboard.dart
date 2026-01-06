import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_settings.dart';
import 'profile_card.dart';

/// Dashboard 위젯
/// React의 Dashboard.tsx를 Flutter로 변환
class Dashboard extends StatefulWidget {
  final UserSettings settings;
  final VoidCallback onOpenSettings;
  final Function(String) onUpdatePersonalGoal;

  const Dashboard({
    super.key,
    required this.settings,
    required this.onOpenSettings,
    required this.onUpdatePersonalGoal,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // bool _isGoalModalOpen = false; // TODO: PersonalGoalModal 구현 시 사용

  // 매일 변경되는 목표 아이템 시스템
  static List<Map<String, dynamic>> get goalItems => [
    {
      'name': '테슬라 주식',
      'price': 520000,
      'unit': '주',
      'icon': Icons.trending_up,
      'bgColor': const Color(0xFFF3E8FF), // purple-100
      'textColor': const Color(0xFF9333EA), // purple-600
      'description': 'TSLA',
    },
    {
      'name': '엔비디아 주식',
      'price': 1560000,
      'unit': '주',
      'icon': Icons.bolt,
      'bgColor': const Color(0xFFDCFCE7), // green-100
      'textColor': const Color(0xFF16A34A), // green-600
      'description': 'NVDA',
    },
    {
      'name': '애플 주식',
      'price': 300000,
      'unit': '주',
      'icon': Icons.smartphone,
      'bgColor': const Color(0xFFF3F4F6), // gray-100
      'textColor': const Color(0xFF4B5563), // gray-600
      'description': 'AAPL',
    },
    {
      'name': '페라리 488',
      'price': 350000000,
      'unit': '개',
      'icon': Icons.directions_car,
      'bgColor': const Color(0xFFFEE2E2), // red-100
      'textColor': const Color(0xFFDC2626), // red-600
      'description': '슈퍼카',
    },
    {
      'name': '아이폰 16 Pro',
      'price': 1550000,
      'unit': '개',
      'icon': Icons.smartphone,
      'bgColor': const Color(0xFFDBEAFE), // blue-100
      'textColor': const Color(0xFF2563EB), // blue-600
      'description': '최신형',
    },
    {
      'name': '맥북 Pro',
      'price': 3200000,
      'unit': '개',
      'icon': Icons.trending_up,
      'bgColor': const Color(0xFFE0E7FF), // indigo-100
      'textColor': const Color(0xFF4F46E5), // indigo-600
      'description': '16인치',
    },
    {
      'name': '포르쉐 911',
      'price': 180000000,
      'unit': '개',
      'icon': Icons.directions_car,
      'bgColor': const Color(0xFFFEF9C3), // yellow-100
      'textColor': const Color(0xFFCA8A04), // yellow-600
      'description': '스포츠카',
    },
  ];

  // 하루마다 바뀌는 재미있는 금연 동기부여 문구
  static const List<String> dailyMotivationMessages = [
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

  Map<String, dynamic> getTodayItem() {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    return goalItems[dayOfYear % goalItems.length];
  }

  String getTodayMotivation() {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    return dailyMotivationMessages[dayOfYear % dailyMotivationMessages.length];
  }

  String getMotivationMessage() {
    switch (widget.settings.quitReason) {
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

  String getReasonEmoji() {
    switch (widget.settings.quitReason) {
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

  @override
  Widget build(BuildContext context) {
    if (widget.settings.startDate == null) {
      return const SizedBox.shrink();
    }

    final startDate = DateTime.parse(widget.settings.startDate!);
    final today = DateTime.now();
    final daysSinceQuit = today.difference(startDate).inDays;

    final cigarettesNotSmoked = daysSinceQuit * widget.settings.cigarettesPerDay;
    final moneySaved = ((cigarettesNotSmoked / 20) * widget.settings.pricePerPack).floor();

    // 절약한 시간 계산 (담배 한 개비당 약 5분 소요)
    final minutesSaved = cigarettesNotSmoked * 5;
    final hoursSaved = (minutesSaved / 60).floor();
    final daysSaved = (hoursSaved / 24).floor();

    final todayItem = getTodayItem();
    final itemRawAmount = moneySaved / (todayItem['price'] as int);
    final itemAmount = itemRawAmount >= 0.01
        ? itemRawAmount.toStringAsFixed(2)
        : itemRawAmount.toStringAsFixed(4);

    // 개인 목표 진행률
    final personalGoalAmount = widget.settings.personalGoalAmount > 0
        ? widget.settings.personalGoalAmount
        : 1000000;
    final personalProgress = ((moneySaved / personalGoalAmount) * 100).clamp(0.0, 100.0);

    final numberFormat = NumberFormat.decimalPattern('ko');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        getReasonEmoji(),
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
                    getMotivationMessage(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4B5563), // gray-600
                    ),
                  ),
                ],
              ),
              // 설정 버튼
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onOpenSettings,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.settings,
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
            settings: widget.settings,
            daysSinceQuit: daysSinceQuit,
            moneySaved: moneySaved,
            cigarettesNotSmoked: cigarettesNotSmoked,
          ),

          // 통계 카드들
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return isWide
                  ? Row(
                      children: [
                        Expanded(child: _buildTimeCard(daysSaved, hoursSaved, minutesSaved, cigarettesNotSmoked, numberFormat)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildGoalItemCard(todayItem, itemAmount, moneySaved, numberFormat)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildPersonalGoalCard(personalProgress, moneySaved, personalGoalAmount, numberFormat)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildTimeCard(daysSaved, hoursSaved, minutesSaved, cigarettesNotSmoked, numberFormat),
                        const SizedBox(height: 16),
                        _buildGoalItemCard(todayItem, itemAmount, moneySaved, numberFormat),
                        const SizedBox(height: 16),
                        _buildPersonalGoalCard(personalProgress, moneySaved, personalGoalAmount, numberFormat),
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
                '💡 ${getTodayMotivation()}',
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
    );
  }

  Widget _buildTimeCard(int daysSaved, int hoursSaved, int minutesSaved, int cigarettesNotSmoked, NumberFormat numberFormat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // rounded-3xl
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
                  color: const Color(0xFFFEF3C7), // amber-100
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.access_time,
                  size: 24,
                  color: Color(0xFFD97706), // amber-600
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '절약한 시간',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF374151), // gray-700
                  ),
                ),
              ),
              Text(
                daysSaved > 0 ? '${daysSaved}일' : '${hoursSaved}시간',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937), // gray-800
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 ${numberFormat.format(minutesSaved)}분',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4B5563), // gray-600
                ),
              ),
              Text(
                '${numberFormat.format(cigarettesNotSmoked)}개비',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4B5563), // gray-600
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            daysSaved > 0
                ? '${daysSaved}일치의 시간을 되찾았어요!'
                : '${hoursSaved}시간을 되찾았어요!',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF374151), // gray-700
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItemCard(Map<String, dynamic> todayItem, String itemAmount, int moneySaved, NumberFormat numberFormat) {
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

  Widget _buildPersonalGoalCard(double personalProgress, int moneySaved, int personalGoalAmount, NumberFormat numberFormat) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: PersonalGoalModal 구현
          // setState(() {
          //   _isGoalModalOpen = true;
          // });
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
                      Icons.track_changes,
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
                        if (widget.settings.personalGoalType == PersonalGoalType.money &&
                            widget.settings.personalGoalAmount > 0)
                          Text(
                            widget.settings.personalGoal.isNotEmpty
                                ? widget.settings.personalGoal
                                : '목표를 설정하세요',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF374151),
                            ),
                          )
                        else if (widget.settings.personalGoalType == PersonalGoalType.healthFamily &&
                            widget.settings.personalGoal.isNotEmpty)
                          const Text(
                            '건강·가족 목표',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF374151),
                            ),
                          )
                        else if (widget.settings.personalGoalType == PersonalGoalType.none)
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
                  if (widget.settings.personalGoalType == PersonalGoalType.money &&
                      widget.settings.personalGoalAmount > 0)
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
              if (widget.settings.personalGoalType == PersonalGoalType.money &&
                  widget.settings.personalGoalAmount > 0) ...[
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
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
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
              ] else if (widget.settings.personalGoalType == PersonalGoalType.healthFamily &&
                  widget.settings.personalGoal.isNotEmpty) ...[
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
                    widget.settings.personalGoal,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ] else if (widget.settings.personalGoalType == PersonalGoalType.none) ...[
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

