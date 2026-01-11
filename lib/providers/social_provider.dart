import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_provider.dart';

/// SocialProvider - 소셜/랭킹 기능을 위한 상태 관리 클래스
class SocialProvider extends ChangeNotifier {
  static const String _collectionName = 'users';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _globalRankings = [];
  List<Map<String, dynamic>> _followingUsers = [];
  bool _isLoadingRankings = false;
  bool _isLoadingFollowing = false;
  String? _error;

  List<Map<String, dynamic>> get globalRankings => _globalRankings;
  List<Map<String, dynamic>> get followingUsers => _followingUsers;
  bool get isLoadingRankings => _isLoadingRankings;
  bool get isLoadingFollowing => _isLoadingFollowing;
  String? get error => _error;

  /// 전체 랭킹 조회 (startDate가 빠른 순서대로 상위 50명)
  Future<void> fetchGlobalRankings() async {
    try {
      _isLoadingRankings = true;
      _error = null;
      notifyListeners();

      // 인덱스 없이 작동하도록 orderBy만 사용하고 클라이언트에서 필터링
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('startDate', descending: false)
          .limit(300) // 더 많이 가져온 후 클라이언트에서 필터링
          .get();

      // isPublic이 true이고 startDate가 null이 아닌 문서만 필터링
      final rankings = querySnapshot.docs
          .where((doc) {
            final data = doc.data();
            final isPublic = data['isPublic'] as bool? ?? true; // 기본값 true
            final startDate = data['startDate'];
            return isPublic && 
                   startDate != null && 
                   startDate.toString().isNotEmpty;
          })
          .map((doc) {
            final data = doc.data();
            return {
              'uid': doc.id,
              ...data,
            };
          })
          .toList();

      // startDate로 정렬 (이중 보장)
      rankings.sort((a, b) {
        final aDate = a['startDate'] as String? ?? '';
        final bDate = b['startDate'] as String? ?? '';
        return aDate.compareTo(bDate);
      });

      _globalRankings = rankings.take(50).toList();

      _isLoadingRankings = false;
      notifyListeners();
    } catch (e) {
      debugPrint('랭킹 조회 중 오류 발생: $e');
      _error = '랭킹을 불러오는데 실패했습니다';
      _isLoadingRankings = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 닉네임으로 유저 검색
  Future<List<Map<String, dynamic>>> searchUserByNickname(String nickname) async {
    try {
      if (nickname.trim().isEmpty) {
        return [];
      }

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('nickname', isEqualTo: nickname.trim())
          .limit(10)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      debugPrint('유저 검색 중 오류 발생: $e');
      rethrow;
    }
  }

  /// 유저 팔로우
  Future<void> followUser(String targetUid, UserProvider userProvider) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('로그인이 필요합니다');
      }

      if (currentUserId == targetUid) {
        throw Exception('본인은 팔로우할 수 없습니다');
      }

      final currentSettings = userProvider.settings;
      final currentFollowing = List<String>.from(currentSettings.following);

      if (currentFollowing.contains(targetUid)) {
        // 이미 팔로우 중
        return;
      }

      currentFollowing.add(targetUid);

      // Firestore에 직접 업데이트 (스트림이 자동으로 UserProvider를 업데이트함)
      await _firestore
          .collection(_collectionName)
          .doc(currentUserId)
          .update({'following': currentFollowing})
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('팔로우 중 오류 발생: $e');
      rethrow;
    }
  }

  /// 유저 언팔로우
  Future<void> unfollowUser(String targetUid, UserProvider userProvider) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('로그인이 필요합니다');
      }

      final currentSettings = userProvider.settings;
      final currentFollowing = List<String>.from(currentSettings.following);

      if (!currentFollowing.contains(targetUid)) {
        // 팔로우하지 않은 유저
        return;
      }

      currentFollowing.remove(targetUid);

      // Firestore에 직접 업데이트 (스트림이 자동으로 UserProvider를 업데이트함)
      await _firestore
          .collection(_collectionName)
          .doc(currentUserId)
          .update({'following': currentFollowing})
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('언팔로우 중 오류 발생: $e');
      rethrow;
    }
  }

  /// 팔로우 중인 유저들 정보 가져오기
  Future<void> getFollowingUsers() async {
    try {
      _isLoadingFollowing = true;
      _error = null;
      notifyListeners();

      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('로그인이 필요합니다');
      }

      final userDoc = await _firestore
          .collection(_collectionName)
          .doc(currentUserId)
          .get();

      if (!userDoc.exists) {
        _followingUsers = [];
        _isLoadingFollowing = false;
        notifyListeners();
        return;
      }

      final data = userDoc.data() as Map<String, dynamic>;
      final following = (data['following'] as List<dynamic>?)?.cast<String>() ?? [];

      if (following.isEmpty) {
        _followingUsers = [];
        _isLoadingFollowing = false;
        notifyListeners();
        return;
      }

      // 여러 문서를 한번에 가져오기 (배치 쿼리)
      final userDocs = await Future.wait(
        following.map((uid) => _firestore.collection(_collectionName).doc(uid).get()),
      );

      _followingUsers = userDocs
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          ...data,
        };
      }).toList();

      _isLoadingFollowing = false;
      notifyListeners();
    } catch (e) {
      debugPrint('팔로우 유저 조회 중 오류 발생: $e');
      _error = '팔로우 중인 유저를 불러오는데 실패했습니다';
      _isLoadingFollowing = false;
      notifyListeners();
      rethrow;
    }
  }
}

