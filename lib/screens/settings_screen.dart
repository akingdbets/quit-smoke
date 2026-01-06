import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_settings.dart';

/// Settings Screen
/// React의 Settings.tsx를 Flutter로 변환
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _yearController = TextEditingController();
  final _monthController = TextEditingController();
  final _dayController = TextEditingController();
  final _cigarettesController = TextEditingController();
  final _priceController = TextEditingController();
  final _personalGoalController = TextEditingController();
  final _personalGoalAmountController = TextEditingController();

  PersonalGoalType _selectedGoalType = PersonalGoalType.money;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final settings = userProvider.settings;

    _nicknameController.text = settings.nickname;
    _cigarettesController.text = settings.cigarettesPerDay.toString();
    _priceController.text = settings.pricePerPack.toString();
    _personalGoalController.text = settings.personalGoal;
    _personalGoalAmountController.text = settings.personalGoalAmount > 0
        ? (settings.personalGoalAmount / 10000).toStringAsFixed(0)
        : '';
    _selectedGoalType = settings.personalGoalType;

    if (settings.startDate != null) {
      try {
        final date = DateTime.parse(settings.startDate!);
        _yearController.text = date.year.toString();
        _monthController.text = date.month.toString();
        _dayController.text = date.day.toString();
      } catch (e) {
        // 날짜 파싱 실패 시 빈 값으로 유지
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _cigarettesController.dispose();
    _priceController.dispose();
    _personalGoalController.dispose();
    _personalGoalAmountController.dispose();
    super.dispose();
  }


  Future<void> _handleSave() async {
    // 키보드 포커스 해제 후 약간 대기하여 입력 충돌 방지
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 200));

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 날짜 유효성 최종 검사
    try {
      final year = int.parse(_yearController.text);
      final month = int.parse(_monthController.text);
      final day = int.parse(_dayController.text);
      final date = DateTime(year, month, day);
      final now = DateTime.now();
      
      // 실제 날짜가 유효한지 확인 (예: 2월 30일 같은 경우)
      if (date.year != year || date.month != month || date.day != day) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('유효하지 않은 날짜입니다')),
          );
        }
        return;
      }
      
      if (date.isAfter(now)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('미래 날짜는 입력할 수 없습니다')),
          );
        }
        return;
      }
      
      if (date.isBefore(DateTime(2000, 1, 1))) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('2000년 이후 날짜를 입력해주세요')),
          );
        }
        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('올바른 날짜를 입력해주세요')),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentSettings = userProvider.settings;

      // 년도, 월, 일을 조합해서 YYYY-MM-DD 형식으로 변환
      final year = int.parse(_yearController.text);
      final month = int.parse(_monthController.text);
      final day = int.parse(_dayController.text);
      final dateString = '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

      final newSettings = currentSettings.copyWith(
        nickname: _nicknameController.text.trim(),
        startDate: dateString, // YYYY-MM-DD 형식
        cigarettesPerDay: int.parse(_cigarettesController.text),
        pricePerPack: int.parse(_priceController.text),
        personalGoalType: _selectedGoalType,
        personalGoal: _personalGoalController.text.trim(),
        personalGoalAmount: _selectedGoalType == PersonalGoalType.money &&
                _personalGoalAmountController.text.isNotEmpty
            ? (int.parse(_personalGoalAmountController.text) * 10000)
            : 0,
      );

      await userProvider.saveSettings(newSettings);

      // UserProvider의 상태 변경으로 HomeScreen이 자동으로 MainScreen으로 전환함
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24), // rounded-3xl
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 헤더
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF34D399), // emerald-400
                                    Color(0xFF14B8A6), // teal-500
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                LucideIcons.sparkles,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '새로운 시작',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937), // gray-800
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '건강한 내일을 위한 첫 걸음',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF6B7280), // gray-500
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // 닉네임
                      TextFormField(
                        controller: _nicknameController,
                        decoration: InputDecoration(
                          labelText: '닉네임',
                          hintText: '용사의 이름',
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB), // gray-50
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFF3F4F6), // gray-100
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFF3F4F6), // gray-100
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF6EE7B7), // emerald-300
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '닉네임을 입력해주세요';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // 금연 시작일 (년도, 월, 일 분리)
                      const Text(
                        '금연 시작일',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937), // gray-800
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // 년도
                          Expanded(
                            child: TextFormField(
                              controller: _yearController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: '년도',
                                hintText: '2024',
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB), // gray-50
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFF3F4F6), // gray-100
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFF3F4F6), // gray-100
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF6EE7B7), // emerald-300
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '년도';
                                }
                                final year = int.tryParse(value);
                                if (year == null) {
                                  return '숫자';
                                }
                                final now = DateTime.now();
                                if (year < 2000 || year > now.year) {
                                  return '2000~${now.year}';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 월
                          Expanded(
                            child: TextFormField(
                              controller: _monthController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: '월',
                                hintText: '1',
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB), // gray-50
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFF3F4F6), // gray-100
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFF3F4F6), // gray-100
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF6EE7B7), // emerald-300
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '월';
                                }
                                final month = int.tryParse(value);
                                if (month == null || month < 1 || month > 12) {
                                  return '1~12';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 일
                          Expanded(
                            child: TextFormField(
                              controller: _dayController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: '일',
                                hintText: '1',
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB), // gray-50
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFF3F4F6), // gray-100
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFF3F4F6), // gray-100
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF6EE7B7), // emerald-300
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '일';
                                }
                                final day = int.tryParse(value);
                                if (day == null || day < 1 || day > 31) {
                                  return '1~31';
                                }
                                
                                // 전체 날짜 유효성 검사
                                final year = int.tryParse(_yearController.text);
                                final month = int.tryParse(_monthController.text);
                                if (year != null && month != null) {
                                  try {
                                    final date = DateTime(year, month, day);
                                    final now = DateTime.now();
                                    if (date.isAfter(now)) {
                                      return '미래 날짜';
                                    }
                                    // 실제 날짜가 유효한지 확인 (예: 2월 30일 같은 경우)
                                    if (date.year != year || date.month != month || date.day != day) {
                                      return '유효하지 않음';
                                    }
                                  } catch (e) {
                                    return '유효하지 않음';
                                  }
                                }
                                
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 담배 개비수와 가격
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cigarettesController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: '하루 평균 담배 개비수',
                                hintText: '20',
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB), // gray-50
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFF3F4F6), // gray-100
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFF3F4F6), // gray-100
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF6EE7B7), // emerald-300
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '개비수를 입력해주세요';
                                }
                                final num = int.tryParse(value);
                                if (num == null || num < 1) {
                                  return '1 이상의 숫자를 입력해주세요';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: '담배 한 갑 가격 (원)',
                                hintText: '4500',
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB), // gray-50
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFF3F4F6), // gray-100
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFF3F4F6), // gray-100
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF6EE7B7), // emerald-300
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '가격을 입력해주세요';
                                }
                                final num = int.tryParse(value);
                                if (num == null || num < 1) {
                                  return '1 이상의 숫자를 입력해주세요';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // 개인 목표 타입 선택
                      const Text(
                        '금연으로 이루고 싶은 목표 (선택)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937), // gray-800
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildGoalTypeButton(
                              type: PersonalGoalType.money,
                              icon: LucideIcons.dollarSign,
                              label: '돈 관련\n목표',
                              color: const Color(0xFF10B981), // emerald
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGoalTypeButton(
                              type: PersonalGoalType.healthFamily,
                              icon: LucideIcons.heart,
                              label: '건강\n가족',
                              color: const Color(0xFFF43F5E), // rose
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGoalTypeButton(
                              type: PersonalGoalType.none,
                              icon: LucideIcons.fileText,
                              label: '그냥',
                              color: const Color(0xFF6B7280), // gray
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 목표 입력 필드
                      if (_selectedGoalType == PersonalGoalType.money) ...[
                        TextFormField(
                          controller: _personalGoalController,
                          decoration: InputDecoration(
                            labelText: '목표 이름',
                            hintText: '예: 제주도 여행',
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB), // gray-50
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFF3F4F6), // gray-100
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFF3F4F6), // gray-100
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFF6EE7B7), // emerald-300
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _personalGoalAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '목표 금액',
                            hintText: '100',
                            suffixText: '만원',
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB), // gray-50
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFF3F4F6), // gray-100
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFF3F4F6), // gray-100
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFF6EE7B7), // emerald-300
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ] else if (_selectedGoalType == PersonalGoalType.healthFamily) ...[
                        TextFormField(
                          controller: _personalGoalController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: '건강·가족 목표',
                            hintText:
                                '건강이나 가족 관련 목표를 적어보세요 (예: 매일 운동하기, 가족과 더 많은 시간 보내기)',
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB), // gray-50
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFF3F4F6), // gray-100
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFF3F4F6), // gray-100
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFFB7185), // rose-300
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // 저장 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            disabledBackgroundColor: Colors.grey[300],
                          ).copyWith(
                            backgroundColor: WidgetStateProperty.all(Colors.transparent),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: _isSaving
                                  ? null
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xFF10B981), // emerald-500
                                        Color(0xFF14B8A6), // teal-500
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(16),
                              color: _isSaving ? Colors.grey[300] : null,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      '금연 시작하기',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalTypeButton({
    required PersonalGoalType type,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _selectedGoalType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoalType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : const Color(0xFFF9FAFB), // gray-50
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : const Color(0xFFF3F4F6), // gray-100
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? color : const Color(0xFF9CA3AF), // gray-400
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? color
                    : const Color(0xFF1F2937), // gray-800
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

