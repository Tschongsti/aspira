import 'package:aspira/models/execution_entry.dart';
import 'package:aspira/models/trackable_task.dart';
import 'package:aspira/providers/daily_execution_provider.dart';
import 'package:aspira/utils/get_current_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class EditExecutionsScreen extends ConsumerStatefulWidget {
  final TrackableTask task;
  final DateTime selectedDate;

  const EditExecutionsScreen({super.key, required this.task, required this.selectedDate});

  @override
  ConsumerState<EditExecutionsScreen> createState() => _EditExecutionsScreenState();
}

class _EditExecutionsScreenState extends ConsumerState<EditExecutionsScreen> {
  final List<ExecutionEntry> _editedEntries = [];
  final List<String> _deletedEntryIds = [];

  @override
  void initState() {
    super.initState();
    _loadExecutions();
  }

  void _loadExecutions() async {
    final data = await ref.read(dailyExecutionProvider((task: widget.task, date: widget.selectedDate)).future);
    setState(() {
      _editedEntries.clear();
      _editedEntries.addAll(data);
    });
  }

  void _addEmptyEntry() {
    final now = DateTime.now();
    final date = widget.selectedDate;
    final defaultStart = DateTime(date.year, date.month, date.day, now.hour, now.minute);
    final defaultEnd = defaultStart.add(Duration(minutes: 30));
    setState(() {
      _editedEntries.add(ExecutionEntry(
        id: const Uuid().v4(),
        taskId: widget.task.id,
        start: defaultStart,
        end: defaultEnd,
      ));
    });
  }

  Future<void> _saveChanges() async {
    final user = getCurrentUserOrThrow();
    final batch = FirebaseFirestore.instance.batch();

    final executionsRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection(widget.task.parentCollection)
      .doc(widget.task.id)
      .collection('executions');

    for (final entry in _editedEntries) {
      final docRef = executionsRef.doc(entry.id);
      batch.set(docRef, entry.toFirebaseMap());
    }

    for (final id in _deletedEntryIds) {
      final docRef = executionsRef.doc(id);
      batch.delete(docRef);
    }

    await batch.commit();
    if (mounted) Navigator.of(context).pop();
  }

  bool _isValidEntry(ExecutionEntry entry) {
    return entry.start.isBefore(entry.end) && !entry.end.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _editedEntries.length + 1,
        itemBuilder: (context, index) {
          if (index == _editedEntries.length) {
            return ElevatedButton.icon(
              onPressed: _addEmptyEntry,
              icon: Icon(Icons.add),
              label: Text('Session hinzufügen'),
            );
          }

          final entry = _editedEntries[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Start: ${TimeOfDay.fromDateTime(entry.start).format(context)}'),
                      ),
                      Expanded(
                        child: Text('Ende: ${TimeOfDay.fromDateTime(entry.end).format(context)}'),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _deletedEntryIds.add(entry.id);
                            _editedEntries.removeAt(index);
                          });
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
