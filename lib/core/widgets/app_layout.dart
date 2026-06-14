import 'package:flutter/material.dart';

class AppLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showBack;
  const AppLayout({super.key, required this.title, required this.child, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: showBack ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)) : null,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: child,
    );
  }
}
