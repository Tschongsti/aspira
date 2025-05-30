import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aspira/models/fokus_taetigkeiten.dart';

class UserFokusActivitiesNotifier extends StateNotifier<List<FokusTaetigkeit>> {
  UserFokusActivitiesNotifier() : super(const []);

  void addFokusTaetigkeit(FokusTaetigkeit fokus) {   
    state = [fokus, ...state]; // new FokusTätigkeit is always at the start of the list
  }

  void remove(FokusTaetigkeit fokus) {
    state = [...state]..remove(fokus);
  }

  void insertAt(int index, FokusTaetigkeit fokus) {
    final newList = [...state];
    newList.insert(index, fokus);
    state = newList;
  }
}

final userFokusActivitiesProvider = StateNotifierProvider<UserFokusActivitiesNotifier, List <FokusTaetigkeit>>(
  (ref) => UserFokusActivitiesNotifier(),
);