import 'package:expense_tracker/providers/filters_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FiltersScreen extends ConsumerWidget {
  const FiltersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilters = ref.watch(filtersProvider);
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Food'),
          value: activeFilters[Filter.food]!,
          onChanged: (value) {
            ref.read(filtersProvider.notifier).setFilter(Filter.food, value);
          },
        ),
        SwitchListTile(
          title: const Text('Travel'),
          value: activeFilters[Filter.travel]!,
          onChanged: (value) {
            ref.read(filtersProvider.notifier).setFilter(Filter.travel, value);
          },
        ),
        SwitchListTile(
          title: const Text('Leisure'),
          value: activeFilters[Filter.leisure]!,
          onChanged: (value) {
            ref.read(filtersProvider.notifier).setFilter(Filter.leisure, value);
          },
        ),
        SwitchListTile(
          title: const Text('Work'),
          value: activeFilters[Filter.work]!,
          onChanged: (value) {
            ref.read(filtersProvider.notifier).setFilter(Filter.work, value);
          },
        ),
      ],
    );
  }
}
