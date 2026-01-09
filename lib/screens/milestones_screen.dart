import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

/// Milestones Screen
/// React의 Milestones.tsx를 Flutter로 변환
class MilestonesScreen extends StatelessWidget {
  const MilestonesScreen({super.key});

  // 마일스톤 데이터 (WHO, CDC 및 금연 연구 논문 기반)
  static const List<Map<String, dynamic>> milestones = [
    {
      'days': 1,
      'title': '24시간',
      'emoji': '❤️',
      'health': '심장마비 위험 감소 시작',
      'message': '혈중 일산화탄소 수치가 100% 정상 범위로 회복되었습니다. 심혈관 시스템이 즉각적인 개선을 보이기 시작합니다.',
    },
    {
      'days': 3,
      'title': '3일',
      'emoji': '🫁',
      'health': '호흡량 약 10% 증가',
      'message': '기관지 이완으로 호흡량이 약 10% 증가했습니다. 니코틴 대사 산물의 90% 이상이 체내에서 배출 완료되었습니다.',
    },
    {
      'days': 7,
      'title': '1주일',
      'emoji': '👃',
      'health': '감각 예민도 20~30% 개선',
      'message': '미각과 후각 신경 재생으로 감각 예민도가 20~30% 개선되었습니다. 흡연 욕구의 피크 시점을 통과했습니다.',
    },
    {
      'days': 14,
      'title': '2주',
      'emoji': '💪',
      'health': '혈액 순환 기능 15~20% 개선',
      'message': '혈액 순환 기능이 15~20% 개선되었으며, 폐활량이 눈에 띄게 증가하기 시작했습니다.',
    },
    {
      'days': 30,
      'title': '1개월',
      'emoji': '🌿',
      'health': '폐의 섬모 세포 재생 활성화',
      'message': '폐의 섬모 세포 재생이 활성화되었습니다. 기침 및 숨 가쁨이 10% 이상 감소했으며, 피부 톤과 탄력이 개선되었습니다.',
    },
    {
      'days': 90,
      'title': '3개월',
      'emoji': '🏆',
      'health': '폐 기능 30% 이상 향상',
      'message': '정자 활성도 및 수태 능력이 30% 증가했으며, 폐 기능이 30% 이상 향상되었습니다.',
    },
    {
      'days': 180,
      'title': '6개월',
      'emoji': '⭐',
      'health': '기도 내 염증 수치 50% 이상 감소',
      'message': '기도 내 염증 수치가 50% 이상 감소했으며, 스트레스 조절 능력이 정상화되었습니다.',
    },
    {
      'days': 365,
      'title': '1년',
      'emoji': '👑',
      'health': '관상동맥 심장질환 위험 50% 감소',
      'message': '관상동맥 심장질환 위험이 흡연자 대비 50% 감소했습니다. 심혈관 건강이 크게 개선되었습니다.',
    },
    {
      'days': 1000,
      'title': '1000일 (약 2.7년)',
      'emoji': '🌟',
      'health': '폐암 사망 위험 약 30% 감소',
      'message': '폐암 사망 위험이 약 30% 감소했으며, 뇌졸중 위험이 비흡연자 수준으로 회복되기 시작했습니다.',
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

