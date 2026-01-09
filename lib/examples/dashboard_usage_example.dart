/// Dashboard와 ProfileCard 사용 예제
/// 
/// 이 파일은 참고용 예제입니다. 실제 앱에서는 필요에 따라 수정하여 사용하세요.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/dashboard.dart';
import '../providers/user_settings_provider.dart';

/// Dashboard를 사용하는 메인 화면 예제
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(userSettingsAsyncProvider);

    return Scaffold(
      // 배경 그라데이션 (React의 bg-gradient-to-br from-green-50 via-emerald-50 to-teal-50)
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
        child: settingsAsync.when(
          data: (settings) {
            if (settings.startDate == null) {
              // 설정이 없으면 설정 화면으로 이동
              return const Center(
                child: Text('설정을 먼저 완료해주세요'),
              );
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Dashboard(
                  settings: settings,
                  onOpenSettings: () {
                    // 설정 화면으로 이동하는 로직
                    // Navigator.push(...)
                  },
                  onUpdatePersonalGoal: (goal) async {
                    await ref
                        .read(userSettingsAsyncProvider.notifier)
                        .updatePersonalGoal(goal);
                  },
                ),
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: Text('오류 발생: $error'),
          ),
        ),
      ),
    );
  }
}

