# 금연 앱 - Flutter 상태 관리

React 코드에서 Flutter로 변환된 상태 관리 시스템입니다.

## 구조

### 모델
- `lib/models/user_settings.dart`: UserSettings 모델 클래스

### Provider (Riverpod - 권장)
- `lib/providers/user_settings_provider.dart`: Riverpod을 사용한 상태 관리

### Provider (Legacy - 선택사항)
- `lib/providers/user_settings_provider_legacy.dart`: Provider 패턴을 사용한 상태 관리

### 위젯
- `lib/widgets/profile_card.dart`: ProfileCard 위젯 (RPG 스타일 프로필 카드)
- `lib/widgets/dashboard.dart`: Dashboard 위젯 (대시보드 화면)

## 사용 방법

### Riverpod 사용 (권장)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quit_smoke/providers/user_settings_provider.dart';

// 위젯을 ConsumerWidget으로 변경
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(userSettingsAsyncProvider);
    
    return settingsAsync.when(
      data: (settings) => YourWidget(settings: settings),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}

// 설정 저장
ref.read(userSettingsAsyncProvider.notifier).saveSettings(newSettings);

// 개인 목표 업데이트
ref.read(userSettingsAsyncProvider.notifier).updatePersonalGoal('새 목표');
```

### Provider 패턴 사용

```dart
import 'package:provider/provider.dart';
import 'package:quit_smoke/providers/user_settings_provider_legacy.dart';

// main.dart에서 Provider 등록
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserSettingsProvider()..initialize(),
      child: MyApp(),
    ),
  );
}

// 위젯에서 사용
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserSettingsProvider>(context);
    final settings = provider.settings;
    
    return Text(settings.nickname);
  }
}
```

## React 코드와의 매핑

| React | Flutter (Riverpod) | Flutter (Provider) |
|-------|-------------------|-------------------|
| `useState` | `StateNotifier` / `AsyncNotifier` | `ChangeNotifier` |
| `useEffect` | `build()` 메서드 | `initialize()` 메서드 |
| `localStorage` | `shared_preferences` | `shared_preferences` |
| `setSettings` | `state = newValue` | `_settings = newValue; notifyListeners()` |

## 위젯 사용 방법

### Dashboard와 ProfileCard 사용

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quit_smoke/widgets/dashboard.dart';
import 'package:quit_smoke/providers/user_settings_provider.dart';

class MyDashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(userSettingsAsyncProvider);
    
    return settingsAsync.when(
      data: (settings) => Container(
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Dashboard(
              settings: settings,
              onOpenSettings: () {
                // 설정 화면으로 이동
              },
              onUpdatePersonalGoal: (goal) async {
                await ref
                    .read(userSettingsAsyncProvider.notifier)
                    .updatePersonalGoal(goal);
              },
            ),
          ),
        ),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

## React 스타일 → Flutter 변환

### Tailwind CSS → Flutter

| Tailwind CSS | Flutter |
|--------------|---------|
| `bg-gradient-to-br from-emerald-500 to-teal-500` | `BoxDecoration` with `LinearGradient` |
| `rounded-3xl` | `BorderRadius.circular(24)` |
| `shadow-xl` | `BoxShadow` with `blurRadius: 25` |
| `p-6` | `padding: EdgeInsets.all(24)` |
| `bg-white/20` | `Colors.white.withOpacity(0.2)` |
| `backdrop-blur-sm` | `BackdropFilter` with `ImageFilter.blur` |

### 아이콘

- React의 `lucide-react` → Flutter의 `lucide_flutter`
- 모든 아이콘은 `LucideIcons` 클래스를 통해 접근

## 설치 방법

1. 의존성 설치:
```bash
flutter pub get
```

2. Riverpod 사용 시 `main.dart`에서 ProviderScope로 앱 감싸기:
```dart
void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

## 주요 기능

1. **설정 저장/로드**: SharedPreferences를 사용한 영구 저장
2. **개인 목표 업데이트**: `updatePersonalGoal()` 메서드
3. **전체 설정 저장**: `saveSettings()` 메서드
4. **부분 업데이트**: `updateField()` 메서드
5. **ProfileCard**: 그라데이션 배경과 경험치 바가 있는 RPG 스타일 프로필 카드
6. **Dashboard**: 절약한 시간, 목표 아이템, 개인 목표를 표시하는 대시보드

