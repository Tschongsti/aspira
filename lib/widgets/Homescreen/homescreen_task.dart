import 'package:flutter/material.dart';

import 'package:aspira/theme/color_schemes.dart';
import 'package:aspira/theme/spacing.dart';

enum TaskType { task, quantity, timer }

class HomescreenTask extends StatelessWidget {
  final TaskType type;
  final Icon icon;
  final String title;
  final Duration loggedTime;
  final Duration goalTime;
  final bool isRunning;
  final VoidCallback? onTapMainAction;
  final VoidCallback? onEdit;

  const HomescreenTask({
    super.key,
    required this.type,
    required this.icon,
    required this.title,
    required this.loggedTime,
    required this.goalTime,
    required this.isRunning,
    required this.onTapMainAction,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final showEdit = loggedTime > Duration.zero && onEdit != null;

    return Container(
      margin: const EdgeInsets.only(bottom: kPaddingSmall),
      padding: const EdgeInsets.all(kPaddingSmall),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: kAspiraLavender,
            child: IconTheme(
              data: const IconThemeData(
                color: kAspiraGold,
                size: 24,
              ),
              child: icon,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white
                  ),
                ),
                Text(
                  '${_formatDuration(loggedTime)} / ${_formatDuration(goalTime)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 36,
            height: 36,
            child: showEdit
                ? IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.edit),
                    color: kAspiraGold,
                    onPressed: onEdit,
                  )
                : const SizedBox.shrink(),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: onTapMainAction != null
                ? _buildMainActionButton()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionButton() {
    switch (type) {
      case TaskType.task:
        return IconButton(
          icon: const Icon(
            Icons.check,
            color: kAspiraGold
          ),
          onPressed: onTapMainAction,
        );
      case TaskType.quantity:
        return IconButton(
          icon: const Icon(
            Icons.add,
            color: kAspiraGold
          ),
          onPressed: onTapMainAction,
        );
      case TaskType.timer:
        return IconButton(
          icon: Icon(
            isRunning ? Icons.pause_circle_outline : Icons.play_circle_outline,
            size: 36,
            color: kAspiraGold
          ),
          onPressed: onTapMainAction,
        );
    }
  }

  Color _backgroundColor() {
    switch (type) {
      case TaskType.task:
        return Colors.green.shade100;
      case TaskType.quantity:
        return Colors.orange.shade100;
      case TaskType.timer:
        return kAspiraPurple;
    }
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.remainder(24).toString().padLeft(2,'0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
