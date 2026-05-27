import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/reminder.dart';
import '../../../domain/usecases/reminder_usecases.dart';
import '../../providers/app_providers.dart';
import '../../widgets/reminder_card.dart';
import '../add_reminder/add_reminder_page.dart';

/// Dashboard — the first tab shown to users.
/// Shows summary stats, next-7-days, and all upcoming reminders.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final remindersAsync = ref.watch(remindersStreamProvider);
    final next7Days = ref.watch(next7DaysProvider);
    final monthlyTotal = ref.watch(monthlyTotalProvider);
    final settings = ref.watch(settingsProvider);
    final currency = settings.currency;

    return CustomScrollView(
      slivers: [
        // ── Header ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _DashboardHeader(
            currency: currency,
            monthlyTotal: monthlyTotal,
            upcomingCount: next7Days.length,
          ),
        ),

        // ── Filter Chips ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _FilterBar(),
        ),

        // ── Search Bar ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _SearchBar(),
        ),

        // ── Next 7 Days ─────────────────────────────────────────────────
        if (next7Days.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                '🔥 Next 7 Days',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ReminderListItem(reminder: next7Days[i]),
              ),
              childCount: next7Days.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
        ],

        // ── All Upcoming ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'All Upcoming',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),

        remindersAsync.when(
          data: (_) {
            final reminders = ref.watch(filteredRemindersProvider);
            if (reminders.isEmpty) {
              return SliverToBoxAdapter(
                child: _EmptyState(),
              );
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ReminderListItem(reminder: reminders[i]),
                ),
                childCount: reminders.length,
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(
            child: Center(
                child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )),
          ),
          error: (e, _) => SliverToBoxAdapter(
            child: Center(child: Text('Error: $e')),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

// ── Dashboard Header ──────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final String currency;
  final AsyncValue<double> monthlyTotal;
  final int upcomingCount;

  const _DashboardHeader({
    required this.currency,
    required this.monthlyTotal,
    required this.upcomingCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good ${_greeting()}! 👋',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'NotifyQ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications_rounded,
                    color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Monthly Outflow',
                  value: monthlyTotal.when(
                    data: (v) => '$currency${v.toStringAsFixed(0)}',
                    loading: () => '...',
                    error: (_, __) => '$currency?',
                  ),
                  icon: Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Due This Week',
                  value: '$upcomingCount',
                  icon: Icons.event_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    fontFamily: 'Outfit',
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Bar ────────────────────────────────────────────────────────────────

class _FilterBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedTypeFilterProvider);

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterChip(
            label: 'All',
            selected: selected == null,
            color: Theme.of(context).colorScheme.primary,
            onTap: () => ref.read(selectedTypeFilterProvider.notifier).state = null,
          ),
          ...ReminderType.values.map((type) => _FilterChip(
                label: type.label,
                selected: selected == type,
                color: ReminderTypeExtension.colorFor(type),
                onTap: () =>
                    ref.read(selectedTypeFilterProvider.notifier).state =
                        selected == type ? null : type,
              )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? color : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? color : color.withOpacity(0.3),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                fontFamily: 'Outfit',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Search Bar ─────────────────────────────────────────────────────────────────

class _SearchBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        onChanged: (v) =>
            ref.read(searchQueryProvider.notifier).state = v,
        decoration: InputDecoration(
          hintText: 'Search reminders...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: ref.watch(searchQueryProvider).isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () =>
                      ref.read(searchQueryProvider.notifier).state = '',
                )
              : null,
        ),
      ),
    );
  }
}

// ── Reminder List Item ────────────────────────────────────────────────────────

class _ReminderListItem extends ConsumerWidget {
  final Reminder reminder;
  const _ReminderListItem({required this.reminder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(reminder.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Reminder'),
          content: Text('Delete "${reminder.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
      onDismissed: (_) => sl<DeleteReminder>().call(reminder.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 26),
      ),
      child: ReminderCard(
        reminder: reminder,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => AddReminderPage(existing: reminder)),
        ),
        onToggleComplete: () =>
            sl<ToggleReminderComplete>().call(reminder.id),
        onDelete: () => sl<DeleteReminder>().call(reminder.id),
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No reminders yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first reminder',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
