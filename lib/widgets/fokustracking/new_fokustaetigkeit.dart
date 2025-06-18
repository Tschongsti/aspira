import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aspira/models/fokus_taetigkeiten.dart';
import 'package:aspira/providers/user_profile_provider.dart';
import 'package:aspira/utils/icon_picker.dart';


class NewFokustaetigkeit extends ConsumerStatefulWidget {
  const NewFokustaetigkeit({super.key, required this.onAddFokustaetigkeit});

  final void Function(FokusTaetigkeit fokusTaetigkeit) onAddFokustaetigkeit;

  @override
  ConsumerState<NewFokustaetigkeit> createState () {
    return _NewFokustaetigkeitState();
  }
}

class _NewFokustaetigkeitState extends ConsumerState<NewFokustaetigkeit> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weeklyGoalController = TextEditingController();
  IconData _selectedIcon = Icons.favorite;

void _showDialog () {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ungültige Eingabe'),
          content: const Text('Bitte stelle sicher, dass Titel und Wochenziel gültig sind.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okay'),
              ),
          ],
        ),
      );
  }

void _submitTaetigkeitData () {
    final enteredWeeklyGoal = double.tryParse(_weeklyGoalController.text); // tryParse('Hello') => null, tryParse('1.13') => 1.13
    final weeklyGoalIsInvalid = enteredWeeklyGoal == null || enteredWeeklyGoal <=0; // && = AND, || = OR
      if(
        _titleController.text.trim().isEmpty ||
        weeklyGoalIsInvalid
        ) { 
      _showDialog();
      return;
     }
    
    final uid = ref.read(firebaseUidProvider);
      if (uid == null || uid.isEmpty) {
        debugPrint('🛑 NewFokustaetigkeitsState_submitTaetigkeitData: keine gültige userId verfügbar');
        return;
      }

    widget.onAddFokustaetigkeit(  
      FokusTaetigkeit(    
        userId: uid,
        title: _titleController.text,
        description: _descriptionController.text,
        iconData: _selectedIcon,
        weeklyGoal: Duration(minutes: enteredWeeklyGoal.round()),
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _weeklyGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return 
      SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text('Titel'),
                  ),
                ),
                const SizedBox(width: 16),
                TextField(
                  controller: _descriptionController,
                  maxLength: 250,
                  decoration: const InputDecoration(
                    label: Text('Beschreibung'),
                  ),
                ),
                 Row(
                  children: [
                    IconButton(
                      icon: Icon(_selectedIcon, size: 32),
                      tooltip: 'Icon wählen',
                      onPressed: () async {
                        final pickedIcon = await pickIcon(context);
                        if (pickedIcon != null) {
                          setState(() {
                            _selectedIcon = pickedIcon;
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _weeklyGoalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          suffixText: 'Minuten',
                          label: Text('Wochenziel'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children:[
                    const Spacer(),
                    TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: const Text('Abbrechen'),
                    ),
                    ElevatedButton(
                      onPressed: _submitTaetigkeitData,
                      child: const Text('Fokustätigkeit speichern!'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
    );
  }

}