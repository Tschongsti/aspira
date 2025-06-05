import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:aspira/models/fokus_taetigkeiten.dart';
import 'package:aspira/utils/appscreenconfig.dart';
import 'package:aspira/utils/appscaffold.dart';
import 'package:aspira/widgets/fokustracking/fokustracking_list.dart';
import 'package:aspira/providers/user_focusactivities_provider.dart';

class FokustrackingScreen extends ConsumerStatefulWidget {
  const FokustrackingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _FokustrackingScreenState();
  }
}

class _FokustrackingScreenState extends ConsumerState <FokustrackingScreen> { 
  late Future<void> _focusactivitiesFuture;
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    _focusactivitiesFuture = ref.read(userFokusActivitiesProvider.notifier).loadFokusActivities(context);
  }

  @override
  Widget build(BuildContext context) {
    final fokusTaetigkeiten = ref.watch(userFokusActivitiesProvider);
    final hasInactive = fokusTaetigkeiten.any((item) => item.status == Status.inactive);

    final filteredList = fokusTaetigkeiten.where((fokus) =>
      _showInactive
        ? fokus.status == Status.inactive
        : fokus.status == Status.active
    ).toList();

    final config = AppScreenConfig(
      title: 'Fokus Tätigkeiten',
      showAppBar: true,
      showBottomNav: true,
      appBarActions: [
        IconButton(
          onPressed: () {
            context.push('/ins-tun/fokus/intro');
          },
          icon: const Icon(Icons.help),
        ),
        IconButton(
          onPressed: () {
            context.push('/ins-tun/fokus/new');
          },
          icon: const Icon(Icons.add),
        ),
      ],
    );

    final mainContent = fokusTaetigkeiten.isEmpty
        ? Center(
            child: Text('Keine Fokus-Tätigkeiten gefunden. Bitte füge eine hinzu!'),
          )
        : FokustrackingList(
            fokusTaetigkeiten: filteredList,
            onRemoveFokustaetigkeit: (fokus) {
              final notifier = ref.read(userFokusActivitiesProvider.notifier);
              final index = fokusTaetigkeiten.indexOf(fokus);

              notifier.deleteFokustaetigkeit(fokus, context);

              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 3),
                  content: const Text('Fokus-Tätigkeit gelöscht.'),
                  action: SnackBarAction(
                    label: 'Wiederherstellen',
                    onPressed: () {
                      notifier.insertAt(index, fokus, context);
                    },
                  ),
                ),
              );
            },
          );

    return AppScaffold(
      config: config,
      child: FutureBuilder(
        future: _focusactivitiesFuture,
        builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(child: mainContent),
                  if (hasInactive)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _showInactive = !_showInactive;
                              });
                            },
                            icon: Icon(_showInactive ? Icons.visibility : Icons.visibility_off),
                            label: Text(_showInactive
                                ? 'Aktive Fokustätigkeiten anzeigen'
                                : 'Inaktive Fokustätigkeiten anzeigen'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
