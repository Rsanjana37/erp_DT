import 'package:erp_test_ui/screens/login_screen.dart';
import 'package:erp_test_ui/screens/my_home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:erp_test_ui/const.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

Future<void> main() async {
  Gemini.init(apiKey: geminiAPIkey);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "erpproject",
    options: const FirebaseOptions(
      apiKey: "AIzaSyDvgKDgqdFlhE0rfFzj_hU2gBVOVxMR1gks",
      appId: "1:746645782715:android:0313eea80c2f298758e99e",
      messagingSenderId: "746645782715",
      projectId: "erp-project-98a7c",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 178, 163, 248),
          brightness: Brightness.light,
        ).copyWith(
          // ignore: deprecated_member_use
          background: Colors.white,
          surface: const Color.fromARGB(255, 255, 251, 251),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 1, 42, 75),
          brightness: Brightness.dark,
        ).copyWith(
          background: Colors.grey[900],
          surface: const Color.fromARGB(255, 22, 40, 65),
        ),
      ),
      themeMode:
          ThemeMode.system, // This will respect the system's theme setting
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return const LoginPage();
          }
          return const MyHome(); // Redirect to home page if logged in
        }

        return const Center(child: Text('Something went wrong!'));
      },
    );
  }
}
