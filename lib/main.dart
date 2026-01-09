import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider()..initialize(),
        ),
      ],
      child: MaterialApp(
        title: '금연 앱',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Pretendard 폰트 적용
          // Note: Pretendard는 Google Fonts에 없으므로 Noto Sans KR 사용
          // Pretendard를 사용하려면 assets/fonts 폴더에 폰트 파일을 추가하고
          // pubspec.yaml에 fonts 설정을 추가해야 합니다.
          textTheme: GoogleFonts.notoSansKrTextTheme(
            ThemeData.light().textTheme,
          ),
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF10B981), // emerald-500
            brightness: Brightness.light,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

/// 홈 화면 - 로그인 상태에 따라 화면 분기
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;

    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        // 연결 상태 확인 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 로그인 안 됨
        if (snapshot.data == null) {
          return const LoginScreen();
        }

        // 로그인 됨 - UserProvider의 상태에 따라 분기
        return Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            // 초기화 중이면 로딩 표시
            if (!userProvider.isInitialized) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // 설정이 없거나 설정 화면을 열어야 하면 설정 화면 표시
            if (userProvider.settings.startDate == null || userProvider.showSettings) {
              return const SettingsScreen();
            }

            // 설정이 있으면 메인 화면 표시
            return const MainScreen();
          },
        );
      },
    );
  }
}



