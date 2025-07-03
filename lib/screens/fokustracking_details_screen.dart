import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aspira/models/fokus_taetigkeiten.dart';
import 'package:aspira/models/trackable_task.dart';
import 'package:aspira/providers/auth_provider.dart';
import 'package:aspira/providers/user_focusactivities_provider.dart';
import 'package:aspira/theme/color_schemes.dart';
import 'package:aspira/utils/appscreenconfig.dart';
import 'package:aspira/utils/appscaffold.dart';
import 'package:aspira/utils/icon_picker.dart';

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
  late IconData _selectedIcon;
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Initialwerte setzen – leer oder aus initialData
    _title = widget.initialData?.title ?? '';
    _description = widget.initialData?.description ?? '';
    _weeklyGoal = widget.initialData?.weeklyGoal.inMinutes ?? 30;
    _selectedIcon = widget.initialData?.iconData ?? Icons.favorite;
  }

  Future<void> _toggleStatus() async {
    if (widget.initialData == null) return;

    setState(() => _isSubmitting = true);
    final notifier = ref.read(userFokusActivitiesProvider.notifier);

    final uid = ref.read(firebaseUidProvider);
      if (uid == null || uid.isEmpty) {
        debugPrint('🛑 FokustrackingDetailsScreenState_toggleStatus: keine gültige userId verfügbar');
        return;
      }

    final toggled = FokusTaetigkeit(
      id: widget.initialData!.id,
      userId: uid,
      title: widget.initialData!.title,
      description: widget.initialData!.description,
      iconData: widget.initialData!.iconData,
      weeklyGoal: widget.initialData!.weeklyGoal,
      startDate: widget.initialData!.startDate,
      loggedTime: widget.initialData!.loggedTime,
      status: widget.initialData!.status == TaskStatus.active
          ? TaskStatus.inactive
          : TaskStatus.active,
      updatedAt: DateTime.now(),
      isDirty: true,
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

    final uid = ref.read(firebaseUidProvider);
      if (uid == null || uid.isEmpty) {
        debugPrint('🛑 FokustrackingDetailsScreenState_saveForm: keine gültige userId verfügbar');
        return;
      }

    final updated = FokusTaetigkeit(
      id: widget.initialData?.id, // bleibt gleich bei Update
      userId: uid,     
      title: _title,
      description: _description,
      iconData: _selectedIcon,
      weeklyGoal: Duration(minutes: _weeklyGoal),
      status: widget.initialData?.status ?? TaskStatus.active,
      updatedAt: DateTime.now(),
      isDirty: true,
    );

    final notifier = ref.read(userFokusActivitiesProvider.notifier);

    try {
      if (widget.initialData == null) {
        await notifier.addFokusTaetigkeit(updated);
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

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.initialData != null;
    final isInactive = widget.initialData?.status == TaskStatus.inactive;
    
    final config = AppScreenConfig(
      title: isEditMode
            ? 'Fokustätigkeit bearbeiten'
            : 'Fokustätigkeit hinzufügen',
      showBottomNav: false,
      showAppBar: true,
    );

    return AppScaffold(
      config: config,
      child: LayoutBuilder(
        builder: (context, constraints) {
         return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey, // zum Validieren und Speichern der Formulareingaben
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            Text('Icon'),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: Icon(_selectedIcon, size: 32),
                              tooltip: 'Icon auswählen',
                              onPressed: () async {
                                final picked = await pickIcon(context);
                                if (picked != null) {
                                  setState(() {
                                    _selectedIcon = picked;
                                  });
                                }
                              },
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
                                  if (parsed == null) {
                                    return 'Bitte eine gültige Zahl eingeben';
                                  }
                                   if (parsed < 1 || parsed > 6720) {
                                    return 'Wert muss zwischen 1 und 6720 Minuten liegen';
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
                        const SizedBox(height: 36),
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
                        const SizedBox (height: 12),
                        TextButton(
                          onPressed: _isSubmitting
                            ? null 
                            : () => Navigator.of(context).pop(),
                          child: const Text('Abbrechen'),
                        ),                        
                        const Spacer(),
                        if (isEditMode)
                          ElevatedButton(
                            onPressed: _isSubmitting
                              ? null
                              : _toggleStatus,
                            style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                              backgroundColor: WidgetStateProperty.all(kAspiraBrown),
                            ),
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
                          const SizedBox(height: 36),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
