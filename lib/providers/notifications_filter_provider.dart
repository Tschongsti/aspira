import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Filter {
  daystart,
  dayend,
  weeklyReflection,
  dailyPlanning,
  weeklyPlanning,
  activityDocumentation
}

class FiltersNotifier extends StateNotifier<Map<Filter, bool>> {
  FiltersNotifier()
    : super({
      Filter.daystart: true,
      Filter.dayend: true,
      Filter.weeklyReflection: true,
      Filter.dailyPlanning: true,
      Filter.weeklyPlanning: true,
      Filter.activityDocumentation: true,
    });

  void setFilters(Map<Filter, bool> chosenFilters) {
    state = chosenFilters;
  }

  void setFilter(Filter filter, bool isActive) {
    state = {
      ...state,
      filter: isActive,
    };
  }
}

final filtersProvider =
  StateNotifierProvider<FiltersNotifier, Map<Filter, bool>>(
    (ref) => FiltersNotifier(),
  );
