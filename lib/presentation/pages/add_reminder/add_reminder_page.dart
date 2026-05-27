import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/usecases/reminder_usecases.dart';
import '../providers/app_providers.dart';
import '../widgets/reminder_card.dart';

/// Full-screen form for creating or editing a reminder.
/// Pass [existing] to pre-populate fields for editing.
class AddReminderPage extends ConsumerStatefulWidget {
  final Reminder? existing;
  const AddReminderPage({super.key, this.existing});

  @override
  ConsumerState<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends ConsumerState<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _customOffsetCtrl;

  late ReminderType _type;
  late RecurrenceRule _recurrence;
  late DateTime _selectedDateTime;
  late int _offsetDays;
  late bool _isCustomOffset;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    final settings = ref.read(settingsProvider);

    _titleCtrl = TextEditingController(text: r?.title ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _amountCtrl = TextEditingController(
        text: r?.amount != null ? r!.amount!.toStringAsFixed(2) : '');
    _customOffsetCtrl = TextEditingController(
        text: r?.isCustomOffset == true ? r!.reminderOffsetDays.toString() : '');

    _type = r?.type ?? ReminderType.expense;
    _recurrence = r?.recurrenceRule ?? RecurrenceRule.oneTime;
    _selectedDateTime = r?.dateTime ?? DateTime.now().add(const Duration(days: 1));
    _offsetDays = r?.reminderOffsetDays ?? settings.defaultOffsetDays;
    _isCustomOffset = r?.isCustomOffset ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _customOffsetCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time?.hour ?? _selectedDateTime.hour,
          time?.minute ?? _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final amount = _amountCtrl.text.trim().isEmpty
        ? null
        : double.tryParse(_amountCtrl.text.trim());

    final offset = _isCustomOffset
        ? (int.tryParse(_customOffsetCtrl.text.trim()) ?? _offsetDays)
        : _offsetDays;

    final reminder = Reminder(
      id: widget.existing?.id ?? const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      type: _type,
      amount: amount,
      dateTime: _selectedDateTime,
      recurrenceRule: _recurrence,
      reminderOffsetDays: offset,
      isCompleted: widget.existing?.isCompleted ?? false,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      isCustomOffset: _isCustomOffset,
    );

    try {
      if (widget.existing != null) {
        await sl<UpdateReminder>().call(reminder);
      } else {
        await sl<AddReminder>().call(reminder);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Reminder' : 'New Reminder'),
        leading: const BackButton(),
        actions: [
          if (!_saving)
            TextButton(
              onPressed: _save,
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
            )
          else
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          children: [
            // ── Type Selector ──────────────────────────────────────────────
            _SectionLabel('Reminder Type'),
            const SizedBox(height: 8),
            _TypeSelector(
              selected: _type,
              onChanged: (t) => setState(() => _type = t),
            ),
            const SizedBox(height: 20),

            // ── Title ──────────────────────────────────────────────────────
            _SectionLabel('Title *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. Netflix Subscription',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Title is required'
                  : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // ── Description ────────────────────────────────────────────────
            _SectionLabel('Description (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                hintText: 'Add a note...',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // ── Amount ─────────────────────────────────────────────────────
            _SectionLabel('Amount (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixIcon: Icon(Icons.currency_rupee_rounded),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            const SizedBox(height: 20),

            // ── Date & Time ────────────────────────────────────────────────
            _SectionLabel('Date & Time *'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEE, dd MMM yyyy  •  hh:mm a')
                          .format(_selectedDateTime),
                      style: theme.textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded,
                        color: theme.colorScheme.outline),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Recurrence ─────────────────────────────────────────────────
            _SectionLabel('Recurrence'),
            const SizedBox(height: 8),
            _RecurrenceSelector(
              selected: _recurrence,
              onChanged: (r) => setState(() => _recurrence = r),
            ),
            const SizedBox(height: 20),

            // ── Reminder Offset ────────────────────────────────────────────
            _SectionLabel('Remind me'),
            const SizedBox(height: 8),
            _OffsetSelector(
              selected: _offsetDays,
              isCustom: _isCustomOffset,
              customController: _customOffsetCtrl,
              onChanged: (days, isCustom) {
                setState(() {
                  _offsetDays = days;
                  _isCustomOffset = isCustom;
                });
              },
            ),
            const SizedBox(height: 32),

            // ── Save Button ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(isEdit ? 'Update Reminder' : 'Save Reminder'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Sub-Widgets ────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.outline,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final ReminderType selected;
  final ValueChanged<ReminderType> onChanged;

  const _TypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ReminderType.values.map((type) {
        final isSelected = type == selected;
        final color = ReminderTypeExtension.colorFor(type);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(ReminderTypeExtension.iconFor(type),
                    size: 14,
                    color: isSelected ? Colors.white : color),
                const SizedBox(width: 4),
                Text(type.label),
              ],
            ),
            selected: isSelected,
            onSelected: (_) => onChanged(type),
            selectedColor: color,
            backgroundColor: color.withOpacity(0.1),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w600,
              fontFamily: 'Outfit',
              fontSize: 13,
            ),
            checkmarkColor: Colors.white,
            showCheckmark: false,
            side: BorderSide(
              color: isSelected ? color : color.withOpacity(0.3),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RecurrenceSelector extends StatelessWidget {
  final RecurrenceRule selected;
  final ValueChanged<RecurrenceRule> onChanged;

  const _RecurrenceSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: RecurrenceRule.values.map((rule) {
        final isSelected = rule == selected;
        return ChoiceChip(
          label: Text(rule.label),
          selected: isSelected,
          onSelected: (_) => onChanged(rule),
          selectedColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : null,
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }
}

class _OffsetSelector extends StatelessWidget {
  final int selected;
  final bool isCustom;
  final TextEditingController customController;
  final Function(int days, bool isCustom) onChanged;

  const _OffsetSelector({
    required this.selected,
    required this.isCustom,
    required this.customController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final presets = [0, 1, 2, 3];
    final presetLabels = ['Same day', '1 day before', '2 days before', '3 days before'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...List.generate(presets.length, (i) {
              final isSelected = !isCustom && selected == presets[i];
              return ChoiceChip(
                label: Text(presetLabels[i]),
                selected: isSelected,
                onSelected: (_) => onChanged(presets[i], false),
                selectedColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w500,
                ),
              );
            }),
            ChoiceChip(
              label: const Text('Custom'),
              selected: isCustom,
              onSelected: (_) => onChanged(selected, true),
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isCustom ? Colors.white : null,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (isCustom)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextFormField(
              controller: customController,
              decoration: const InputDecoration(
                hintText: 'Days before event',
                suffixText: 'days',
                prefixIcon: Icon(Icons.tune_rounded),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (isCustom && (v == null || v.trim().isEmpty)) {
                  return 'Enter number of days';
                }
                return null;
              },
            ),
          ),
      ],
    );
  }
}
