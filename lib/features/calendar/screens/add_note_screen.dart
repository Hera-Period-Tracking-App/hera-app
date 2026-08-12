import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/constants/app_constants.dart';
import 'package:hera_app/core/datasources/secure_storage_data_source.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/core/theme/app_colors.dart';
import 'package:hera_app/features/notes/exceptions/duplicate_note_date_exception.dart';
import 'package:hera_app/features/notes/models/note.dart';
import 'package:hera_app/features/notes/repositories/note_repository.dart';
import 'package:hera_app/features/settings/providers/auto_sync_provider.dart';
import 'package:hera_app/features/settings/providers/settings_provider.dart';
import 'package:hera_app/l10n/generated/app_localizations.dart';
import 'package:hera_app/shared/providers/shell_navigation_visibility_provider.dart';

class AddNoteScreen extends ConsumerStatefulWidget {
  const AddNoteScreen({
    required this.date,
    this.note,
    this.returnToNotes = false,
    super.key,
  });

  final DateTime date;
  final Note? note;
  final bool returnToNotes;

  @override
  ConsumerState<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends ConsumerState<AddNoteScreen> {
  final TextEditingController _noteController = TextEditingController();
  final Set<String> _selectedSymptoms = <String>{};
  final Set<String> _customSymptoms = <String>{};
  final Set<String> _visibleCommonSymptoms = Set<String>.from(_commonSymptoms);
  String? _selectedFlow;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(shellNavigationVisibleProvider.notifier)
            .setVisible(true);
      }
    });
    final note = widget.note;
    if (note != null) {
      _hydrateFromExistingNote(note.encryptedContent);
    }
    Future.microtask(_loadCustomSymptoms);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomSymptoms() async {
    final storage = ref.read(secureStorageDataSourceProvider);
    final rawValue = await storage.read(AppConstants.customSymptomsKey);
    if (rawValue == null || rawValue.isEmpty) {
      return;
    }

    final decoded = jsonDecode(rawValue);
    if (decoded is! List) {
      return;
    }

    final symptoms = decoded
        .whereType<String>()
        .map((symptom) => symptom.trim())
        .where((symptom) => symptom.isNotEmpty)
        .toSet();
    if (!mounted) {
      return;
    }

    setState(() {
      _customSymptoms
        ..addAll(symptoms)
        ..addAll(
          _selectedSymptoms.where(
            (symptom) => !_commonSymptoms.contains(symptom),
          ),
        );
    });
  }

  void _hydrateFromExistingNote(String content) {
    final noteLines = <String>[];

    for (final block in content.split('\n\n')) {
      final trimmedBlock = block.trim();
      if (trimmedBlock.isEmpty) {
        continue;
      }

      if (trimmedBlock.startsWith('Symptoms: ')) {
        final symptoms = trimmedBlock
            .substring('Symptoms: '.length)
            .split(',')
            .map((symptom) => symptom.trim())
            .where((symptom) => symptom.isNotEmpty);
        _selectedSymptoms.addAll(symptoms);
        _customSymptoms.addAll(
          symptoms.where((symptom) => !_commonSymptoms.contains(symptom)),
        );
        continue;
      }

      if (trimmedBlock.startsWith('Menstrual flow: ')) {
        final flow = trimmedBlock.substring('Menstrual flow: '.length).trim();
        if (flow.isNotEmpty) {
          _selectedFlow = flow;
        }
        continue;
      }

      noteLines.add(trimmedBlock);
    }

    _noteController.text = noteLines.join('\n\n');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedDate = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
    );
    final l10n = AppLocalizations.of(context);
    final noteInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: theme.colorScheme.outline,
        width: 0.75,
      ),
    );
    final focusedNoteInputBorder = noteInputBorder.copyWith(
      borderSide: BorderSide(
        color: theme.colorScheme.primary,
        width: 0.75,
      ),
    );
    final notesEnabled = ref.watch(settingsProvider).maybeWhen(
          data: (settings) => settings.notesEnabled,
          orElse: () => true,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? l10n.newNote : l10n.editNote),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 16),
            if (!notesEnabled)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    l10n.notesDisabledInSettings,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              )
            else ...[
              TextField(
                controller: _noteController,
                autofocus: true,
                minLines: 6,
                maxLines: 10,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  border: noteInputBorder,
                  enabledBorder: noteInputBorder,
                  focusedBorder: focusedNoteInputBorder,
                  hintText: l10n.writePrivateNoteHint,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isSaving ? null : _showSymptomsSheet,
                icon: const Icon(Icons.add),
                label: Text(l10n.addSymptoms),
              ),
              if (_selectedSymptoms.isNotEmpty || _selectedFlow != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final symptom in _selectedSymptoms)
                      InputChip(
                        label: Text(symptom),
                        onDeleted: _isSaving
                            ? null
                            : () => setState(
                                  () => _selectedSymptoms.remove(symptom),
                                ),
                      ),
                    if (_selectedFlow != null)
                      InputChip(
                        label: Text(
                          l10n.flowLabel(_flowLabel(l10n, _selectedFlow!)),
                        ),
                        onDeleted: _isSaving
                            ? null
                            : () => setState(() => _selectedFlow = null),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => _cancelNote(normalizedDate),
                      child: Text(l10n.cancelNote),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.sun,
                        foregroundColor: AppColors.twilight,
                      ),
                      onPressed:
                          _isSaving ? null : () => _saveNote(normalizedDate),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              widget.note == null ? l10n.saveNote : l10n.save,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveNote(DateTime date) async {
    final content = _buildNoteContent();
    final l10n = AppLocalizations.of(context);
    if (content.isEmpty) {
      _showMessage(l10n.writeNoteOrSymptomsBeforeSaving);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final note = widget.note;
      if (note == null) {
        await ref.read(noteRepositoryProvider).addNote(
              date: date,
              content: content,
            );
      } else {
        await ref.read(noteRepositoryProvider).updateNote(
              note: note,
              content: content,
            );
      }
      ref.read(autoSyncProvider).queueSync();

      if (!mounted) {
        return;
      }

      _showMessage(widget.note == null ? l10n.noteSaved : l10n.noteUpdated);
      _closeNoteEditor(date);
    } on DuplicateNoteDateException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage(l10n.couldNotSaveNote(error.toString()));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _cancelNote(DateTime date) {
    _closeNoteEditor(date);
  }

  void _closeNoteEditor(DateTime date) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(
      widget.returnToNotes
          ? AppRoutePaths.notes
          : '${AppRoutePaths.calendar}?focusDate=${_formatRouteDate(date)}',
    );
  }

  Future<void> _showSymptomsSheet() {
    final draftSymptoms = Set<String>.from(_selectedSymptoms);
    final draftCustomSymptoms = Set<String>.from(_customSymptoms);
    final draftVisibleCommonSymptoms = Set<String>.from(_visibleCommonSymptoms);
    final customSymptomController = TextEditingController();
    final editCustomSymptomController = TextEditingController();
    String? customSymptomBeingEdited;
    var draftFlow = _selectedFlow;
    var isCustomSymptomInputVisible = false;
    var isEditingSymptoms = false;
    final l10n = AppLocalizations.of(context);

    void applyChangesImmediately() {
      setState(() {
        _selectedSymptoms
          ..clear()
          ..addAll(draftSymptoms);
        _customSymptoms
          ..clear()
          ..addAll(draftCustomSymptoms);
        _visibleCommonSymptoms
          ..clear()
          ..addAll(draftVisibleCommonSymptoms);
        _selectedFlow = draftFlow;
      });
      _saveCustomSymptoms(draftCustomSymptoms);
    }

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SafeArea(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEditingSymptoms ? l10n.editSymptoms : l10n.symptoms,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setSheetState(() {
                            isEditingSymptoms = !isEditingSymptoms;
                            customSymptomBeingEdited = null;
                            editCustomSymptomController.clear();
                          });
                        },
                        icon: Icon(
                          isEditingSymptoms ? Icons.check : Icons.edit,
                        ),
                        label: Text(isEditingSymptoms ? l10n.done : l10n.edit),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isEditingSymptoms) ...[
                    Card(
                      child: Column(
                        children: [
                          for (final symptom in _commonSymptoms)
                            CheckboxListTile(
                              title: Text(_symptomLabel(l10n, symptom)),
                              value:
                                  draftVisibleCommonSymptoms.contains(symptom),
                              onChanged: (shown) {
                                setSheetState(() {
                                  if (shown ?? false) {
                                    draftVisibleCommonSymptoms.add(symptom);
                                  } else {
                                    draftVisibleCommonSymptoms.remove(symptom);
                                    draftSymptoms.remove(symptom);
                                  }
                                });
                                applyChangesImmediately();
                              },
                            ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final symptom in _commonSymptoms.where(
                          draftVisibleCommonSymptoms.contains,
                        ))
                          FilterChip(
                            label: Text(_symptomLabel(l10n, symptom)),
                            selected: draftSymptoms.contains(symptom),
                            onSelected: (selected) {
                              setSheetState(() {
                                if (selected) {
                                  draftSymptoms.add(symptom);
                                } else {
                                  draftSymptoms.remove(symptom);
                                }
                              });
                              applyChangesImmediately();
                            },
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    l10n.customSymptoms,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (isEditingSymptoms) ...[
                    if (draftCustomSymptoms.isEmpty)
                      Text(
                        l10n.noCustomSymptomsYet,
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      Card(
                        child: Column(
                          children: [
                            for (final symptom in draftCustomSymptoms) ...[
                              if (customSymptomBeingEdited == symptom)
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      TextField(
                                        controller:
                                            editCustomSymptomController,
                                        autofocus: true,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        decoration: InputDecoration(
                                          border: const OutlineInputBorder(),
                                          hintText: l10n.symptomName,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () {
                                                setSheetState(() {
                                                  customSymptomBeingEdited =
                                                      null;
                                                  editCustomSymptomController
                                                      .clear();
                                                });
                                                applyChangesImmediately();
                                              },
                                              child: Text(l10n.cancel),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: FilledButton(
                                              onPressed: () {
                                                final updatedSymptom =
                                                    editCustomSymptomController
                                                        .text
                                                        .trim();
                                                if (updatedSymptom.isEmpty) {
                                                  return;
                                                }
                                                setSheetState(() {
                                                  draftCustomSymptoms
                                                    ..remove(symptom)
                                                    ..add(updatedSymptom);
                                                  if (draftSymptoms
                                                      .remove(symptom)) {
                                                    draftSymptoms
                                                        .add(updatedSymptom);
                                                  }
                                                  customSymptomBeingEdited =
                                                      null;
                                                  editCustomSymptomController
                                                      .clear();
                                                });
                                                applyChangesImmediately();
                                              },
                                              child: Text(l10n.save),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ListTile(
                                  title: Text(symptom),
                                  trailing: Wrap(
                                    spacing: 4,
                                    children: [
                                      IconButton(
                                        tooltip: l10n.editCustomSymptom,
                                        icon: const Icon(Icons.edit_outlined),
                                        onPressed: () {
                                          setSheetState(() {
                                            customSymptomBeingEdited = symptom;
                                            editCustomSymptomController.text =
                                                symptom;
                                          });
                                        },
                                      ),
                                      IconButton(
                                        tooltip: l10n.removeCustomSymptom,
                                        icon: const Icon(
                                          Icons.delete_outline,
                                        ),
                                        onPressed: () {
                                          setSheetState(() {
                                            draftCustomSymptoms
                                                .remove(symptom);
                                            draftSymptoms.remove(symptom);
                                            if (customSymptomBeingEdited ==
                                                symptom) {
                                              customSymptomBeingEdited = null;
                                              editCustomSymptomController
                                                  .clear();
                                            }
                                          });
                                          applyChangesImmediately();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                  ] else ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final symptom in draftCustomSymptoms)
                          FilterChip(
                            label: Text(symptom),
                            selected: draftSymptoms.contains(symptom),
                            onSelected: (selected) {
                              setSheetState(() {
                                if (selected) {
                                  draftSymptoms.add(symptom);
                                } else {
                                  draftSymptoms.remove(symptom);
                                }
                              });
                              applyChangesImmediately();
                            },
                          ),
                        if (!isCustomSymptomInputVisible)
                          ActionChip(
                            avatar: const Icon(Icons.add),
                            label: Text(l10n.addSymptom),
                            onPressed: () {
                              setSheetState(() {
                                isCustomSymptomInputVisible = true;
                              });
                            },
                          ),
                      ],
                    ),
                    if (isCustomSymptomInputVisible) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: customSymptomController,
                              autofocus: true,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                border: const UnderlineInputBorder(),
                                hintText: l10n.symptomName,
                              ),
                              onSubmitted: (_) => _addCustomSymptom(
                                controller: customSymptomController,
                                symptoms: draftSymptoms,
                                customSymptoms: draftCustomSymptoms,
                                setSheetState: setSheetState,
                                hideInput: () {
                                  isCustomSymptomInputVisible = false;
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setSheetState(() {
                                        customSymptomController.clear();
                                        isCustomSymptomInputVisible = false;
                                      });
                                    },
                                    child: Text(l10n.cancel),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.sun,
                                      foregroundColor: AppColors.twilight,
                                    ),
                                    onPressed: () => _addCustomSymptom(
                                      controller: customSymptomController,
                                      symptoms: draftSymptoms,
                                      customSymptoms: draftCustomSymptoms,
                                      setSheetState: setSheetState,
                                      hideInput: () {
                                        isCustomSymptomInputVisible = false;
                                      },
                                    ),
                                    child: Text(l10n.add),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 20),
                  Text(
                    l10n.menstrualFlow,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final flow in _flowOptions)
                        ChoiceChip(
                          label: Text(_flowLabel(l10n, flow)),
                          selected: draftFlow == flow,
                          onSelected: (selected) {
                            setSheetState(() {
                              draftFlow = selected ? flow : null;
                            });
                            applyChangesImmediately();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      customSymptomController.dispose();
      editCustomSymptomController.dispose();
    });
  }

  void _addCustomSymptom({
    required TextEditingController controller,
    required Set<String> symptoms,
    required Set<String> customSymptoms,
    required StateSetter setSheetState,
    required VoidCallback hideInput,
  }) {
    final customSymptom = controller.text.trim();
    if (customSymptom.isEmpty) {
      return;
    }

    setSheetState(() {
      customSymptoms.add(customSymptom);
      symptoms.add(customSymptom);
      controller.clear();
      hideInput();
    });
    setState(() {
      _customSymptoms.add(customSymptom);
      _selectedSymptoms.add(customSymptom);
    });
    _saveCustomSymptoms(_customSymptoms);
  }

  Future<void> _saveCustomSymptoms(Set<String> symptoms) {
    final storage = ref.read(secureStorageDataSourceProvider);
    final normalizedSymptoms = symptoms
        .map((symptom) => symptom.trim())
        .where((symptom) => symptom.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return storage.write(
      AppConstants.customSymptomsKey,
      jsonEncode(normalizedSymptoms),
    );
  }

  String _buildNoteContent() {
    final parts = <String>[];
    final note = _noteController.text.trim();
    if (note.isNotEmpty) {
      parts.add(note);
    }
    if (_selectedSymptoms.isNotEmpty) {
      parts.add('Symptoms: ${_selectedSymptoms.join(', ')}');
    }
    if (_selectedFlow != null) {
      parts.add('Menstrual flow: $_selectedFlow');
    }
    return parts.join('\n\n');
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.twilight,
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

const _commonSymptoms = [
  'Cramps',
  'Headache',
  'Bloating',
  'Back pain',
  'Breast tenderness',
  'Acne',
  'Fatigue',
  'Mood swings',
  'Nausea',
  'Cravings',
];

const _flowOptions = [
  'Spotting',
  'Light',
  'Medium',
  'Heavy',
  'Very heavy',
];

String _symptomLabel(AppLocalizations l10n, String symptom) {
  return switch (symptom) {
    'Cramps' => l10n.symptomCramps,
    'Headache' => l10n.symptomHeadache,
    'Bloating' => l10n.symptomBloating,
    'Back pain' => l10n.symptomBackPain,
    'Breast tenderness' => l10n.symptomBreastTenderness,
    'Acne' => l10n.symptomAcne,
    'Fatigue' => l10n.symptomFatigue,
    'Mood swings' => l10n.symptomMoodSwings,
    'Nausea' => l10n.symptomNausea,
    'Cravings' => l10n.symptomCravings,
    _ => symptom,
  };
}

String _flowLabel(AppLocalizations l10n, String flow) {
  return switch (flow) {
    'Spotting' => l10n.flowSpotting,
    'Light' => l10n.flowLight,
    'Medium' => l10n.flowMedium,
    'Heavy' => l10n.flowHeavy,
    'Very heavy' => l10n.flowVeryHeavy,
    _ => flow,
  };
}

String _formatRouteDate(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return '${normalized.year.toString().padLeft(4, '0')}-'
      '${normalized.month.toString().padLeft(2, '0')}-'
      '${normalized.day.toString().padLeft(2, '0')}';
}
