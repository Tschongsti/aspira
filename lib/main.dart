import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'package:aspira/theme/themes.dart';
import 'package:aspira/router/app_router.dart';
import 'package:aspira/services/app_lifecyclehandler.dart';


var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color(0xFFBCA7E6),
);

final container = ProviderContainer();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('de_CH', null);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((fn) {
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: ProviderScope(
        child: AspiraApp(navigatorKey: navigatorKey),
      ),
    ),
  );
  });
}

class AspiraApp extends ConsumerWidget {
  const AspiraApp({
    required this.navigatorKey,
    super.key
    });

  final GlobalKey<NavigatorState> navigatorKey; 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router =ref.watch(appRouterProvider);
    return AppLifecycleHandler(
      child: MaterialApp.router(
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
