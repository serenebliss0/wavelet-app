import 'package:flutter/material.dart';
import 'package:Wavelet/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const WaveletApp());
}

class WaveletApp extends StatefulWidget {
  const WaveletApp({super.key});


  @override
  State<WaveletApp> createState() => _WaveletAppState();
}

class _WaveletAppState extends State<WaveletApp> {

 ThemeMode _themeMode = ThemeMode.system; // was ThemeMode.dark. now takes system default
  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme:      WaveletTheme.light,
      darkTheme:  WaveletTheme.dark,
      themeMode:  _themeMode,
      // home: SplashPage(toggleTheme: toggleTheme),
      home: AuthGate(toggleTheme: toggleTheme,),
      debugShowCheckedModeBanner: false,
    );
}
}
