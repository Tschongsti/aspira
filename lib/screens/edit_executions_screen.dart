import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:sqflite/sqflite.dart';

import 'package:aspira/data/database.dart';
import 'package:aspira/models/execution_entry.dart';
import 'package:aspira/models/trackable_task.dart';

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
    final db = await getDatabase();
    final start = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day);
    final end = start.add(Duration(days: 1)).subtract(Duration(milliseconds: 1));

    final data = await db.query(
      'execution_entries',
      where: 'taskId = ? AND start >= ? AND start < ? AND isArchived = 0',
      whereArgs: [widget.task.id, start.toLocal().toIso8601String(), end.toLocal().toIso8601String()],
    );

    setState(() {
      _entries = data.map((row) => ExecutionEntry.fromMap(row)).toList();
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
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked != null) {
      final updated = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, picked.hour, picked.minute);
      setState(() {
        _entries[index] = _entries[index].copyWith(
          start: isStart ? updated : null,
          end: isStart ? null : updated,
        );
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

    final db = await getDatabase();
    final startOfDay = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

    final existing = await db.query(
      'execution_entries',
      where: 'taskId = ? AND start >= ? AND start < ?',
      whereArgs: [widget.task.id, startOfDay.toLocal().toIso8601String(), endOfDay.toLocal().toIso8601String()],
    );

    final existingIds = existing.map((item) => item['id'] as String).toSet();
    final currentIds = _entries.map((item) => item.id).toSet();

    final idsToDelete = existingIds.difference(currentIds);

    final batch = db.batch();
    for (final id in idsToDelete) {
      batch.delete('execution_entries', where: 'id = ?', whereArgs: [id]);
    }

    for (final entry in _entries) {
      batch.insert(
        'execution_entries',
        entry.toLocalMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);

    if (!mounted) return;
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
      isDirty: true,
      isArchived: false,
      updatedAt: DateTime.now(),
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
