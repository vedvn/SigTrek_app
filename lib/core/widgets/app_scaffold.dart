import 'package:flutter/material.dart';
import '../constants/dimensions.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final String? title;

  const AppScaffold({
    super.key,
    required this.child,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null ? AppBar(title: Text(title!)) : null,
      body: Padding(
        padding: const EdgeInsets.all(AppDimens.padding),
        child: child,
      ),
    );
  }
}
