import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:aspira/models/execution_entry.dart';
import 'package:aspira/models/trackable_task.dart';
import 'package:aspira/providers/weekly_sum_provider.dart';
import 'package:aspira/utils/get_current_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditExecutionsScreen extends ConsumerStatefulWidget {
  final TrackableTask task;
  final DateTime selectedDate;

  const EditExecutionsScreen({super.key, required this.task, required this.selectedDate});

  @override
  ConsumerState<EditExecutionsScreen> createState() => _EditExecutionsScreenState();
}

class _EditExecutionsScreenState extends ConsumerState<EditExecutionsScreen> {
  List<ExecutionEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExecutions();
  }

  Future<void> _loadExecutions() async {
    final user = getCurrentUserOrThrow();
    final start = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day);
    final end = start.add(Duration(days: 1)).subtract(Duration(milliseconds: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection(widget.task.parentCollection)
        .doc(widget.task.id)
        .collection('executions')
        .where('start', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('start', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    setState(() {
      _entries = snapshot.docs.map((doc) => ExecutionEntry.fromMap(doc.data())).toList();
      _isLoading = false;
    });
  }

  String _formatTime(DateTime time) {
    return DateFormat.Hm('de_CH').format(time);
  }

  Future<void> _pickTime(int index, bool isStart) async {
    final current = isStart ? _entries[index].start : _entries[index].end;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked != null) {
      final updated = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, picked.hour, picked.minute);
      setState(() {
        if (isStart) {
          _entries[index] = ExecutionEntry(
            id: _entries[index].id,
            taskId: _entries[index].taskId,
            start: updated,
            end: _entries[index].end,
          );
        } else {
          _entries[index] = ExecutionEntry(
            id: _entries[index].id,
            taskId: _entries[index].taskId,
            start: _entries[index].start,
            end: updated,
          );
        }
      });
    }
  }
  
  bool _validate() {
    final now = DateTime.now().toLocal();
    for (final entry in _entries) {
      if (entry.start.isAfter(entry.end)) return false;
      if (entry.end.isAfter(now)) return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (!_validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ungültige Zeiten.')));
      return;
    }

    final user = getCurrentUserOrThrow();
    final executionCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection(widget.task.parentCollection)
        .doc(widget.task.id)
        .collection('executions');

    final startOfDay = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

    final snapshot = await executionCollection
        .where('start', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('start', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    final existingIds = snapshot.docs.map((doc) => doc.id).toSet();
    final currentIds = _entries.map((e) => e.id).toSet();

    final idsToDelete = existingIds.difference(currentIds);

    final batch = FirebaseFirestore.instance.batch();

    // 1. Löschen
    for (final doc in snapshot.docs) {
      if (idsToDelete.contains(doc.id)) {
        batch.delete(doc.reference);
      }
    }

    // 2. Hinzufügen oder Überschreiben
    for (final entry in _entries) {
      batch.set(executionCollection.doc(entry.id), entry.toFirebaseMap());
    }

    await batch.commit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(weeklySumProvider(widget.task));
    }); 
    Navigator.of(context).pop();
  }

  void _addEntry() {
    final defaultStart = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, 9).toLocal();
    final defaultEnd = defaultStart.add(Duration(hours: 1)).toLocal();
    final newEntry = ExecutionEntry(
      id: const Uuid().v4(),
      taskId: widget.task.id,
      start: defaultStart,
      end: defaultEnd,
    );
    setState(() {
      _entries.add(newEntry);
    });
  }

  void _removeEntry(int index) {
    setState(() {
      _entries.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => _pickTime(index, true),
                              child: Text('Start: ${_formatTime(entry.start)}'),
                            ),
                            TextButton(
                              onPressed: () => _pickTime(index, false),
                              child: Text('Ende: ${_formatTime(entry.end)}'),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeEntry(index),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: ElevatedButton.icon(
                    onPressed: _addEntry,
                    icon: const Icon(Icons.add),
                    label: const Text('Neue Ausführung hinzufügen'),
                  ),
                ),
              ],
            ),
    );
  }
}
