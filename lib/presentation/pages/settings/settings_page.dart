import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';

/// Settings tab — theme, currency, default offset, notification toggle.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      children: [
        // ── Profile Placeholder ───────────────────────────────────────────
        // Future: Replace with real user profile from Firebase Auth.
        _ProfileCard(theme: theme),
        const SizedBox(height: 24),

        // ── Appearance ────────────────────────────────────────────────────
        _SectionHeader('Appearance'),
        _SettingsTile(
          icon: Icons.brightness_6_rounded,
          title: 'Theme',
          trailing: SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_rounded, size: 16)),
              ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_rounded, size: 16)),
              ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_rounded, size: 16)),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (s) => notifier.setThemeMode(s.first),
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Notifications ────────────────────────────────────────────────
        _SectionHeader('Notifications'),
        _SettingsTile(
          icon: Icons.notifications_rounded,
          title: 'Enable Notifications',
          subtitle: 'Receive alerts for upcoming reminders',
          trailing: Switch.adaptive(
            value: settings.notificationsEnabled,
            onChanged: (v) => notifier.setNotificationsEnabled(v),
            activeColor: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.timer_outlined,
          title: 'Default Reminder Offset',
          subtitle: '${settings.defaultOffsetDays} day(s) before event',
          onTap: () => _showOffsetPicker(context, settings.defaultOffsetDays,
              (v) => notifier.setDefaultOffset(v)),
        ),
        const SizedBox(height: 16),

        // ── Regional ─────────────────────────────────────────────────────
        _SectionHeader('Regional'),
        _SettingsTile(
          icon: Icons.currency_exchange_rounded,
          title: 'Currency Symbol',
          subtitle: settings.currency,
          onTap: () => _showCurrencyPicker(
              context, settings.currency, (v) => notifier.setCurrency(v)),
        ),
        const SizedBox(height: 24),

        // ── Future: Cloud Sync ────────────────────────────────────────────
        _SectionHeader('Future Features'),
        _SettingsTile(
          icon: Icons.cloud_sync_rounded,
          title: 'Cloud Sync',
          subtitle: 'Coming soon — sync across devices',
          enabled: false,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Soon',
              style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Outfit'),
            ),
          ),
        ),
        _SettingsTile(
          icon: Icons.auto_awesome_rounded,
          title: 'AI Spending Insights',
          subtitle: 'Coming soon — intelligent analysis',
          enabled: false,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Soon',
              style: TextStyle(
                  color: AppColors.info,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Outfit'),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ── App Info ──────────────────────────────────────────────────────
        Center(
          child: Column(
            children: [
              Text(
                AppConstants.appName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'v${AppConstants.appVersion}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  void _showOffsetPicker(
      BuildContext context, int current, ValueChanged<int> onSave) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OffsetPickerSheet(current: current, onSave: onSave),
    );
  }

  void _showCurrencyPicker(
      BuildContext context, String current, ValueChanged<String> onSave) {
    const currencies = ['₹', '\$', '€', '£', '¥', '₩', '฿', 'AED'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Currency',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: currencies
                  .map((c) => ChoiceChip(
                        label: Text(c),
                        selected: current == c,
                        onSelected: (_) {
                          onSave(c);
                          Navigator.pop(ctx);
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: current == c ? Colors.white : null,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Outfit',
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Sub-Widgets ────────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final ThemeData theme;
  const _ProfileCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.25),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Hello there! 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    fontFamily: 'Outfit',
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Sign in to sync across devices',  // Future: Firebase Auth
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Sign In',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                fontFamily: 'Outfit',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (enabled ? theme.colorScheme.primary : theme.colorScheme.outline)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: enabled
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.5),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: enabled ? null : theme.colorScheme.outline.withOpacity(0.5),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: enabled
                      ? null
                      : theme.colorScheme.outline.withOpacity(0.4),
                ),
              )
            : null,
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded) : null),
        onTap: enabled ? onTap : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _OffsetPickerSheet extends StatefulWidget {
  final int current;
  final ValueChanged<int> onSave;
  const _OffsetPickerSheet({required this.current, required this.onSave});

  @override
  State<_OffsetPickerSheet> createState() => _OffsetPickerSheetState();
}

class _OffsetPickerSheetState extends State<_OffsetPickerSheet> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Default Reminder Offset',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Notify me $_value day(s) before event',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          Slider(
            value: _value.toDouble(),
            min: 0,
            max: 7,
            divisions: 7,
            label: '$_value',
            onChanged: (v) => setState(() => _value = v.round()),
            activeColor: AppColors.primary,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(_value);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
