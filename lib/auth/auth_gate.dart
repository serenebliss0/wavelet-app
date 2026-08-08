import 'package:Wavelet/pages/home_page.dart';
import 'package:Wavelet/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthGate extends StatelessWidget {
  final VoidCallback toggleTheme;

  const AuthGate({
    super.key,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // Firebase is still figuring out the authentication state.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // A user is logged in.
        if (snapshot.hasData) {
          return HomePage(
            toggleTheme: toggleTheme,
          );
        }

        // Nobody is logged in.
        return LoginPage(
          toggleTheme: toggleTheme,
        );
      },
    );
  }
}