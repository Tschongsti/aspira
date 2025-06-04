import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

import 'package:aspira/models/fokus_taetigkeiten.dart';
import 'package:aspira/providers/user_focusactivities_provider.dart';


class NewFokustaetigkeitScreen extends ConsumerStatefulWidget {
  const NewFokustaetigkeitScreen({super.key});

  @override
  ConsumerState<NewFokustaetigkeitScreen> createState() => _NewFokustaetigkeitScreenState();
}

class _NewFokustaetigkeitScreenState extends ConsumerState<NewFokustaetigkeitScreen> {
  final _formKey = GlobalKey<FormState>();
  var _title = '';
  var _description = '';
  var _weeklyGoal = 30;
  var _selectedIcon = IconName.favorite;
  var _isSubmitting = false;

  void _saveForm() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    _formKey.currentState!.save();

    // setState(() => _isSubmitting = true); 

     ref.read(userFokusActivitiesProvider.notifier).addFokusTaetigkeit(
      FokusTaetigkeit(
        title: _title, 
        description: _description,
        iconName: _selectedIcon,
        weeklyGoal: Duration(minutes: _weeklyGoal),
        ),
        context,
     );

    // if (!mounted) return;
    Navigator.of(context).pop();
  }

  //void _pickIcon() async {
  //  IconData? icon = await IconPicker.showPicker(
  //    context,
  //    iconPackModes: [IconPack.material],
  //  );

  //  if (icon != null) {
  //    setState(() {
  //      _selectedIcon = icon;
  //    });
  //  }
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fokustätigkeit hinzufügen')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Titel'),
                  maxLength: 50,
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return 'Mind. 3 Zeichen nötig.';
                    }
                    return null;
                  },
                  onSaved: (value) => _title = value!.trim(),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Beschreibung'),
                  maxLines: 2,
                  maxLength: 250,
                  onSaved: (value) => _description = value?.trim() ?? '',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<IconName>(
                        value: _selectedIcon,
                        decoration: const InputDecoration(labelText: 'Icon'),
                        items: IconName.values.map((icon) {
                          return DropdownMenuItem(
                            value: icon,
                            child: Icon(categoryIcons[icon]),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                            setState(() {
                              _selectedIcon = value;
                            });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Wochenziel',
                          suffixText: 'Min',
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: _weeklyGoal.toString(),
                        validator: (value) {
                          final parsed = int.tryParse(value ?? '');
                          if (parsed == null || parsed <= 0) {
                            return 'Bitte gültige Zahl > 0';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _weeklyGoal = int.parse(value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting
                        ? null 
                        : () => Navigator.of(context).pop(),
                      child: const Text('Abbrechen'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSubmitting 
                        ? null 
                        : _saveForm,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Speichern'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
