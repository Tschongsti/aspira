import 'package:flutter_riverpod/flutter_riverpod.dart';

final firstVisitProvider = StateNotifierProvider<FirstVisitNotifier, Set<String>>((ref) {
  return FirstVisitNotifier();
});

class FirstVisitNotifier extends StateNotifier<Set<String>> {
  FirstVisitNotifier() : super({});

  void markVisited(String key) {
    state = {...state, key};
  }

  bool isVisited(String key) {
    return state.contains(key);
  }
}
