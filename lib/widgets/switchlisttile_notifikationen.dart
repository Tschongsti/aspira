import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aspira/providers/notifications_filter_provider.dart';
import 'package:aspira/theme/color_schemes.dart';

class SwitchlisttileNotifikationen extends ConsumerWidget{
  
  final Filter filter;
  final String title;
  final String subtitle;

  const SwitchlisttileNotifikationen ({
    required this.filter,
    required this.title,
    required this.subtitle,
    super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilters = ref.watch(filtersProvider);
  
    return SwitchListTile(
      value: activeFilters[filter]!,
      onChanged: (isChecked) {
        ref
          .read(filtersProvider.notifier)
          .setFilter(filter, isChecked);
      },
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          ),
      ),
      activeColor: kAspiraPurple,
      contentPadding: const EdgeInsets.only(
        left: 34,
        right: 22,
      ),
    );
  }
}