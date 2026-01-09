import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:intl/intl.dart';
import '../models/user_settings.dart';

/// ProfileCard 위젯
/// React의 ProfileCard.tsx를 Flutter로 변환
class ProfileCard extends StatelessWidget {
  final UserSettings settings;
  final int daysSinceQuit;
  final int moneySaved;
  final int cigarettesNotSmoked;
  final DateTime? currentTime;
  final DateTime? startDate;

  const ProfileCard({
    super.key,
    required this.settings,
    required this.daysSinceQuit,
    required this.moneySaved,
    required this.cigarettesNotSmoked,
    this.currentTime,
    this.startDate,
  });

  // 칭호 시스템 (titles_screen.dart와 동기화)
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

  Map<String, dynamic> getCurrentTitle() {
    for (int i = titles.length - 1; i >= 0; i--) {
      final titleDays = titles[i]['days'] as int;
      if (daysSinceQuit >= titleDays) {
        return titles[i];
      }
    }
    return {'days': 0, 'name': '초보자', 'emoji': '🥚'};
  }

  Map<String, dynamic>? getNextTitle() {
    for (int i = 0; i < titles.length; i++) {
      final titleDays = titles[i]['days'] as int;
      if (daysSinceQuit < titleDays) {
        return titles[i];
      }
    }
    return null;
  }

  // 클래스 정의 - personalGoalType에 따라 결정
  Map<String, dynamic> getClass() {
    switch (settings.personalGoalType) {
      case PersonalGoalType.money:
        return {
          'name': '재력가',
          'icon': LucideIcons.dollarSign,
          'colors': [const Color(0xFFF59E0B), const Color(0xFFEAB308)], // amber-500 to yellow-500
        };
      case PersonalGoalType.healthFamily:
        return {
          'name': '수호자',
          'icon': LucideIcons.heart,
          'colors': [const Color(0xFFF43F5E), const Color(0xFFEC4899)], // rose-500 to pink-500
        };
      case PersonalGoalType.none:
        return {
          'name': '여정의 용사',
          'icon': LucideIcons.users,
          'colors': [const Color(0xFF10B981), const Color(0xFF14B8A6)], // emerald-500 to teal-500
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTitle = getCurrentTitle();
    final nextTitle = getNextTitle();
    final playerClass = getClass();
    final classIcon = playerClass['icon'] as IconData;
    final classColors = playerClass['colors'] as List<Color>;

    // 다음 레벨까지의 경험치 (%)
    final expProgress = nextTitle != null && currentTitle['days'] != null
        ? ((daysSinceQuit - (currentTitle['days'] as int)) /
                ((nextTitle['days'] as int) - (currentTitle['days'] as int))) *
            100
        : daysSinceQuit < 1
            ? (daysSinceQuit / 1) * 100
            : 100.0;

    final numberFormat = NumberFormat.decimalPattern('ko');

    return Container(
      decoration: BoxDecoration(
        // bg-gradient-to-br from-emerald-500 via-teal-500 to-cyan-500
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10B981), // emerald-500
            Color(0xFF14B8A6), // teal-500
            Color(0xFF06B6D4), // cyan-500
          ],
        ),
        borderRadius: BorderRadius.circular(24), // rounded-3xl
        border: Border.all(
          color: Colors.white.withOpacity(0.3), // border-2 border-white/30
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // shadow-xl
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24), // p-6 md:p-8
      margin: const EdgeInsets.only(bottom: 24), // mb-6
      child: Stack(
        children: [
          // 배경 패턴
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: DiagonalPatternPainter(),
              ),
            ),
          ),

          // 메인 컨텐츠
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 왼쪽: 프로필 아이콘과 이름
                  Row(
                    children: [
                      // 프로필 아이콘
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: classColors,
                          ),
                          borderRadius: BorderRadius.circular(16), // rounded-2xl
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          classIcon,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 이름과 칭호
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 칭호 뱃지
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              '${currentTitle['emoji']} ${currentTitle['name']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // 닉네임
                          Text(
                            settings.nickname,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // 오른쪽: 레벨
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'LEVEL',
                        style: TextStyle(
                          color: Color(0xFF6EE7B7), // emerald-100
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        daysSinceQuit.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        '금연 일수',
                        style: TextStyle(
                          color: Color(0xFF99F6E4), // teal-100
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 경험치 바
              if (nextTitle != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'EXP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '다음 칭호까지 ${(nextTitle['days'] as int) - daysSinceQuit}일',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 경험치 바 컨테이너
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Stack(
                      children: [
                        // 그라데이션 경험치 바
                        FractionallySizedBox(
                          widthFactor: expProgress / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF86EFAC), // green-300
                                  Color(0xFF6EE7B7), // emerald-200
                                  Color(0xFF5EEAD4), // teal-300
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 추가 정보
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '절약한 금액',
                            style: TextStyle(
                              color: Color(0xFF99F6E4), // teal-100
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${numberFormat.format(moneySaved)}원',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '피우지 않은 담배',
                            style: TextStyle(
                              color: Color(0xFF99F6E4), // teal-100
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${numberFormat.format(cigarettesNotSmoked)}개비',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 대각선 패턴을 그리는 CustomPainter
class DiagonalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;

    const spacing = 35.0;
    const lineLength = 70.0;

    // 45도 각도로 대각선 패턴 그리기
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + lineLength, lineLength),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

