/// Riverpod 사용 예제
/// 
/// 이 파일은 참고용 예제입니다. 실제 앱에서는 필요에 따라 수정하여 사용하세요.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_settings_provider.dart';
import '../models/user_settings.dart';

/// Riverpod을 사용한 메인 앱 예제
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // UserSettings를 비동기로 로드
    final settingsAsync = ref.watch(userSettingsAsyncProvider);

    return MaterialApp(
      title: '금연 앱',
      home: settingsAsync.when(
        data: (settings) {
          // 설정이 없으면 설정 화면 표시
          if (settings.startDate == null) {
            return SettingsScreen();
          }
          // 설정이 있으면 대시보드 표시
          return DashboardScreen(settings: settings);
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stackTrace) => Scaffold(
          body: Center(
            child: Text('오류 발생: $error'),
          ),
        ),
      ),
    );
  }
}

/// 설정 화면 예제
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nicknameController = TextEditingController();
  final _cigarettesController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    _cigarettesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final currentSettings = ref.read(userSettingsAsyncProvider).value;
    if (currentSettings == null) return;

    final newSettings = currentSettings.copyWith(
      nickname: _nicknameController.text,
      cigarettesPerDay: int.tryParse(_cigarettesController.text) ?? 20,
      pricePerPack: int.tryParse(_priceController.text) ?? 4500,
      startDate: DateTime.now().toIso8601String().split('T')[0], // YYYY-MM-DD 형식
    );

    await ref.read(userSettingsAsyncProvider.notifier).saveSettings(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(labelText: '닉네임'),
            ),
            TextField(
              controller: _cigarettesController,
              decoration: const InputDecoration(labelText: '하루 평균 담배 개비수'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: '담배 한 갑 가격 (원)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 대시보드 화면 예제
class DashboardScreen extends ConsumerWidget {
  final UserSettings settings;

  const DashboardScreen({super.key, required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('대시보드')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('닉네임: ${settings.nickname}'),
            Text('하루 평균: ${settings.cigarettesPerDay}개비'),
            Text('한 갑 가격: ${settings.pricePerPack}원'),
            Text('시작일: ${settings.startDate ?? "미설정"}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // 개인 목표 업데이트 예제
                await ref
                    .read(userSettingsAsyncProvider.notifier)
                    .updatePersonalGoal('제주도 여행');
              },
              child: const Text('개인 목표 업데이트'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Provider 패턴 사용 예제 (참고용)
/*
import 'package:provider/provider.dart';
import '../providers/user_settings_provider_legacy.dart';

class MyAppWithProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserSettingsProvider()..initialize(),
      child: MaterialApp(
        title: '금연 앱',
        home: Consumer<UserSettingsProvider>(
          builder: (context, provider, child) {
            if (!provider.isInitialized) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final settings = provider.settings;
            if (settings.startDate == null) {
              return SettingsScreen();
            }
            return DashboardScreen(settings: settings);
          },
        ),
      ),
    );
  }
}
*/

