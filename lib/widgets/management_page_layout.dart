import 'package:flutter/material.dart';
import '../widgets/AppScaffold.dart';

class ManagementPageLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double headerHeight;
  final Widget child;
  final Widget? floatingActionButton;

  const ManagementPageLayout({
    super.key,
    required this.title,
    this.subtitle,
    this.headerHeight = 170,
    required this.child,
    this.floatingActionButton,
  });

  static void showError(BuildContext context, Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showInfo(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSuccess(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static Future<bool> confirmDelete(
    BuildContext context, {
    required String title,
    required String message,
    String cancelText = 'Cancel',
    String confirmText = 'Delete',
  }) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return res == true;
  }

  static Future<T?> showStyledDialog<T>(
    BuildContext context, {
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(24),
    double radius = 20,
  }) {
    return showDialog<T>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        child: Padding(padding: padding, child: child),
      ),
    );
  }

  static Widget dialogHeader({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Color(0xFF718096)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  static InputDecoration fieldDecoration({
    required String label,
    required IconData icon,
    required Color focusColor,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF718096)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: focusColor, width: 2),
      ),
      prefixIcon: Icon(icon, color: focusColor),
    );
  }

  static Widget cancelButton(BuildContext context, {String text = 'Cancel'}) {
    return OutlinedButton(
      onPressed: () => Navigator.pop(context),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: const Color(0xFF667eea).withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'Cancel',
        style: TextStyle(
          color: Color(0xFF667eea),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget primaryButton({
    required String text,
    required VoidCallback? onPressed,
    Color color = const Color(0xFF667eea),
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }


  static Widget loading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF667eea)),
    );
  }

  static Widget emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Color color = const Color(0xFF667eea),
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: color.withOpacity(0.2), width: 1.5),
            ),
            child: Icon(icon, size: 50, color: color),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 16, color: Color(0xFF718096)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      subtitle: subtitle,
      headerHeight: headerHeight,
      onBack: () => Navigator.pop(context),  
      floatingActionButton: floatingActionButton,
      child: Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFFF8FAFF),
        child: child,
      ),
    );
  }
}
