import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

/// Titles Screen
/// React의 Titles.tsx를 Flutter로 변환
class TitlesScreen extends StatelessWidget {
  const TitlesScreen({super.key});

  // 칭호 목록
  static const List<Map<String, dynamic>> titles = [
    {
      'days': 1,
      'name': '첫걸음',
      'emoji': '🌱',
      'description': '금연의 첫 하루를 시작했습니다'
    },
    {
      'days': 3,
      'name': '도전자',
      'emoji': '💪',
      'description': '3일간의 도전을 이어가고 있습니다'
    },
    {
      'days': 7,
      'name': '일주일 전사',
      'emoji': '⭐',
      'description': '일주일을 무사히 버텼습니다'
    },
    {
      'days': 14,
      'name': '2주 생존자',
      'emoji': '🔥',
      'description': '2주간의 여정을 완수했습니다'
    },
    {
      'days': 30,
      'name': '한달 정복자',
      'emoji': '🏆',
      'description': '한 달이라는 큰 산을 넘었습니다'
    },
    {
      'days': 60,
      'name': '두달 챔피언',
      'emoji': '👑',
      'description': '두 달간 금연을 유지했습니다'
    },
    {
      'days': 90,
      'name': '분기 마스터',
      'emoji': '💎',
      'description': '3개월의 금연에 성공했습니다'
    },
    {
      'days': 180,
      'name': '반년 영웅',
      'emoji': '🦸',
      'description': '반 년을 금연으로 채웠습니다'
    },
    {
      'days': 365,
      'name': '1년 레전드',
      'emoji': '🌟',
      'description': '1년간의 대장정을 완료했습니다'
    },
    {
      'days': 730,
      'name': '2년 신화',
      'emoji': '🔱',
      'description': '2년이라는 위업을 달성했습니다'
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

    // 현재 칭호 찾기
    final currentTitle = _getCurrentTitle(daysSinceQuit);
    final nextTitle = _getNextTitle(daysSinceQuit);

    // 다음 칭호까지의 진행률
    final daysUntilNextTitle = nextTitle != null
        ? (nextTitle['days'] as int) - daysSinceQuit
        : 0;
    final titleProgress = nextTitle != null && currentTitle != null
        ? ((daysSinceQuit - (currentTitle['days'] as int)) /
                ((nextTitle['days'] as int) - (currentTitle['days'] as int))) *
            100
        : daysSinceQuit < 1
            ? (daysSinceQuit / 1) * 100
            : 100.0;

    // 획득한 칭호 개수
    final unlockedCount =
        titles.where((t) => daysSinceQuit >= (t['days'] as int)).length;
    final totalCount = titles.length;
    final achievementRate = ((unlockedCount / totalCount) * 100).round();

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
                children: [
                  const Text(
                    '🏅',
                    style: TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '칭호 시스템',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937), // gray-800
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '금연 일수에 따라 새로운 칭호를 획득하세요',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4B5563), // gray-600
                ),
              ),

              const SizedBox(height: 24),

              // 현재 칭호 카드
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFACC15), // yellow-400
                      Color(0xFFF97316), // orange-500
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Text(
                      '현재 칭호',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentTitle != null
                          ? currentTitle['emoji'] as String
                          : '🥚',
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentTitle != null
                          ? currentTitle['name'] as String
                          : '시작 전',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                      Text(
                        currentTitle != null
                            ? currentTitle['description'] as String
                            : '금연을 시작해보세요',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 다음 칭호 진행률
              if (nextTitle != null) ...[
                Container(
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
                              color: const Color(0xFFFED7AA), // orange-100
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              LucideIcons.award,
                              size: 24,
                              color: Color(0xFFEA580C), // orange-600
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '다음 칭호까지',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF374151), // gray-700
                                  ),
                                ),
                                Text(
                                  '$daysUntilNextTitle일 남음',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937), // gray-800
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 진행률 바
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6), // gray-100
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: titleProgress / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFACC15), // yellow-400
                                  Color(0xFFF97316), // orange-500
                                ],
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 다음 칭호 미리보기
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB), // gray-50
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Text(
                              nextTitle['emoji'] as String,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nextTitle['name'] as String,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937), // gray-800
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    nextTitle['description'] as String,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF4B5563), // gray-600
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 전체 칭호 목록
              Container(
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
                    const Text(
                      '전체 칭호',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937), // gray-800
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: titles.length,
                      itemBuilder: (context, index) {
                        final title = titles[index];
                        final titleDays = title['days'] as int;
                        final isUnlocked = daysSinceQuit >= titleDays;
                        final isCurrent = currentTitle != null &&
                            currentTitle['days'] == titleDays;

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < titles.length - 1 ? 12 : 0,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: isUnlocked && isCurrent
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFFFEF3C7), // yellow-50
                                        Color(0xFFFED7AA), // orange-50
                                      ],
                                    )
                                  : null,
                              color: isUnlocked && !isCurrent
                                  ? const Color(0xFFF9FAFB) // gray-50
                                  : isUnlocked && isCurrent
                                      ? null
                                      : const Color(0xFFF9FAFB), // gray-50
                              borderRadius: BorderRadius.circular(16),
                              border: isUnlocked && isCurrent
                                  ? Border.all(
                                      color: const Color(0xFFFED7AA), // orange-200
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  title['emoji'] as String,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            title['name'] as String,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: isUnlocked
                                                  ? const Color(0xFF1F2937) // gray-800
                                                  : const Color(0xFF6B7280), // gray-500
                                            ),
                                          ),
                                          if (isCurrent) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF97316), // orange-500
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                '현재',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        title['description'] as String,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isUnlocked
                                              ? const Color(0xFF4B5563) // gray-600
                                              : const Color(0xFF9CA3AF), // gray-400
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${titleDays}일 달성 시',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isUnlocked
                                              ? const Color(0xFF6B7280) // gray-500
                                              : const Color(0xFF9CA3AF), // gray-400
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // 상태 아이콘
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isUnlocked
                                        ? const Color(0xFF10B981) // green-500
                                        : const Color(0xFFD1D5DB), // gray-300
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isUnlocked
                                        ? LucideIcons.check
                                        : LucideIcons.lock,
                                    size: isUnlocked ? 20 : 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // 통계
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.only(top: 24),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                '획득한 칭호',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4B5563), // gray-600
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$unlockedCount',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937), // gray-800
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                '전체 칭호',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4B5563), // gray-600
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$totalCount',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937), // gray-800
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                '달성률',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4B5563), // gray-600
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$achievementRate%',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937), // gray-800
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic>? _getCurrentTitle(int daysSinceQuit) {
    for (int i = titles.length - 1; i >= 0; i--) {
      if (daysSinceQuit >= (titles[i]['days'] as int)) {
        return titles[i];
      }
    }
    return null;
  }

  Map<String, dynamic>? _getNextTitle(int daysSinceQuit) {
    for (int i = 0; i < titles.length; i++) {
      if (daysSinceQuit < (titles[i]['days'] as int)) {
        return titles[i];
      }
    }
    return null;
  }
}

