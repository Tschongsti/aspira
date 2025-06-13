import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:aspira/providers/visited_screens_provider.dart';
import 'package:aspira/theme/themes.dart';
import 'package:aspira/utils/appscaffold.dart';
import 'package:aspira/utils/appscreenconfig.dart';

class FokustrackingIntroScreen extends ConsumerStatefulWidget {
  const FokustrackingIntroScreen({super.key});

  @override
  ConsumerState<FokustrackingIntroScreen> createState() => _State();
}

class _State extends ConsumerState<FokustrackingIntroScreen> {
  late YoutubePlayerController _ytController;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();
    const videoId = '1OCAGHYIG1c'; // ID oder Parameter übergeben

    _ytController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    )..addListener(() {
        if (_ytController.value.hasError) {
          setState(() {
            _videoError = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _ytController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   
    final config = AppScreenConfig(
      title: 'Fokustätigkeit Intro',
      showBottomNav: false,
      );
    
    return AppScaffold(
      config: config,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // YouTube‑Video
            if (!_videoError) ...[
              YoutubePlayer(
                controller: _ytController,
                showVideoProgressIndicator: true,
                onReady: () {
                  // Player bereit
                },
              ),
            ] else
              const Center(
                child: Text(
                  'Video kann derzeit nicht abgespielt werden.',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            const SizedBox(height: 24),

            // Erklärungstext
            Text(
              'Hast du dich schon gefragt, wie viel deiner Zeit wirklich in das fließt, was dir am allerwichtigsten ist?\n\nNur was sichtbar wird, kann bewusst wachsen.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                ),
            ),
            const SizedBox(height: 24),

            // Zitat
            Text(
              '„What gets measured, gets done.“\nPeter Drucker',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                ),
            ),
            const SizedBox(height: 32),

            // Call‑to‑Action
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(visitedScreensProvider.notifier)
                    .markVisited('fokus');
                if (context.mounted) {
                  context.go('/ins-tun/fokus');
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 72),
              ),
              child: const Text('Erfasse deine Fokus‑Tätigkeiten'),
            ),
          ],
        ),
      ),
    );
  }
}