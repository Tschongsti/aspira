import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:aspira/utils/appscreenconfig.dart';

class AppScaffold extends StatelessWidget {
  final AppScreenConfig config;
  final Widget child;

  int _locationToIndex(String location) {
  if (location.startsWith('/home')) return 0;
  if (location.startsWith('/effektivitaet')) return 1;
  if (location.startsWith('/effizienz')) return 2;
  if (location.startsWith('/ins-tun')) return 3;
  return 0;
  }

  const AppScaffold({super.key, required this.config, required this.child});

  void _onTap(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/effektivitaet');
        break;
      case 2:
        context.go('/effizienz');
        break;
      case 3:
        context.go('/ins-tun');
        break;
    }
  }  

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _locationToIndex(location);

    return Scaffold(
      appBar: config.showAppBar
          ? AppBar(
              title: Text(config.title),
              leading: config.leading,
              actions: config.appBarActions,
            )
          : null,
      body: child,
      bottomNavigationBar: config.showBottomNav
          ? BottomNavigationBar(
              onTap: (index) => _onTap(index, context),
              currentIndex: selectedIndex, // highlights the selected page
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.track_changes),
                  label: 'Effektivität',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.timer),
                  label: 'Effizienz',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.directions_run),
                  label: 'Ins Tun',
                )
              ],
            )
          : null,
    );
  }
}