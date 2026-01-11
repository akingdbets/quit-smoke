import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/social_provider.dart';
import '../widgets/real_time_ticker.dart';

/// Social Screen - 소셜/랭킹 기능 화면
class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4), // green-50
      appBar: AppBar(
        title: const Text(
          '커뮤니티',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937), // gray-800
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF10B981), // emerald-600
          unselectedLabelColor: const Color(0xFF6B7280), // gray-500
          indicatorColor: const Color(0xFF10B981),
          tabs: const [
            Tab(
              icon: Icon(LucideIcons.trophy),
              text: '명예의 전당',
            ),
            Tab(
              icon: Icon(LucideIcons.users),
              text: '내 친구',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          GlobalRankingsTab(),
          FollowingUsersTab(),
        ],
      ),
    );
  }
}

/// 전체 랭킹 탭
class GlobalRankingsTab extends StatefulWidget {
  const GlobalRankingsTab({super.key});

  @override
  State<GlobalRankingsTab> createState() => _GlobalRankingsTabState();
}

class _GlobalRankingsTabState extends State<GlobalRankingsTab> {
  String? _lastNickname;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRankings();
      // 현재 닉네임 저장
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _lastNickname = userProvider.settings.nickname;
    });
  }

  Future<void> _loadRankings() async {
    final socialProvider = Provider.of<SocialProvider>(context, listen: false);
    try {
      await socialProvider.fetchGlobalRankings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('랭킹을 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SocialProvider, UserProvider>(
      builder: (context, socialProvider, userProvider, child) {
        // 닉네임이 변경되었는지 확인
        final currentNickname = userProvider.settings.nickname;
        if (_lastNickname != null && _lastNickname != currentNickname) {
          _lastNickname = currentNickname;
          // 닉네임이 변경되었으면 데이터 새로고침
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _loadRankings();
            }
          });
        } else if (_lastNickname == null) {
          _lastNickname = currentNickname;
        }

        if (socialProvider.isLoadingRankings) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF10B981), // emerald-600
            ),
          );
        }

        if (socialProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(height: 16),
                Text(
                  socialProvider.error!,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadRankings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                  ),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }

        final rankings = socialProvider.globalRankings;

        if (rankings.isEmpty) {
          return const Center(
            child: Text(
              '랭킹 데이터가 없습니다',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadRankings,
          color: const Color(0xFF10B981),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rankings.length,
            itemBuilder: (context, index) {
              final rank = index + 1;
              final userData = rankings[index];
              return _buildRankingCard(userData, rank);
            },
          ),
        );
      },
    );
  }

  Widget _buildRankingCard(Map<String, dynamic> userData, int rank) {
    final startDateStr = userData['startDate'] as String?;
    if (startDateStr == null) return const SizedBox.shrink();

    final startDate = DateTime.parse(startDateStr);
    final now = DateTime.now();
    final daysSinceQuit = now.difference(startDate).inDays;

    final nickname = userData['nickname'] as String? ?? '익명';
    final currentTitle = _getCurrentTitle(daysSinceQuit);
    final emoji = currentTitle['emoji'] as String;

    final isTopThree = rank <= 3;

    return Container(
      margin: EdgeInsets.only(bottom: rank == 3 ? 0 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTopThree
              ? const Color(0xFF10B981) // emerald-600
              : const Color(0xFFE5E7EB), // gray-200
          width: isTopThree ? 2 : 1,
        ),
        boxShadow: isTopThree
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ListTile(
        leading: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isTopThree
                      ? [
                          const Color(0xFFFCD34D), // amber-300
                          const Color(0xFFFBBF24), // amber-400
                        ]
                      : [
                          const Color(0xFFE5E7EB), // gray-200
                          const Color(0xFFD1D5DB), // gray-300
                        ],
                ),
                shape: BoxShape.circle,
              ),
              child: isTopThree
                  ? const Icon(
                      LucideIcons.crown,
                      color: Color(0xFF92400E), // amber-800
                      size: 24,
                    )
                  : Center(
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isTopThree
                              ? const Color(0xFF92400E)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
            ),
          ],
        ),
        title: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                nickname,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isTopThree
                      ? const Color(0xFF10B981)
                      : const Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: RealTimeDurationTicker(
            startDate: startDate,
            style: TextStyle(
              fontSize: 14,
              color: isTopThree
                  ? const Color(0xFF059669) // emerald-700
                  : const Color(0xFF6B7280),
              fontWeight: isTopThree ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        trailing: isTopThree
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5), // emerald-50
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${rank}위',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Map<String, dynamic> _getCurrentTitle(int daysSinceQuit) {
    const titles = <Map<String, dynamic>>[
      {'days': 1, 'name': '첫걸음', 'emoji': '🌱'},
      {'days': 3, 'name': '도전자', 'emoji': '💪'},
      {'days': 7, 'name': '일주일 전사', 'emoji': '⭐'},
      {'days': 14, 'name': '2주 생존자', 'emoji': '🔥'},
      {'days': 30, 'name': '한달 정복자', 'emoji': '🏆'},
      {'days': 60, 'name': '두달 챔피언', 'emoji': '👑'},
      {'days': 90, 'name': '분기 마스터', 'emoji': '💎'},
      {'days': 180, 'name': '반년 영웅', 'emoji': '🦸'},
      {'days': 365, 'name': '1년 레전드', 'emoji': '🌟'},
      {'days': 730, 'name': '2년 신화', 'emoji': '🔱'},
    ];

    for (int i = titles.length - 1; i >= 0; i--) {
      final titleDays = titles[i]['days'] as int;
      if (daysSinceQuit >= titleDays) {
        return titles[i];
      }
    }
    return {'days': 0, 'name': '초보자', 'emoji': '🥚'};
  }
}

/// 내 친구 탭
class FollowingUsersTab extends StatefulWidget {
  const FollowingUsersTab({super.key});

  @override
  State<FollowingUsersTab> createState() => _FollowingUsersTabState();
}

class _FollowingUsersTabState extends State<FollowingUsersTab> {
  String? _lastNickname;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFollowing();
      // 현재 닉네임 저장
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _lastNickname = userProvider.settings.nickname;
    });
  }

  Future<void> _loadFollowing() async {
    final socialProvider = Provider.of<SocialProvider>(context, listen: false);
    try {
      await socialProvider.getFollowingUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('팔로우 중인 유저를 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _showSearchDialog() async {
    final nicknameController = TextEditingController();
    final socialProvider = Provider.of<SocialProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final result = await showDialog<List<Map<String, dynamic>>>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              bool isSearching = false;

              return Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 타이틀 영역
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.search,
                            size: 24,
                            color: Color(0xFF10B981), // emerald-600
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '친구 찾기',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937), // gray-800
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 검색 입력창
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6), // gray-100
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: nicknameController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: '닉네임을 입력해주세요',
                            hintStyle: TextStyle(
                              color: Color(0xFF9CA3AF), // gray-400
                            ),
                            prefixIcon: Icon(
                              LucideIcons.search,
                              color: Color(0xFF6B7280), // gray-500
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          onSubmitted: (value) async {
                            final nickname = value.trim();
                            if (nickname.isEmpty) return;
                            if (isSearching) return;

                            setDialogState(() {
                              isSearching = true;
                            });

                            try {
                              final results = await socialProvider.searchUserByNickname(nickname);
                              if (context.mounted) {
                                Navigator.pop(context, results);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                setDialogState(() {
                                  isSearching = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('검색 중 오류가 발생했습니다: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 버튼 영역
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: isSearching
                                  ? null
                                  : () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                '취소',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF6B7280), // gray-500
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: isSearching
                                  ? null
                                  : () async {
                                      final nickname = nicknameController.text.trim();
                                      if (nickname.isEmpty) return;

                                      setDialogState(() {
                                        isSearching = true;
                                      });

                                      try {
                                        final results = await socialProvider.searchUserByNickname(nickname);
                                        if (context.mounted) {
                                          Navigator.pop(context, results);
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          setDialogState(() {
                                            isSearching = false;
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('검색 중 오류가 발생했습니다: $e')),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981), // emerald-600
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: isSearching
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      '검색',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
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
            },
          ),
        );
      },
    );

    if (result != null && result.isNotEmpty && mounted) {
      await _showUserListDialog(result, socialProvider, userProvider);
    } else if (result != null && result.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('검색 결과가 없습니다')),
      );
    }
  }

  Future<void> _showUserListDialog(
    List<Map<String, dynamic>> users,
    SocialProvider socialProvider,
    UserProvider userProvider,
  ) async {
    final currentUserId = userProvider.currentUser?.uid;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('검색 결과'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final uid = user['uid'] as String?;
              final nickname = user['nickname'] as String? ?? '익명';

              if (uid == currentUserId) {
                return ListTile(
                  title: Text('$nickname (나)'),
                  enabled: false,
                );
              }

              final isFollowing = userProvider.settings.following.contains(uid);

              return ListTile(
                title: Text(nickname),
                trailing: isFollowing
                    ? TextButton(
                        onPressed: () async {
                          try {
                            await socialProvider.unfollowUser(uid!, userProvider);
                            if (context.mounted) {
                              Navigator.pop(context);
                              _loadFollowing();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('언팔로우했습니다')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('오류가 발생했습니다: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('언팔로우'),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          try {
                            await socialProvider.followUser(uid!, userProvider);
                            if (context.mounted) {
                              Navigator.pop(context);
                              _loadFollowing();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('팔로우했습니다')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('오류가 발생했습니다: $e')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                        ),
                        child: const Text('팔로우'),
                      ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showSearchDialog,
        backgroundColor: const Color(0xFF10B981), // emerald-600
        child: const Icon(LucideIcons.userPlus, color: Colors.white),
      ),
      body: Consumer2<SocialProvider, UserProvider>(
        builder: (context, socialProvider, userProvider, child) {
          // 닉네임이 변경되었는지 확인
          final currentNickname = userProvider.settings.nickname;
          if (_lastNickname != null && _lastNickname != currentNickname) {
            _lastNickname = currentNickname;
            // 닉네임이 변경되었으면 데이터 새로고침
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _loadFollowing();
              }
            });
          } else if (_lastNickname == null) {
            _lastNickname = currentNickname;
          }

          if (socialProvider.isLoadingFollowing) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF10B981),
              ),
            );
          }

          if (socialProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    socialProvider.error!,
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadFollowing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final followingUsers = socialProvider.followingUsers;

          if (followingUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.users,
                    size: 64,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '아직 팔로우한 친구가 없습니다',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _showSearchDialog,
                    child: const Text('친구 찾기'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadFollowing,
            color: const Color(0xFF10B981),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: followingUsers.length,
              itemBuilder: (context, index) {
                final userData = followingUsers[index];
                return _buildFollowingCard(userData, socialProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFollowingCard(
      Map<String, dynamic> userData, SocialProvider socialProvider) {
    final startDateStr = userData['startDate'] as String?;
    if (startDateStr == null) return const SizedBox.shrink();

    final startDate = DateTime.parse(startDateStr);
    final now = DateTime.now();
    final daysSinceQuit = now.difference(startDate).inDays;

    final nickname = userData['nickname'] as String? ?? '익명';
    final currentTitle = _getCurrentTitle(daysSinceQuit);
    final emoji = currentTitle['emoji'] as String;
    final uid = userData['uid'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF10B981), // emerald-500
                Color(0xFF14B8A6), // teal-500
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        title: Text(
          nickname,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5), // emerald-50
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${currentTitle['name']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 열품타 스타일 실시간 시간 표시
              RealTimeDurationTicker(
                startDate: startDate,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF059669), // emerald-700
                ),
              ),
            ],
          ),
        ),
        trailing: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final isFollowing = uid != null &&
                userProvider.settings.following.contains(uid);

            return IconButton(
              icon: Icon(
                isFollowing ? LucideIcons.userMinus : LucideIcons.userPlus,
                color: const Color(0xFF10B981),
              ),
              onPressed: () async {
                if (uid == null) return;

                try {
                  if (isFollowing) {
                    await socialProvider.unfollowUser(uid, userProvider);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('언팔로우했습니다')),
                      );
                      _loadFollowing();
                    }
                  } else {
                    await socialProvider.followUser(uid, userProvider);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('팔로우했습니다')),
                      );
                      _loadFollowing();
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('오류가 발생했습니다: $e')),
                    );
                  }
                }
              },
            );
          },
        ),
      ),
    );
  }


  Map<String, dynamic> _getCurrentTitle(int daysSinceQuit) {
    const titles = <Map<String, dynamic>>[
      {'days': 1, 'name': '첫걸음', 'emoji': '🌱'},
      {'days': 3, 'name': '도전자', 'emoji': '💪'},
      {'days': 7, 'name': '일주일 전사', 'emoji': '⭐'},
      {'days': 14, 'name': '2주 생존자', 'emoji': '🔥'},
      {'days': 30, 'name': '한달 정복자', 'emoji': '🏆'},
      {'days': 60, 'name': '두달 챔피언', 'emoji': '👑'},
      {'days': 90, 'name': '분기 마스터', 'emoji': '💎'},
      {'days': 180, 'name': '반년 영웅', 'emoji': '🦸'},
      {'days': 365, 'name': '1년 레전드', 'emoji': '🌟'},
      {'days': 730, 'name': '2년 신화', 'emoji': '🔱'},
    ];

    for (int i = titles.length - 1; i >= 0; i--) {
      final titleDays = titles[i]['days'] as int;
      if (daysSinceQuit >= titleDays) {
        return titles[i];
      }
    }
    return {'days': 0, 'name': '초보자', 'emoji': '🥚'};
  }
}

