import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aspira/providers/visited_screens_provider.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    ref.listen<Set<String>>(visitedScreensProvider, (_, __) {
      notifyListeners();
    });
  }
}