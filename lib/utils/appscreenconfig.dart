import 'package:flutter/material.dart';

class AppScreenConfig {
  final String title;
  final bool showAppBar;
  final bool showBottomNav;
  final Widget? leading;
  final List<Widget>? appBarActions;

  const AppScreenConfig({
    required this.title,
    this.showAppBar = true,
    this.showBottomNav = true,
    this.leading,
    this.appBarActions,
  });
}