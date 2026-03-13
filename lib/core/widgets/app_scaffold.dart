import 'package:flutter/material.dart';
import 'package:diplomeprojectmobile/app/theme/colors.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.useSafeArea = true,
  });

  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final EdgeInsets padding;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: body);

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(title: Text(title!), actions: actions),
      backgroundColor: AppColors.background,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
