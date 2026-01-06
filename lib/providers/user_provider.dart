import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import '../models/user_settings.dart';

/// UserProvider - ChangeNotifier를 상속받은 상태 관리 클래스
/// React의 App.tsx의 useState, useEffect 로직을 Flutter로 변환
/// Firestore를 사용한 실시간 데이터 동기화
class UserProvider extends ChangeNotifier {
  static const String _collectionName = 'users';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  
  StreamSubscription<DocumentSnapshot>? _settingsSubscription;
  StreamSubscription<User?>? _authStateSubscription;

  UserSettings _settings = UserSettings.defaultSettings();
  bool _isInitialized = false;
  bool _showSettings = false;

  UserSettings get settings => _settings;
  bool get isInitialized => _isInitialized;
  bool get showSettings => _showSettings;
  User? get currentUser => _auth.currentUser;

  /// 현재 사용자의 문서 ID 가져오기
  String? get _documentId => _auth.currentUser?.uid;

  /// 초기화 메서드 (React의 useEffect 로직)
  /// 앱 시작 시 호출해야 함
  /// Firestore의 실시간 스트림을 구독하여 데이터 변경을 감지
  /// 로그인 상태 변경도 감지
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 로그인 상태 변경 감지
      _authStateSubscription = _auth.authStateChanges().listen((User? user) {
        if (user == null) {
          // 로그아웃 시 설정 초기화
          _settings = UserSettings.defaultSettings();
          _showSettings = false;
          _settingsSubscription?.cancel();
          _settingsSubscription = null;
          notifyListeners();
        } else {
          // 로그인 시 해당 사용자의 설정 로드
          _loadUserSettings(user.uid);
        }
      });

      // 현재 로그인된 사용자가 있으면 설정 로드
      if (_auth.currentUser != null) {
        _loadUserSettings(_auth.currentUser!.uid);
      } else {
        _isInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('초기화 중 오류 발생: $e');
      _isInitialized = true;
      _showSettings = true;
      notifyListeners();
    }
  }

  /// 사용자 설정 로드 (Firestore 실시간 스트림 구독)
  void _loadUserSettings(String userId) {
    // 기존 구독 취소
    _settingsSubscription?.cancel();

    // 새로운 사용자의 설정 구독
    _settingsSubscription = _firestore
        .collection(_collectionName)
        .doc(userId)
        .snapshots()
        .listen(
      (DocumentSnapshot snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          try {
            final data = snapshot.data() as Map<String, dynamic>;
            _settings = UserSettings.fromJson(data);
            
            // startDate가 없으면 설정 화면 표시
            if (_settings.startDate == null) {
              _showSettings = true;
            } else {
              _showSettings = false;
            }
            
            _isInitialized = true;
            notifyListeners();
          } catch (e) {
            debugPrint('설정 파싱 중 오류 발생: $e');
          }
        } else {
          // 문서가 없으면 기본값 사용 및 설정 화면 표시
          _settings = UserSettings.defaultSettings();
          _showSettings = true;
          _isInitialized = true;
          notifyListeners();
        }
      },
      onError: (error) {
        debugPrint('Firestore 스트림 오류: $error');
        _isInitialized = true;
        _showSettings = true;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    _authStateSubscription?.cancel();
    super.dispose();
  }

  /// 구글 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 구글 로그인 플로우 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // 사용자가 로그인 취소
        return null;
      }

      // 구글 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Firebase 인증을 위한 credential 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 로그인
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // 로그인 성공 시 해당 사용자의 설정 자동 로드됨 (authStateChanges 리스너가 처리)
      
      return userCredential;
    } catch (e) {
      debugPrint('구글 로그인 중 오류 발생: $e');
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      // authStateChanges 리스너가 자동으로 설정 초기화 처리
    } catch (e) {
      debugPrint('로그아웃 중 오류 발생: $e');
      rethrow;
    }
  }

  /// 설정 저장 (React의 saveSettings 함수)
  /// Firestore에 저장하면 실시간 스트림이 자동으로 업데이트됨
  Future<void> saveSettings(UserSettings newSettings) async {
    try {
      final userId = _documentId;
      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .set(newSettings.toMap(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));
      
      // 스트림이 자동으로 업데이트하므로 여기서는 _showSettings만 변경
      _showSettings = false; // 설정 저장 후 설정 화면 닫기
      notifyListeners();
    } catch (e) {
      debugPrint('설정 저장 중 오류 발생: $e');
      rethrow;
    }
  }

  /// 개인 목표 업데이트 (React의 updatePersonalGoal 함수)
  Future<void> updatePersonalGoal(String goal) async {
    try {
      final userId = _documentId;
      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .update({'personalGoal': goal});
      
      // 스트림이 자동으로 업데이트하므로 notifyListeners는 필요 없지만
      // 즉시 반영을 위해 호출
      notifyListeners();
    } catch (e) {
      debugPrint('개인 목표 업데이트 중 오류 발생: $e');
      rethrow;
    }
  }

  /// 설정 화면 열기
  void openSettings() {
    _showSettings = true;
    notifyListeners();
  }

  /// 설정 화면 닫기
  void closeSettings() {
    _showSettings = false;
    notifyListeners();
  }

  /// 특정 필드 업데이트 헬퍼 메서드
  Future<void> updateField({
    String? startDate,
    int? cigarettesPerDay,
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
      final userId = _documentId;
      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      final updatedSettings = _settings.copyWith(
        startDate: startDate,
        cigarettesPerDay: cigarettesPerDay,
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

      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .set(updatedSettings.toMap(), SetOptions(merge: true));
      
      // 스트림이 자동으로 업데이트함
      notifyListeners();
    } catch (e) {
      debugPrint('필드 업데이트 중 오류 발생: $e');
      rethrow;
    }
  }

  /// 설정 초기화 (디버깅용)
  Future<void> resetSettings() async {
    try {
      final userId = _documentId;
      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .delete();
      
      _settings = UserSettings.defaultSettings();
      _showSettings = true;
      notifyListeners();
    } catch (e) {
      debugPrint('설정 초기화 중 오류 발생: $e');
      rethrow;
    }
  }
}

