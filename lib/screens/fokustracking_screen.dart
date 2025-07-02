import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:aspira/models/trackable_task.dart';
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
  
  @override
  Widget build(BuildContext context) {
    final fokusTaetigkeiten = ref.watch(userFokusActivitiesProvider);
    final hasInactive = fokusTaetigkeiten.any((item) => item.status == TaskStatus.inactive);
    final showInactive = ref.watch(showInactiveProvider);
    
    final filteredList = fokusTaetigkeiten.where((fokus) =>
      showInactive
        ? fokus.status == TaskStatus.inactive
        : fokus.status == TaskStatus.active
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
            onRemoveFokustaetigkeit: (deleted) {
              final notifier = ref.read(userFokusActivitiesProvider.notifier);
              final index = fokusTaetigkeiten.indexOf(deleted);

              notifier.deleteFokusTaetigkeit(deleted);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                
                ScaffoldMessenger.of(context)
                ..clearMaterialBanners()
                ..showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                    content: const Text('Fokus-Tätigkeit gelöscht.'),
                    action: SnackBarAction(
                      label: 'Wiederherstellen',
                      onPressed: () {
                        notifier.restoreFokusTaetigkeit(index, deleted);
                      },
                    ),
                  ),
                );
              });
            },
          );

    return AppScaffold(
      config: config,
      child: Column(
        children: [
          Expanded(child: mainContent),
          if (hasInactive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(showInactiveProvider.notifier).state = !showInactive;
                  },                          
                  icon: Icon(showInactive ? Icons.visibility : Icons.visibility_off),
                  label: Text(showInactive
                      ? 'Aktive Fokustätigkeiten anzeigen'
                      : 'Inaktive Fokustätigkeiten anzeigen'),
                ),
              ),
            ),
          SizedBox(height: 6),
        ],
      ),
    );
  }
}
