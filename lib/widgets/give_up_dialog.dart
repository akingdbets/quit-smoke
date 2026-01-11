import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 금연 포기 다이얼로그
/// 감성적인 이탈 방지 UI를 제공
class GiveUpDialog extends StatelessWidget {
  final int daysSinceQuit;
  final int moneySaved;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool isLoading;

  const GiveUpDialog({
    super.key,
    required this.daysSinceQuit,
    required this.moneySaved,
    required this.onCancel,
    required this.onConfirm,
    this.isLoading = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int daysSinceQuit,
    required int moneySaved,
  }) async {
    bool? confirmed = false;
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => GiveUpDialog(
        daysSinceQuit: daysSinceQuit,
        moneySaved: moneySaved,
        onCancel: () => Navigator.pop(context, false),
        onConfirm: () => Navigator.pop(context, true),
      ),
    ).then((value) {
      confirmed = value;
    });
    return confirmed;
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern('ko');

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            const Text(
              '정말 포기하시겠습니까?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDC2626), // red-600
              ),
            ),
            const SizedBox(height: 24),

            // 지금까지의 노력 (배경색 있는 부분)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2).withOpacity(0.5), // red-50
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFECACA).withOpacity(0.5), // red-200
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF374151), // gray-700
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: '지금까지 '),
                        TextSpan(
                          text: '$daysSinceQuit일',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC2626), // red-600
                          ),
                        ),
                        const TextSpan(text: ' 동안 참으셨어요! 😢'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF374151), // gray-700
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: '아끼신 '),
                        TextSpan(
                          text: '${numberFormat.format(moneySaved)}원',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC2626), // red-600
                          ),
                        ),
                        const TextSpan(text: '이 모두 사라집니다 💸'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '삭제된 데이터는 절대 복구할 수 없습니다.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280), // gray-500
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 액션 버튼
            Row(
              children: [
                // 계속 할게요 (취소)
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981), // emerald-600
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '계속 할게요',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 포기할래요 (삭제)
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : onConfirm,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B7280), // gray-500
                      side: const BorderSide(
                        color: Color(0xFFE5E7EB), // gray-200
                        width: 1,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '포기할래요',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
