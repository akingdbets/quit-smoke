import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_settings.dart';

/// Settings Screen
/// 설정 화면 - 개인 정보 수정 및 로그아웃 기능
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
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 200));

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final year = int.parse(_yearController.text);
      final month = int.parse(_monthController.text);
      final day = int.parse(_dayController.text);
      final date = DateTime(year, month, day);
      final now = DateTime.now();

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

      final year = int.parse(_yearController.text);
      final month = int.parse(_monthController.text);
      final day = int.parse(_dayController.text);
      final dateString =
          '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

      final newSettings = currentSettings.copyWith(
        nickname: _nicknameController.text.trim(),
        startDate: dateString,
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정이 저장되었습니다')),
        );
      }
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

  // 로그아웃 핸들러
  Future<void> _handleLogout() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.signOut();
      // 로그아웃 시 UserProvider가 상태 변화를 감지하여 MainScreen을 재빌드, 로그인 화면으로 이동됨
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '설정',
          style:
              TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 닉네임
                  TextFormField(
                    controller: _nicknameController,
                    decoration: InputDecoration(
                      labelText: '닉네임',
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFF3F4F6)),
                      ),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? '닉네임을 입력해주세요'
                            : null,
                  ),
                  const SizedBox(height: 24),

                  // 금연 시작일
                  const Text('금연 시작일',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _yearController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: '년도',
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          validator: (v) => v!.isEmpty ? '년도' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _monthController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: '월',
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          validator: (v) => v!.isEmpty ? '월' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _dayController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: '일',
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          validator: (v) => v!.isEmpty ? '일' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 담배 정보
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cigarettesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: '하루 흡연량 (개비)',
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16))),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: '한 갑 가격 (원)',
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 목표 선택
                  const Text('금연 목표',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildGoalTypeButton(
                              type: PersonalGoalType.money,
                              icon: LucideIcons.dollarSign,
                              label: '돈',
                              color: const Color(0xFF10B981))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildGoalTypeButton(
                              type: PersonalGoalType.healthFamily,
                              icon: LucideIcons.heart,
                              label: '건강/가족',
                              color: const Color(0xFFF43F5E))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildGoalTypeButton(
                              type: PersonalGoalType.none,
                              icon: LucideIcons.fileText,
                              label: '기타',
                              color: const Color(0xFF6B7280))),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 목표 상세 입력
                  if (_selectedGoalType == PersonalGoalType.money) ...[
                    TextFormField(
                      controller: _personalGoalController,
                      decoration: InputDecoration(
                          labelText: '목표 이름',
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16))),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _personalGoalAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: '목표 금액 (만원)',
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16))),
                    ),
                  ] else if (_selectedGoalType ==
                      PersonalGoalType.healthFamily) ...[
                    TextFormField(
                      controller: _personalGoalController,
                      maxLines: 4,
                      decoration: InputDecoration(
                          labelText: '목표 내용',
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16))),
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
                            borderRadius: BorderRadius.circular(16)),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ).copyWith(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.transparent)),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF14B8A6)]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('저장하기',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // [추가됨] 로그아웃 버튼
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _handleLogout,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.red[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side:
                              BorderSide(color: Colors.red.shade100, width: 1),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.logOut, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '로그아웃',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalTypeButton(
      {required PersonalGoalType type,
      required IconData icon,
      required String label,
      required Color color}) {
    final isSelected = _selectedGoalType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedGoalType = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? color : const Color(0xFFF3F4F6), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 24, color: isSelected ? color : const Color(0xFF9CA3AF)),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? color : const Color(0xFF1F2937),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
