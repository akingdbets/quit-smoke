import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_settings.dart';

/// UserSettings 상태 관리 클래스 (Provider 패턴)
/// 
/// React의 App.tsx에 있는 상태 관리 로직을 Flutter Provider로 변환:
/// - useState -> ChangeNotifier
/// - useEffect -> 초기화 메서드
/// - localStorage -> shared_preferences
class UserSettingsProvider extends ChangeNotifier {
  static const String _storageKey = 'quitSmokingSettings';
  
  UserSettings _settings = UserSettings.defaultSettings();
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  UserSettings get settings => _settings;
  bool get isInitialized => _isInitialized;

  /// 초기화 메서드 (React의 useEffect 로직)
  /// 앱 시작 시 호출해야 함
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadSettings();
      _isInitialized = true;
    } catch (e) {
      print('초기화 중 오류 발생: $e');
      _isInitialized = true; // 에러가 나도 초기화 완료로 표시
    }
  }

  /// localStorage에서 설정 로드 (React의 useEffect 로직)
  Future<void> _loadSettings() async {
    try {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }
      
      final saved = _prefs!.getString(_storageKey);
      if (saved != null) {
        final json = jsonDecode(saved) as Map<String, dynamic>;
        _settings = UserSettings.fromJson(json);
        notifyListeners();
      }
    } catch (e) {
      // 에러 발생 시 기본값 유지
      print('설정 로드 중 오류 발생: $e');
    }
  }

  /// 설정 저장 (React의 saveSettings 함수)
  Future<void> saveSettings(UserSettings newSettings) async {
    try {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }
      
      _settings = newSettings;
      await _prefs!.setString(_storageKey, jsonEncode(newSettings.toJson()));
      notifyListeners();
    } catch (e) {
      print('설정 저장 중 오류 발생: $e');
      rethrow;
    }
  }

  /// 개인 목표 업데이트 (React의 updatePersonalGoal 함수)
  Future<void> updatePersonalGoal(String goal) async {
    try {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }
      
      _settings = _settings.copyWith(personalGoal: goal);
      await _prefs!.setString(_storageKey, jsonEncode(_settings.toJson()));
      notifyListeners();
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
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }
      
      _settings = _settings.copyWith(
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
      
      await _prefs!.setString(_storageKey, jsonEncode(_settings.toJson()));
      notifyListeners();
    } catch (e) {
      print('필드 업데이트 중 오류 발생: $e');
      rethrow;
    }
  }

  /// 설정 초기화 (디버깅용)
  Future<void> resetSettings() async {
    _settings = UserSettings.defaultSettings();
    if (_prefs != null) {
      await _prefs!.remove(_storageKey);
    }
    notifyListeners();
  }
}

