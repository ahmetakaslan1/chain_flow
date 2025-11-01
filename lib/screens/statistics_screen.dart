import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain/providers/project_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:chain/l10n/app_localizations.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final localeTag = Intl.canonicalizedLocale(Localizations.localeOf(context).toLanguageTag());
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('statistics')),
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          final allProjects = projectProvider.projects;

          if (allProjects.isEmpty) {
            return Center(
              child: Text(loc.translate('no_projects_title')),
            );
          }

          return ListView.builder(
            itemCount: allProjects.length,
            itemBuilder: (context, index) {
              final project = allProjects[index];
              final int daysWorked = project.dailyStatus.where((day) => day.isCompleted).length;
              final int totalDays = DateTime.now().difference(project.startDate).inDays + 1;
              final int daysMissed = totalDays - daysWorked;
              final double successRate = totalDays > 0 ? (daysWorked / totalDays) * 100 : 0.0;

              return Card(
                margin: const EdgeInsets.all(8.0),
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
                      Text('${loc.translate('start_date')}: ${DateFormat.yMMMd(localeTag).format(project.startDate)}'),
                      Text('${loc.translate('days_worked')}: $daysWorked'),
                      Text('${loc.translate('days_missed')}: $daysMissed'),
                      Text('${loc.translate('success_rate')}: ${successRate.toStringAsFixed(1)}%'),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        height: 150,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                color: Colors.green,
                                value: daysWorked.toDouble(),
                                title: loc.translate('days_worked'),
                                radius: 50,
                                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              PieChartSectionData(
                                color: Colors.red,
                                value: daysMissed.toDouble().clamp(0, double.infinity),
                                title: loc.translate('days_missed'),
                                radius: 50,
                                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                    ],
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
