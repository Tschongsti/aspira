import 'package:flutter/material.dart';

import 'package:aspira/models/fokus_taetigkeiten.dart';

class NewFokustaetigkeit extends StatefulWidget {
  const NewFokustaetigkeit({super.key, required this.onAddFokustaetigkeit});

  final void Function(FokusTaetigkeit fokusTaetigkeit) onAddFokustaetigkeit;

  @override
  State<NewFokustaetigkeit> createState () {
    return _NewFokustaetigkeitState();
  }
}

class _NewFokustaetigkeitState extends State<NewFokustaetigkeit> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weeklyGoalController = TextEditingController();
  IconName _selectedIconName = IconName.favorite;

void _submitTaetigkeitData () {
    // final enteredAmount = double.tryParse(_amountController.text); // tryParse('Hello') => null, tryParse('1.13') => 1.13
    //final amountIsInvalid = enteredAmount == null || enteredAmount <=0; // && = AND, || = OR
    // if(_titleController.text.trim().isEmpty ||
    //  amountIsInvalid ||
    //  _selectedDate == null) { 
    //  _showDialog();
    //  return;
    //  }
    
    widget.onAddFokustaetigkeit(  
      FokusTaetigkeit(    
        title: _titleController.text,
        description: _descriptionController.text,
        iconName: _selectedIconName,
        weeklyGoal: Duration(minutes: _weeklyGoalController.hashCode),
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
                    DropdownButton (
                      value: _selectedIconName,
                      items: IconName.values
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Icon(
                              categoryIcons[category],
                              ),
                            ),
                        )
                        .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _selectedIconName = value;
                        });
                      }
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
                const SizedBox(width: 16),
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