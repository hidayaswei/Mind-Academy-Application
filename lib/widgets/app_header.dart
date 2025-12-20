import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double height;
  final VoidCallback? onBack;
  final VoidCallback? onLogout;
  final bool showLogo;
  final String? bottomText;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.height = 200,
    this.onBack,
    this.onLogout,
    this.showLogo = false,
    this.bottomText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ],
                ),
                if (onBack != null || onLogout != null)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      onPressed: onBack ?? onLogout,
                      icon: Icon(
                        onBack != null
                            ? Icons.arrow_back_rounded
                            : Icons.logout_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            if (showLogo)
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Image.asset(
                    'images/app_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              )
            else if (bottomText != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  bottomText!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
