import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain/models/project.dart';
import 'package:chain/providers/project_provider.dart';
import 'package:chain/models/day_status.dart';
import 'package:intl/intl.dart';
import 'package:chain/l10n/app_localizations.dart';

class ProjectDetailPage extends StatefulWidget {
  final String projectId;

  const ProjectDetailPage({super.key, required this.projectId});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  void _toggleDayStatus(Project project, DateTime date) {
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    setState(() {
      final existingStatusIndex = project.dailyStatus.indexWhere(
          (ds) => ds.date.year == date.year && ds.date.month == date.month && ds.date.day == date.day);

      if (existingStatusIndex != -1) {
        project.dailyStatus[existingStatusIndex].isCompleted =
            !project.dailyStatus[existingStatusIndex].isCompleted;
      } else {
        project.dailyStatus.add(DayStatus(date: date, isCompleted: true));
      }
      project.dailyStatus.sort((a, b) => a.date.compareTo(b.date));
    });
    provider.updateProject(project);
  }

  void _toggleProjectCompletion(Project project) {
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    setState(() {
      project.isCompleted = !project.isCompleted;
    });
    provider.updateProject(project);
  }

  Future<void> _showEditProjectDialog(Project project) async {
    final loc = context.loc;
    final controller = TextEditingController(text: project.name);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.translate('edit_project')),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: loc.translate('project_name'),
              hintText: loc.translate('project_name'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(loc.translate('cancel')),
            ),
            FilledButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isEmpty) return;
                if (newName == project.name) {
                  Navigator.pop(context, false);
                  return;
                }
                project.name = newName;
                Navigator.pop(context, true);
              },
              child: Text(loc.translate('save')),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await Provider.of<ProjectProvider>(context, listen: false).updateProject(project);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('project_updated'))),
        );
      }
    }
  }

  Future<void> _confirmDeleteProject(Project project) async {
    final loc = context.loc;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('delete_project')),
        content: Text(loc.translate('delete_project_message', params: {'name': project.name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.translate('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.translate('delete_project')),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await Provider.of<ProjectProvider>(context, listen: false).deleteProject(project.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('project_deleted'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final loc = context.loc;
    Project? project;
    for (final p in projectProvider.projects) {
      if (p.id == widget.projectId) {
        project = p;
        break;
      }
    }

    if (project == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.translate('app_title')),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentProject = project;
    final DateTime today = DateTime.now();
    final totalDays = DateTime.now().difference(currentProject.startDate).inDays + 1;
    final daysWorked = currentProject.dailyStatus.where((day) => day.isCompleted).length;
    final localeTag = Intl.canonicalizedLocale(Localizations.localeOf(context).toLanguageTag());
    final dateFormatter = DateFormat.yMMMMd(localeTag);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentProject.name),
        actions: [
          IconButton(
            tooltip: currentProject.isCompleted
                ? loc.translate('revert_project')
                : loc.translate('complete_project'),
            icon: Icon(currentProject.isCompleted ? Icons.undo : Icons.check_circle_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(currentProject.isCompleted
                      ? loc.translate('revert_project')
                      : loc.translate('complete_project')),
                  content: Text(currentProject.isCompleted
                      ? loc.translate('revert_project_message')
                      : loc.translate('complete_project_message')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(loc.translate('cancel')),
                    ),
                    TextButton(
                      onPressed: () {
                        _toggleProjectCompletion(currentProject);
                        Navigator.pop(context);
                        final message = currentProject.isCompleted
                            ? loc.translate('project_completed')
                            : loc.translate('project_reverted');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      },
                      child: Text(currentProject.isCompleted
                          ? loc.translate('revert_project')
                          : loc.translate('complete_project')),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            tooltip: loc.translate('edit_project'),
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditProjectDialog(currentProject),
          ),
          IconButton(
            tooltip: loc.translate('delete_project'),
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDeleteProject(currentProject),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormatter.format(currentProject.startDate),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.translate('total_days'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '$totalDays',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.translate('days_completed'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '$daysWorked',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                loc.translate('progress_overview'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: totalDays,
                itemBuilder: (context, index) {
                  final date = DateTime(currentProject.startDate.year, currentProject.startDate.month,
                          currentProject.startDate.day)
                      .add(Duration(days: index));
                  final isCompleted = currentProject.dailyStatus.any((ds) =>
                      ds.date.year == date.year && ds.date.month == date.month && ds.date.day == date.day && ds.isCompleted);
                  final bool isToday = today.year == date.year && today.month == date.month && today.day == date.day;
                  final bool isPast = date.isBefore(DateTime(today.year, today.month, today.day));

                  return GestureDetector(
                    onTap: () => _toggleDayStatus(currentProject, date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green.shade500
                            : (isPast ? Colors.redAccent.shade100 : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: isToday
                            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                            : Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          DateFormat.d(localeTag).format(date),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: isCompleted
                                    ? Colors.white
                                    : (isPast ? Colors.red.shade900 : Colors.grey.shade800),
                                fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
