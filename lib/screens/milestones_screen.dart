import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

/// Milestones Screen
/// React의 Milestones.tsx를 Flutter로 변환
class MilestonesScreen extends StatelessWidget {
  const MilestonesScreen({super.key});

  // 마일스톤 데이터
  static const List<Map<String, dynamic>> milestones = [
    {
      'days': 1,
      'title': '첫 24시간',
      'emoji': '🌅',
      'health': '혈압과 맥박이 정상으로',
      'message': '첫 하루를 보내셨네요! 벌써 몸이 회복되기 시작했어요.',
    },
    {
      'days': 3,
      'title': '3일',
      'emoji': '🌿',
      'health': '니코틴 배출 완료',
      'message': '니코틴이 몸에서 빠져나갔어요. 미각과 후각이 돌아오고 있어요.',
    },
    {
      'days': 7,
      'title': '1주일',
      'emoji': '💚',
      'health': '폐 기능 개선 시작',
      'message': '일주일을 해냈어요! 폐가 회복되고 숨쉬기가 편해질 거예요.',
    },
    {
      'days': 14,
      'title': '2주',
      'emoji': '🌸',
      'health': '혈액순환 크게 개선',
      'message': '2주 달성! 혈액순환이 좋아지고 피부도 건강해지고 있어요.',
    },
    {
      'days': 30,
      'title': '1개월',
      'emoji': '🎉',
      'health': '면역력 강화',
      'message': '한 달을 해냈어요! 면역력이 강해지고 폐가 치유되고 있어요.',
    },
    {
      'days': 90,
      'title': '3개월',
      'emoji': '🏆',
      'health': '폐 기능 30% 향상',
      'message': '3개월 완료! 폐 기능이 크게 좋아졌어요. 정말 대단해요!',
    },
    {
      'days': 180,
      'title': '6개월',
      'emoji': '⭐',
      'health': '호흡기 질환 위험 감소',
      'message': '반년이에요! 호흡기가 훨씬 건강해졌어요. 정말 자랑스러워요!',
    },
    {
      'days': 365,
      'title': '1년',
      'emoji': '👑',
      'health': '심장마비 위험 50% 감소',
      'message': '1년 달성! 당신은 승리자예요. 정말 축하드립니다!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final settings = userProvider.settings;

    if (settings.startDate == null) {
      return const Center(
        child: Text('설정을 먼저 완료해주세요'),
      );
    }

    final startDate = DateTime.parse(settings.startDate!);
    final now = DateTime.now();
    final daysSinceQuit = now.difference(startDate).inDays;

    // 달성한 마일스톤 개수
    final achievedCount = milestones.where((m) => daysSinceQuit >= (m['days'] as int)).length;

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
          child: Container(
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
                // 헤더
                Row(
                  children: [
                    const Icon(
                      LucideIcons.sparkles,
                      size: 24,
                      color: Color(0xFF10B981), // emerald-500
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '건강 회복 타임라인',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937), // gray-800
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 마일스톤 리스트
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: milestones.length,
                  itemBuilder: (context, index) {
                    final milestone = milestones[index];
                    final milestoneDays = milestone['days'] as int;
                    final isAchieved = daysSinceQuit >= milestoneDays;
                    final isNext = !isAchieved &&
                        achievedCount == index;

                    // 진행률 계산
                    final progress = isNext
                        ? ((daysSinceQuit / milestoneDays) * 100).clamp(0.0, 100.0)
                        : 0.0;

                    return _buildMilestoneItem(
                      milestone: milestone,
                      isAchieved: isAchieved,
                      isNext: isNext,
                      progress: progress,
                      daysSinceQuit: daysSinceQuit,
                      isLast: index == milestones.length - 1,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneItem({
    required Map<String, dynamic> milestone,
    required bool isAchieved,
    required bool isNext,
    required double progress,
    required int daysSinceQuit,
    required bool isLast,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Stack(
        children: [
          // 타임라인 선
          if (!isLast)
            Positioned(
              left: 24,
              top: 48,
              bottom: -24,
              child: Container(
                width: 2,
                decoration: BoxDecoration(
                  color: isAchieved
                      ? const Color(0xFF6EE7B7) // emerald-300
                      : const Color(0xFFE5E7EB), // gray-200
                ),
              ),
            ),

          // 마일스톤 아이템
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 아이콘 영역
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: isAchieved
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF34D399), // emerald-400
                            Color(0xFF14B8A6), // teal-500
                          ],
                        )
                      : null,
                  color: isNext
                      ? const Color(0xFFD1FAE5) // emerald-100
                      : const Color(0xFFF3F4F6), // gray-100
                  borderRadius: BorderRadius.circular(16),
                  border: isAchieved
                      ? null
                      : Border.all(
                          color: isNext
                              ? const Color(0xFF6EE7B7) // emerald-300
                              : const Color(0xFFE5E7EB), // gray-200
                          width: 2,
                        ),
                  boxShadow: isAchieved
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isAchieved
                      ? Text(
                          milestone['emoji'] as String,
                          style: const TextStyle(fontSize: 24),
                        )
                      : Icon(
                          LucideIcons.lock,
                          size: 20,
                          color: isNext
                              ? const Color(0xFF10B981) // emerald-500
                              : const Color(0xFFD1D5DB), // gray-300
                        ),
                ),
              ),

              const SizedBox(width: 16),

              // 내용 영역
              Expanded(
                child: Transform.scale(
                  scale: isNext ? 1.05 : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isAchieved
                          ? const Color(0xFFF9FAFB) // gray-50
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isAchieved
                            ? const Color(0xFFD1FAE5) // emerald-200
                            : isNext
                                ? const Color(0xFF6EE7B7) // emerald-300
                                : const Color(0xFFF3F4F6), // gray-100
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제목과 상태
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              milestone['title'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isAchieved
                                    ? const Color(0xFF065F46) // emerald-700
                                    : const Color(0xFF1F2937), // gray-800
                              ),
                            ),
                            if (isAchieved)
                              Row(
                                children: [
                                  const Icon(
                                    LucideIcons.check,
                                    size: 16,
                                    color: Color(0xFF10B981), // emerald-600
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '달성',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF10B981), // emerald-600
                                    ),
                                  ),
                                ],
                              )
                            else if (isNext)
                              Text(
                                '${(milestone['days'] as int) - daysSinceQuit}일 남음',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF10B981), // emerald-600
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 건강 정보
                        Text(
                          milestone['health'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: isAchieved
                                ? const Color(0xFF4B5563) // gray-600
                                : const Color(0xFF6B7280), // gray-500
                          ),
                        ),

                        // 달성 메시지
                        if (isAchieved) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              milestone['message'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4B5563), // gray-600
                              ),
                            ),
                          ),
                        ],

                        // 진행률 바
                        if (isNext && progress > 0) ...[
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1FAE5), // emerald-100
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: FractionallySizedBox(
                                  widthFactor: progress / 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF34D399), // emerald-400
                                          Color(0xFF2DD4BF), // teal-400
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${progress.toStringAsFixed(0)}% 달성',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF10B981), // emerald-600
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

