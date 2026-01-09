import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_settings.dart';

/// UserSettings 상태 관리 Provider (Riverpod)
/// 
/// React의 App.tsx에 있는 상태 관리 로직을 Flutter Riverpod으로 변환:
/// - useState -> StateNotifier
/// - useEffect -> 초기화 로직
/// - localStorage -> shared_preferences
class UserSettingsNotifier extends StateNotifier<UserSettings> {
  static const String _storageKey = 'quitSmokingSettings';
  final SharedPreferences _prefs;

  UserSettingsNotifier(this._prefs) : super(UserSettings.defaultSettings()) {
    _loadSettings();
  }

  /// localStorage에서 설정 로드 (React의 useEffect 로직)
  Future<void> _loadSettings() async {
    try {
      final saved = _prefs.getString(_storageKey);
      if (saved != null) {
        final json = jsonDecode(saved) as Map<String, dynamic>;
        state = UserSettings.fromJson(json);
      }
    } catch (e) {
      // 에러 발생 시 기본값 유지
      print('설정 로드 중 오류 발생: $e');
    }
  }

  /// 설정 저장 (React의 saveSettings 함수)
  Future<void> saveSettings(UserSettings newSettings) async {
    try {
      state = newSettings;
      await _prefs.setString(_storageKey, jsonEncode(newSettings.toJson()));
    } catch (e) {
      print('설정 저장 중 오류 발생: $e');
      rethrow;
    }
  }

  /// 개인 목표 업데이트 (React의 updatePersonalGoal 함수)
  Future<void> updatePersonalGoal(String goal) async {
    try {
      final newSettings = state.copyWith(personalGoal: goal);
      state = newSettings;
      await _prefs.setString(_storageKey, jsonEncode(newSettings.toJson()));
    } catch (e) {
      print('개인 목표 업데이트 중 오류 발생: $e');
      rethrow;
    }
  }

  /// 특정 필드 업데이트 헬퍼 메서드
  Future<void> updateField({
    String? startDate,
    int? cigarettesPerDay,
    int? cigarettesPerPack,
    int? pricePerPack,
    QuitReason? quitReason,
    String? personalGoal,
    PersonalGoalType? personalGoalType,
    String? personalGoalCategory,
    int? personalGoalAmount,
    String? healthGoal,
    String? nickname,
    int? age,
  }) async {
    try {
      final newSettings = state.copyWith(
        startDate: startDate,
        cigarettesPerDay: cigarettesPerDay,
        cigarettesPerPack: cigarettesPerPack,
        pricePerPack: pricePerPack,
        quitReason: quitReason,
        personalGoal: personalGoal,
        personalGoalType: personalGoalType,
        personalGoalCategory: personalGoalCategory,
        personalGoalAmount: personalGoalAmount,
        healthGoal: healthGoal,
        nickname: nickname,
        age: age,
      );
      state = newSettings;
      await _prefs.setString(_storageKey, jsonEncode(newSettings.toJson()));
    } catch (e) {
      print('필드 업데이트 중 오류 발생: $e');
      rethrow;
    }
  }
}

/// SharedPreferences Provider
/// 앱 시작 시 한 번만 초기화
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// UserSettings Provider
/// SharedPreferences가 준비되면 UserSettingsNotifier를 생성
final userSettingsProvider = StateNotifierProvider<UserSettingsNotifier, UserSettings>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  
  // SharedPreferences가 아직 로드되지 않았으면 기본값 반환
  if (prefsAsync.hasValue) {
    return UserSettingsNotifier(prefsAsync.value!);
  }
  
  // 임시로 기본 SharedPreferences 인스턴스 사용 (실제로는 FutureProvider 사용 권장)
  // 이 경우 앱 시작 시 await ref.read(sharedPreferencesProvider.future)를 먼저 호출해야 함
  throw UnimplementedError('SharedPreferences가 아직 초기화되지 않았습니다.');
});

/// 더 안전한 버전: AsyncNotifier 사용
class UserSettingsAsyncNotifier extends AsyncNotifier<UserSettings> {
  static const String _storageKey = 'quitSmokingSettings';

  @override
  Future<UserSettings> build() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    return _loadSettings(prefs);
  }

  Future<UserSettings> _loadSettings(SharedPreferences prefs) async {
    try {
      final saved = prefs.getString(_storageKey);
      if (saved != null) {
        final json = jsonDecode(saved) as Map<String, dynamic>;
        return UserSettings.fromJson(json);
      }
    } catch (e) {
      print('설정 로드 중 오류 발생: $e');
    }
    return UserSettings.defaultSettings();
  }

  Future<void> saveSettings(UserSettings newSettings) async {
    state = const AsyncValue.loading();
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString(_storageKey, jsonEncode(newSettings.toJson()));
      state = AsyncValue.data(newSettings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> updatePersonalGoal(String goal) async {
    final current = state.value;
    if (current == null) return;

    state = const AsyncValue.loading();
    try {
      final newSettings = current.copyWith(personalGoal: goal);
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString(_storageKey, jsonEncode(newSettings.toJson()));
      state = AsyncValue.data(newSettings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

/// AsyncNotifier 버전의 Provider (권장)
final userSettingsAsyncProvider = AsyncNotifierProvider<UserSettingsAsyncNotifier, UserSettings>(() {
  return UserSettingsAsyncNotifier();
});

