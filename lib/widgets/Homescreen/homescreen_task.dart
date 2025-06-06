import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TaskType { task, quantity, timer }

class HomescreenTask extends StatelessWidget {
  final TaskType type;
  final Icon icon;
  final String title;
  final Duration loggedTime;
  final Duration goalTime;
  final bool isRunning;
  final VoidCallback onTapMainAction;
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withAlpha(30),
            child: icon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${_formatDuration(loggedTime)} / ${_formatDuration(goalTime)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          if (showEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
          _buildMainActionButton(),
        ],
      ),
    );
  }

  Widget _buildMainActionButton() {
    switch (type) {
      case TaskType.task:
        return IconButton(
          icon: const Icon(Icons.check),
          onPressed: onTapMainAction,
        );
      case TaskType.quantity:
        return IconButton(
          icon: const Icon(Icons.add),
          onPressed: onTapMainAction,
        );
      case TaskType.timer:
        return IconButton(
          icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
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
        return Colors.purple.shade100;
    }
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.remainder(24).toString().padLeft(2,'0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
