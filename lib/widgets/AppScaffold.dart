import 'package:flutter/material.dart';
import '../controllers/state.dart';
import 'app_header.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final double headerHeight;
  final VoidCallback? onBack;
  final VoidCallback? onLogout;
  final bool showLogo;
  final String? bottomText;
final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.headerHeight = 200,
    this.onBack,
    this.onLogout,
    this.showLogo = false,
    this.bottomText,
     this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoggedIn,
      builder: (context, logged, _) {
      if (logged) {
  return Container(
    color: Colors.white,
    child: Stack(
      children: [
        Column(
          children: [
            if (title != null)
              AppHeader(
                title: title!,
                subtitle: subtitle,
                height: headerHeight,
                onBack: onBack,
                onLogout: onLogout,
                showLogo: showLogo,
                bottomText: bottomText,
              ),
            Expanded(child: child),
          ],
        ),

        if (floatingActionButton != null)
          Positioned(
            right: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            child: floatingActionButton!,
          ),
      ],
    ),
  );
}
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
