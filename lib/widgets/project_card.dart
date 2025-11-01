import 'package:flutter/material.dart';
import 'package:chain/models/project.dart';
import 'package:intl/intl.dart';
import 'package:chain/l10n/app_localizations.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({super.key, required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final int totalDays = today.difference(project.startDate).inDays + 1;
    final int daysWorked = project.dailyStatus.where((day) => day.isCompleted).length;
    final double progress = totalDays > 0 ? (daysWorked / totalDays).clamp(0.0, 1.0) : 0.0;
    final loc = context.loc;
    final locale = Intl.canonicalizedLocale(Localizations.localeOf(context).toLanguageTag());

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.12),
              Theme.of(context).colorScheme.secondary.withOpacity(0.10),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Chip(
                  backgroundColor: project.isCompleted
                      ? Colors.green.shade100
                      : Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                  label: Text(
                    project.isCompleted
                        ? loc.translate('project_status_completed')
                        : loc.translate('project_status_active'),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: project.isCompleted
                              ? Colors.green.shade700
                              : Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  '${loc.translate('start_date_label')}: ${DateFormat.yMMMd(locale).format(project.startDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              children: [
                _ProgressStat(
                  label: loc.translate('days_completed'),
                  value: daysWorked.toString(),
                  icon: Icons.check_circle_outline,
                ),
                _ProgressStat(
                  label: loc.translate('total_days'),
                  value: totalDays.toString(),
                  icon: Icons.calendar_month_outlined,
                ),
                _ProgressStat(
                  label: loc.translate('success_rate'),
                  value: '${(progress * 100).toStringAsFixed(0)}%',
                  icon: Icons.rocket_launch_outlined,
                ),
              ],
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.arrow_forward_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProgressStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
