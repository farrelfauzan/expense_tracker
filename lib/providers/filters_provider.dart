import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Filter {
  food,
  travel,
  leisure,
  work,
}

class FilterNotifier extends StateNotifier<Map<Filter, bool>> {
  FilterNotifier()
      : super(
          {
            Filter.food: true,
            Filter.travel: true,
            Filter.leisure: true,
            Filter.work: true,
          },
        );

  void setFilter(Filter filter, bool value) {
    state = {
      ...state,
      filter: value,
    };
  }

  void setFilters(Map<Filter, bool> filters) {
    state = filters;
  }
}

final filtersProvider =
    StateNotifierProvider<FilterNotifier, Map<Filter, bool>>(
  (ref) => FilterNotifier(),
);
