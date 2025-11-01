import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain/providers/project_provider.dart';
import 'package:chain/screens/project_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:chain/l10n/app_localizations.dart';

class CompletedProjectsScreen extends StatelessWidget {
  const CompletedProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final localeTag = Intl.canonicalizedLocale(Localizations.localeOf(context).toLanguageTag());
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('completed_tab')),
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          final completedProjects = projectProvider.getCompletedProjects();

          if (completedProjects.isEmpty) {
            return Center(
              child: Text(loc.translate('empty_completed')),
            );
          }

          return ListView.builder(
            itemCount: completedProjects.length,
            itemBuilder: (context, index) {
              final project = completedProjects[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectDetailPage(projectId: project.id),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          '${loc.translate('completion_date')}: ${project.dailyStatus.isNotEmpty ? DateFormat.yMMMd(localeTag).format(project.dailyStatus.last.date) : '-'}',
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                            onPressed: () {
                              project.isCompleted = false;
                              projectProvider.updateProject(project);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(loc.translate('project_reverted'))),
                              );
                            },
                            child: Text(loc.translate('undo_completion')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
