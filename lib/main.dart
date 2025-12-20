import 'package:flutter/material.dart';
import 'screens/welcome_page.dart';
import 'controllers/state.dart';

void main() {
  runApp(const MindAcademyApp());
}

class MindAcademyApp extends StatelessWidget {
  const MindAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoggedIn,
      builder: (context, logged, _) {
        return MaterialApp(
          title: 'MindAcademy',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF667eea),
            fontFamily: 'Roboto',
          ),
          builder: (context, child) {
            return Scaffold(
              
              backgroundColor: Colors.transparent,
              body: child ?? const SizedBox.shrink(),
            );
          },
          home: const WelcomePage(),
        );
      },
    );
  }
}
