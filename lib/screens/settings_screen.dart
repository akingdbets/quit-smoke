import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_settings.dart';
import '../widgets/give_up_dialog.dart';
import 'dart:async';

/// Settings Screen
/// 설정 화면 - iOS 시스템 설정/토스 스타일의 깔끔한 그룹형 리스트
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _nicknameController = TextEditingController();
  final _yearController = TextEditingController();
  final _monthController = TextEditingController();
  final _dayController = TextEditingController();
  final _cigarettesController = TextEditingController();
  final _cigarettesPerPackController = TextEditingController();
  final _priceController = TextEditingController();
  final _personalGoalController = TextEditingController();
  final _personalGoalAmountController = TextEditingController();

  PersonalGoalType _selectedGoalType = PersonalGoalType.money;
  bool _isSaving = false;
  bool _isCheckingNickname = false;
  String? _nicknameError;
  Timer? _nicknameCheckTimer;
  TimeOfDay? _selectedTime;
  bool _isDeletingAccount = false;

  /// 금칙어 리스트
  /// 실제 서비스 시에는 더 방대한 욕설 데이터베이스나 외부 필터링 API를 사용하는 것이 좋습니다
  static const List<String> _bannedWords = [
    // 욕설 및 비속어
    '바보',
    '멍청이',
    '멍청',
    '개새끼',
    '개소리',
    '씨발',
    '시발',
    '병신',
    '좆',
    '젓',
    '자지',
    '보지',
    '섹스',
    // 관리자 사칭
    'admin',
    '관리자',
    '운영자',
    'administrator',
    'operator',
    // 기타 부적절한 단어
    'test',
    '테스트',
    'null',
    'undefined',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final settings = userProvider.settings;

    _nicknameController.text = settings.nickname;
    _cigarettesController.text = settings.cigarettesPerDay.toString();
    _cigarettesPerPackController.text = settings.cigarettesPerPack.toString();
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
        _selectedTime = TimeOfDay.fromDateTime(date);
      } catch (e) {
        // 날짜 파싱 실패 시 빈 값으로 유지
      }
    }
  }

  @override
  void dispose() {
    _nicknameCheckTimer?.cancel();
    _scrollController.dispose();
    _nicknameController.dispose();
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _cigarettesController.dispose();
    _cigarettesPerPackController.dispose();
    _priceController.dispose();
    _personalGoalController.dispose();
    _personalGoalAmountController.dispose();
    super.dispose();
  }

  // 닉네임 유효성 검사
  bool _validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }
    final trimmed = value.trim();
    if (trimmed.length < 2 || trimmed.length > 8) {
      return false;
    }
    // 한글, 영문, 숫자만 허용
    final regex = RegExp(r'^[a-zA-Z0-9가-힣]+$');
    return regex.hasMatch(trimmed);
  }

  // 닉네임 중복 확인 (체크 버튼 클릭 시 호출)
  Future<void> _checkNicknameDuplicate() async {
    final nickname = _nicknameController.text.trim();
    
    // 1. 빈 값 체크
    if (nickname.isEmpty) {
      setState(() {
        _nicknameError = '닉네임을 입력해주세요';
      });
      return;
    }
    
    // 2. 기본 유효성 검사 (길이, 형식)
    if (!_validateNickname(nickname)) {
      setState(() {
        _nicknameError = '닉네임은 2-8자의 한글, 영문, 숫자만 사용 가능합니다';
      });
      return;
    }

    // 3. 금칙어 검사
    if (_bannedWords.any((word) => nickname.contains(word))) {
      setState(() {
        _nicknameError = '부적절한 단어가 포함되어 있어 사용할 수 없습니다';
      });
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentNickname = userProvider.settings.nickname;
    
    // 4. 현재 닉네임과 동일한 경우 (변경 없음)
    if (nickname == currentNickname) {
      setState(() {
        _nicknameError = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('현재 닉네임과 동일합니다'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    // 5. 중복 확인 (서버 통신)
    setState(() {
      _isCheckingNickname = true;
      _nicknameError = null;
    });

    try {
      final isDuplicate = await userProvider.checkNicknameDuplicate(nickname);
      if (mounted) {
        setState(() {
          _isCheckingNickname = false;
          if (isDuplicate) {
            _nicknameError = '이미 사용 중인 닉네임입니다';
          } else {
            _nicknameError = null;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('사용 가능한 닉네임입니다'),
                backgroundColor: Color(0xFF10B981), // emerald-600
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingNickname = false;
          _nicknameError = '중복 확인 중 오류가 발생했습니다';
        });
      }
    }
  }

  // 날짜 및 시간 유효성 검사 (강화)
  bool _validateDateTime() {
    try {
      final year = int.parse(_yearController.text);
      final month = int.parse(_monthController.text);
      final day = int.parse(_dayController.text);
      
      final time = _selectedTime ?? const TimeOfDay(hour: 0, minute: 0);
      final dateTime = DateTime(year, month, day, time.hour, time.minute);
      final now = DateTime.now();

      // 입력한 값과 실제 날짜가 일치하는지 확인
      if (dateTime.year != year || dateTime.month != month || dateTime.day != day) {
        return false;
      }

      // 미래 시간 차단
      if (dateTime.isAfter(now)) {
        return false;
      }

      // 1980년 1월 1일 이전 차단
      if (dateTime.isBefore(DateTime(1980, 1, 1))) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // 시간 선택 다이얼로그
  Future<void> _selectTime() async {
    final initialTime = _selectedTime ?? TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF10B981), // emerald-600
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 200));

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 닉네임 유효성 검사
    final nickname = _nicknameController.text.trim();
    if (!_validateNickname(nickname)) {
      setState(() {
        _nicknameError = '닉네임은 2-8자의 한글, 영문, 숫자만 사용 가능합니다';
      });
      _formKey.currentState!.validate();
      return;
    }

    // 금칙어 검사 (중복 확인 전에 수행하여 불필요한 네트워크 낭비 방지)
    if (_bannedWords.any((word) => nickname.contains(word))) {
      setState(() {
        _nicknameError = '부적절한 단어가 포함되어 있어 사용할 수 없습니다';
      });
      _formKey.currentState!.validate();
      return;
    }

    // 닉네임 중복 확인
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentNickname = userProvider.settings.nickname;
    if (nickname != currentNickname) {
      try {
        final isDuplicate = await userProvider.checkNicknameDuplicate(nickname);
        if (isDuplicate) {
          setState(() {
            _nicknameError = '이미 사용 중인 닉네임입니다';
          });
          _formKey.currentState!.validate();
          return;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('닉네임 확인 중 오류가 발생했습니다')),
          );
        }
        return;
      }
    }

    // 날짜 및 시간 유효성 검사
    if (!_validateDateTime()) {
      try {
        final year = int.parse(_yearController.text);
        final month = int.parse(_monthController.text);
        final day = int.parse(_dayController.text);
        final time = _selectedTime ?? const TimeOfDay(hour: 0, minute: 0);
        final dateTime = DateTime(year, month, day, time.hour, time.minute);
        final now = DateTime.now();

        if (dateTime.isAfter(now)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('미래의 시간은 입력할 수 없습니다')),
          );
        } else if (dateTime.isBefore(DateTime(1980, 1, 1))) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('올바른 날짜를 입력해주세요')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('올바른 날짜를 입력해주세요')),
          );
        }
      } catch (e) {
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
      final currentSettings = userProvider.settings;
      final year = int.parse(_yearController.text);
      final month = int.parse(_monthController.text);
      final day = int.parse(_dayController.text);
      final time = _selectedTime ?? const TimeOfDay(hour: 0, minute: 0);
      final dateTime = DateTime(year, month, day, time.hour, time.minute);
      // ISO 8601 형식으로 저장 (시간 포함)
      final dateString = dateTime.toIso8601String();

      final newSettings = currentSettings.copyWith(
        nickname: nickname,
        startDate: dateString,
        cigarettesPerDay: int.parse(_cigarettesController.text),
        cigarettesPerPack: int.parse(_cigarettesPerPackController.text),
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
        setState(() {
          _nicknameError = null;
        });
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

  // 알림 설정 업데이트
  Future<void> _updateNotificationSettings(bool value) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentSettings = userProvider.settings;
      final newSettings = currentSettings.copyWith(allowNotifications: value);
      await userProvider.saveSettings(newSettings);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('설정 저장 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  // 로그아웃 핸들러
  Future<void> _handleLogout() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  // 금연 포기 핸들러
  Future<void> _handleDeleteAccount() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final settings = userProvider.settings;

    // 금연 시작일이 없으면 성과 계산 불가
    if (settings.startDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('금연 시작일이 설정되지 않았습니다')),
        );
      }
      return;
    }

    final startDate = DateTime.parse(settings.startDate!);
    final now = DateTime.now();
    final daysSinceQuit = now.difference(startDate).inDays;
    final cigarettesNotSmoked = daysSinceQuit * settings.cigarettesPerDay;
    final cigarettesPerPack = settings.cigarettesPerPack > 0 ? settings.cigarettesPerPack : 20;
    final moneySaved = ((cigarettesNotSmoked / cigarettesPerPack) * settings.pricePerPack).floor();

    // GiveUpDialog 표시
    final confirmed = await GiveUpDialog.show(
      context,
      daysSinceQuit: daysSinceQuit,
      moneySaved: moneySaved,
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isDeletingAccount = true;
      });

      try {
        // 로딩 다이얼로그 표시
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        await userProvider.deleteAccount();

        // 다이얼로그 닫기
        if (mounted) {
          Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        }
      } catch (e) {
        if (mounted) {
          // 로딩 다이얼로그 닫기
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('계정 삭제 중 오류가 발생했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isDeletingAccount = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final settings = userProvider.settings;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F4F6),
          appBar: AppBar(
            title: const Text(
              '설정',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // A. 프로필 설정 섹션
                      _buildSection(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _nicknameController,
                                  decoration: InputDecoration(
                                    labelText: '닉네임',
                                    hintText: '2-8자의 한글, 영문, 숫자',
                                    errorText: _nicknameError,
                                    suffixIcon: _isCheckingNickname
                                        ? const Padding(
                                            padding: EdgeInsets.all(12),
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          )
                                        : IconButton(
                                            icon: const Icon(LucideIcons.check),
                                            onPressed: _checkNicknameDuplicate,
                                            tooltip: '중복 확인',
                                          ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return '닉네임을 입력해주세요';
                                    }
                                    if (!_validateNickname(value)) {
                                      return '2-8자의 한글, 영문, 숫자만 사용 가능합니다';
                                    }
                                    if (_nicknameError != null) {
                                      return _nicknameError;
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _nicknameError = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // B. 알림 설정 섹션
                      _buildSection(
                        children: [
                          SwitchListTile(
                            title: const Text('알림 수신 동의'),
                            subtitle: const Text(
                              '중요한 금연 마일스톤과 응원 메시지를 받습니다',
                              style: TextStyle(fontSize: 13),
                            ),
                            value: settings.allowNotifications,
                            onChanged: _updateNotificationSettings,
                            activeColor: const Color(0xFF10B981),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // C. 금연 정보 설정 섹션
                      _buildSection(
                        children: [
                          // 금연 시작일
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '금연 시작일',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _yearController,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          labelText: '년도',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        validator: (v) =>
                                            v!.isEmpty ? '년도를 입력해주세요' : null,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _monthController,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          labelText: '월',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        validator: (v) =>
                                            v!.isEmpty ? '월을 입력해주세요' : null,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _dayController,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          labelText: '일',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        validator: (v) =>
                                            v!.isEmpty ? '일을 입력해주세요' : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // 시작 시간 설명 텍스트
                                const Text(
                                  '금연 시작 시간',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF6B7280), // gray-500
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // 시작 시간 선택 버튼
                                OutlinedButton.icon(
                                  onPressed: _selectTime,
                                  icon: const Icon(
                                    LucideIcons.clock,
                                    size: 18,
                                  ),
                                  label: Text(
                                    _selectedTime != null
                                        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                        : '시작 시간 선택',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF10B981),
                                    side: const BorderSide(
                                      color: Color(0xFF10B981),
                                      width: 1.5,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Divider(height: 1),

                          // 하루 흡연량
                          ListTile(
                            title: const Text('하루 흡연량'),
                            subtitle: TextFormField(
                              controller: _cigarettesController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.end,
                              decoration: const InputDecoration(
                                hintText: '개비',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),

                          const Divider(height: 1),

                          // 한 갑당 개비 수
                          ListTile(
                            title: const Text('한 갑당 개비 수'),
                            subtitle: TextFormField(
                              controller: _cigarettesPerPackController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.end,
                              decoration: const InputDecoration(
                                hintText: '개',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),

                          const Divider(height: 1),

                          // 한 갑 가격
                          ListTile(
                            title: const Text('한 갑 가격'),
                            subtitle: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.end,
                              decoration: const InputDecoration(
                                hintText: '원',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),

                          const Divider(height: 1),

                          // 금연 목표
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '금연 목표',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildGoalTypeButton(
                                        type: PersonalGoalType.money,
                                        icon: LucideIcons.dollarSign,
                                        label: '돈',
                                        color: const Color(0xFF10B981),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildGoalTypeButton(
                                        type: PersonalGoalType.healthFamily,
                                        icon: LucideIcons.heart,
                                        label: '건강/가족',
                                        color: const Color(0xFFF43F5E),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildGoalTypeButton(
                                        type: PersonalGoalType.none,
                                        icon: LucideIcons.fileText,
                                        label: '기타',
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),

                                // 목표 상세 입력
                                if (_selectedGoalType == PersonalGoalType.money) ...[
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _personalGoalController,
                                    decoration: InputDecoration(
                                      labelText: '목표 이름',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _personalGoalAmountController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.end,
                                    decoration: InputDecoration(
                                      labelText: '목표 금액 (만원)',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ] else if (_selectedGoalType ==
                                    PersonalGoalType.healthFamily) ...[
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _personalGoalController,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      labelText: '목표 내용',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // D. 계정 관리 섹션
                      _buildSection(
                        children: [
                          ListTile(
                            title: const Text('로그아웃'),
                            trailing: const Icon(
                              LucideIcons.logOut,
                              size: 20,
                              color: Color(0xFF6B7280),
                            ),
                            onTap: _handleLogout,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            title: const Text(
                              '금연 포기하기 (계정 삭제)',
                              style: TextStyle(color: Colors.red),
                            ),
                            trailing: const Icon(
                              LucideIcons.trash2,
                              size: 20,
                              color: Colors.red,
                            ),
                            onTap: _isDeletingAccount ? null : _handleDeleteAccount,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 100), // 저장 버튼 공간 확보
                    ],
                  ),
                ),

                // 저장 버튼 (하단 고정)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF10B981),
                              Color(0xFF14B8A6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  '저장하기',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 섹션 빌더 (흰색 컨테이너)
  Widget _buildSection({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
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
      onTap: () => setState(() => _selectedGoalType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? color : const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color : const Color(0xFF1F2937),
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
