import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:sqflite/sqflite.dart';

import 'package:aspira/data/database.dart';
import 'package:aspira/models/execution_entry.dart';
import 'package:aspira/models/trackable_task.dart';
import 'package:aspira/providers/weekly_sum_provider.dart';
import 'package:aspira/providers/total_logged_time_provicder.dart';
import 'package:aspira/utils/appscreenconfig.dart';
import 'package:aspira/utils/appscaffold.dart';

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
      where: 'taskId = ? AND start >= ? AND start < ? AND isArchived = 0 AND status = ?',
      whereArgs: [widget.task.id, start.toLocal().toIso8601String(), end.toLocal().toIso8601String(), ExecutionEntryStatus.active.name],
    );

    setState(() {
      _entries = data.map((row) => ExecutionEntry.fromLocalMap(row)).toList();
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
    final now = DateTime.now();

    for (int i = 0; i < _entries.length; i++) {
      final a = _entries[i];

      if (a.start.isAfter(a.end)) return false;
      if (a.end.isAfter(now)) return false;

      for (int j = i + 1; j < _entries.length; j++) {
        final b = _entries[j];

        final overlap = a.start.isBefore(b.end) && a.end.isAfter(b.start);
        if (overlap) return false;
      }
    }
    return true;
  }

  Future<void> _save() async {
    if (!_validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(
        'Ungültige Eingabe. Ausführungen können nicht in der Zukunft sein und dürfen sich nicht überschneiden'
      )));
      return;
    }

    final previousEntries = [..._entries];

    try {
      final db = await getDatabase();
      final batch = db.batch();

      for (final entry in _entries) {
        batch.insert(
          'execution_entries',
          entry.toLocalMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
      
      ref.invalidate(weeklySumProvider(widget.task)); // Provider invaldieren, damit Homescreen neue Daten lädt
      ref.invalidate(totalLoggedTimeProvider(widget.task.id));

      if (!mounted) return;
      Navigator.of(context).pop();

    } catch (error, stackTrace) {
      debugPrint('🛑 Fehler beim Speichern der Executions: $error');
      debugPrintStack(stackTrace: stackTrace);
      setState(() {
        _entries = previousEntries;
      });
    } 
  }

  void _addEntry() {
    final defaultStart = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, 9).toLocal();
    final defaultEnd = defaultStart.add(Duration(hours: 1)).toLocal();
    final newEntry = ExecutionEntry(
      id: const Uuid().v4(),
      taskId: widget.task.id,
      start: defaultStart,
      end: defaultEnd,
      status: ExecutionEntryStatus.active,
      isDirty: true,
      isArchived: false,
      updatedAt: DateTime.now(),
    );
    setState(() {
      _entries.add(newEntry);
    });
  }

  Future<void> _removeEntry(int index) async {
    final previousState = [..._entries];
    
    try {
      final deleted = _entries[index].copyWith(
        status: ExecutionEntryStatus.deleted,
        updatedAt: DateTime.now(),
        isDirty: true,
      );

      setState(() {
        _entries[index] = deleted;
      });
    } catch (error, stackTrace) {
      debugPrint('🛑 Fehler beim Soft Delete von ExecutionEntry: $error');
      debugPrintStack(stackTrace: stackTrace);
      setState(() {
        _entries = previousState;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = AppScreenConfig(
      title: 'Ausführungen ${widget.task.title.toString()}',
      showBottomNav: false,
      showAppBar: true,
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: _save,
        ),
      ],
    );
    
    final visibleEntries = _entries.where((e) => e.status == ExecutionEntryStatus.active).toList();

    return AppScaffold(
      config: config,  
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              top: false, // bereits durch AppBar geschützt
              bottom: true,
              child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 96,
                        ),
                        itemCount: visibleEntries.length,
                        itemBuilder: (context, index) {
                          final entry = visibleEntries[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: Padding (
                              padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox (width: 24),
                                    TextButton(
                                      onPressed: () => _pickTime(index, true),
                                      child: Text('Start: ${_formatTime(entry.start)}'),
                                    ),
                                    SizedBox (width: 12),
                                    TextButton(
                                      onPressed: () => _pickTime(index, false),
                                      child: Text('Ende: ${_formatTime(entry.end)}'),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.black),
                                      onPressed: () => _removeEntry(index),
                                    ),
                                    SizedBox (width: 24),
                                  ],
                                ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12),
                      child: ElevatedButton.icon(
                        onPressed: _addEntry,
                        icon: const Icon(Icons.add),
                        label: const Text('Neue Ausführung hinzufügen'),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }
}
