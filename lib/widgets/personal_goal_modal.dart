import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// PersonalGoalModal 위젯
/// React의 PersonalGoalModal.tsx를 Flutter의 showDialog로 변환
class PersonalGoalModal {
  /// 모달 표시
  static Future<void> show({
    required BuildContext context,
    required String currentGoal,
    required Function(String) onSave,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return _PersonalGoalModalDialog(
          currentGoal: currentGoal,
          onSave: onSave,
        );
      },
    );
  }
}

class _PersonalGoalModalDialog extends StatefulWidget {
  final String currentGoal;
  final Function(String) onSave;

  const _PersonalGoalModalDialog({
    required this.currentGoal,
    required this.onSave,
  });

  @override
  State<_PersonalGoalModalDialog> createState() => _PersonalGoalModalDialogState();
}

class _PersonalGoalModalDialogState extends State<_PersonalGoalModalDialog>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _goalController;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController(text: widget.currentGoal);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _goalController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final goal = _goalController.text.trim();
    if (goal.isNotEmpty) {
      widget.onSave(goal);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24), // rounded-3xl
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 닫기 버튼
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    LucideIcons.x,
                    size: 20,
                    color: Color(0xFF6B7280), // gray-500
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 헤더
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF60A5FA), // blue-400
                          Color(0xFF06B6D4), // cyan-500
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      LucideIcons.target,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '개인 목표 설정',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937), // gray-800
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '금연으로 아낀 돈으로 이루고 싶은 목표를 입력하세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 입력 필드
              TextField(
                controller: _goalController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: '목표',
                  hintText: '예: 여행 자금 모으기, 노트북 구매하기 등',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB), // gray-50
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB), // gray-200
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB), // gray-200
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF60A5FA), // blue-300
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF374151), // gray-700
                ),
                onSubmitted: (_) => _handleSave(),
              ),

              const SizedBox(height: 24),

              // 버튼
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _goalController.text.trim().isEmpty ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.grey[300],
                        elevation: 0,
                      ).copyWith(
                        backgroundColor: WidgetStateProperty.all(Colors.transparent),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: _goalController.text.trim().isEmpty
                              ? null
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFF3B82F6), // blue-500
                                    Color(0xFF06B6D4), // cyan-500
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(16),
                          color: _goalController.text.trim().isEmpty
                              ? Colors.grey[300]
                              : null,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Center(
                          child: Text(
                            '저장',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

