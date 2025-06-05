import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

import 'package:aspira/models/fokus_taetigkeiten.dart';
import 'package:aspira/providers/user_focusactivities_provider.dart';


class FokustrackingDetailsScreen extends ConsumerStatefulWidget {
  const FokustrackingDetailsScreen({
    this.initialData,
    super.key
    });

  final FokusTaetigkeit? initialData;

  @override
  ConsumerState<FokustrackingDetailsScreen> createState() => _FokustrackingDetailsScreenState();
}

class _FokustrackingDetailsScreenState extends ConsumerState<FokustrackingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _description;
  late int _weeklyGoal;
  late IconName _selectedIcon;
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Initialwerte setzen – leer oder aus initialData
    _title = widget.initialData?.title ?? '';
    _description = widget.initialData?.description ?? '';
    _weeklyGoal = widget.initialData?.weeklyGoal.inMinutes ?? 30;
    _selectedIcon = widget.initialData?.iconName ?? IconName.favorite;
  }

  Future<void> _toggleStatus() async {
    if (widget.initialData == null) return;

    setState(() => _isSubmitting = true);
    final notifier = ref.read(userFokusActivitiesProvider.notifier);

    final toggled = FokusTaetigkeit(
      id: widget.initialData!.id,
      title: widget.initialData!.title,
      description: widget.initialData!.description,
      iconName: widget.initialData!.iconName,
      weeklyGoal: widget.initialData!.weeklyGoal,
      startDate: widget.initialData!.startDate,
      loggedTime: widget.initialData!.loggedTime,
      status: widget.initialData!.status == Status.active
          ? Status.inactive
          : Status.active,
    );

    try {
      await notifier.updateFokusTaetigkeit(toggled, versionGoal: false);

      if (mounted) {
        ref.read(showInactiveProvider.notifier).state = false;
        Navigator.of(context).pop();
      }
      
    } catch (error, stackTrace) {
      debugPrint('Fehler toggleStatus: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Statusänderung fehlgeschlagen.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    _formKey.currentState!.save();
    setState(() => _isSubmitting = true); 

    final updated = FokusTaetigkeit(
      id: widget.initialData?.id, // bleibt gleich bei Update
      title: _title,
      description: _description,
      iconName: _selectedIcon,
      weeklyGoal: Duration(minutes: _weeklyGoal),
      status: widget.initialData?.status ?? Status.active,
    );

    final notifier = ref.read(userFokusActivitiesProvider.notifier);

    try {
      if (widget.initialData == null) {
        await notifier.addFokusTaetigkeit(updated, context);
      } else {
        final changedWeeklyGoal = updated.weeklyGoal != widget.initialData!.weeklyGoal;
        await notifier.updateFokusTaetigkeit(updated, versionGoal: changedWeeklyGoal);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (error, stackTrace) {
      debugPrint('Fehler saveForm: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speichern fehlgeschlagen.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
    final isEditMode = widget.initialData != null;
    final isInactive = widget.initialData?.status == Status.inactive;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode
            ? 'Fokustätigkeit bearbeiten'
            : 'Fokustätigkeit hinzufügen'
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Titel'),
                  initialValue: _title,
                  maxLength: 40,
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
                  initialValue: _description,
                  maxLength: 250,
                  minLines: 1,
                  maxLines: 6,
                  keyboardType: TextInputType.multiline,
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
                const SizedBox(height: 24),
                if (isEditMode)
                  ElevatedButton(
                    onPressed: _isSubmitting
                      ? null
                      : _toggleStatus,
                    child: _isSubmitting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          isInactive
                            ? 'Fokustätigkeit reaktivieren'
                            : 'Fokustätigkeit inaktivieren',
                        ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
