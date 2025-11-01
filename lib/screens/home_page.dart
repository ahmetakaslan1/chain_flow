import 'package:flutter/material.dart';
import 'package:chain/screens/completed_projects_screen.dart';
import 'package:chain/screens/settings_screen.dart';
import 'package:chain/screens/statistics_screen.dart';
import 'package:provider/provider.dart';
import 'package:chain/providers/project_provider.dart';
import 'package:chain/widgets/project_card.dart';
import 'package:chain/screens/project_detail_page.dart';
import 'package:chain/screens/add_project_screen.dart';
import 'package:intl/intl.dart';
import 'package:chain/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _HomeScreenContent(),
      const StatisticsScreen(),
      const SettingsScreen(),
      const CompletedProjectsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('greeting'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            Text(
              loc.translate('home_title'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              child: Icon(
                Icons.bolt_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _screens[_currentIndex],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProjectScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(loc.translate('new_project')),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.8),
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.home_rounded), label: loc.translate('home_tab')),
              BottomNavigationBarItem(icon: const Icon(Icons.bar_chart_rounded), label: loc.translate('stats_tab')),
              BottomNavigationBarItem(icon: const Icon(Icons.settings_rounded), label: loc.translate('settings_tab')),
              BottomNavigationBarItem(icon: const Icon(Icons.archive_rounded), label: loc.translate('completed_tab')),
            ],
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final localeTag = Intl.canonicalizedLocale(Localizations.localeOf(context).toLanguageTag());
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.08),
            Theme.of(context).colorScheme.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Consumer<ProjectProvider>(
          builder: (context, projectProvider, child) {
            final activeProjects = projectProvider.getActiveProjects();
            final filteredProjects = activeProjects
                .where((project) => project.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();

            final headline = filteredProjects.isEmpty
                ? loc.translate('no_projects_title')
                : loc.translate('projects_count', params: {'count': filteredProjects.length.toString()});

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat.yMMMMd(localeTag).format(DateTime.now()),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          hintText: loc.translate('search_hint'),
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        headline,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filteredProjects.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome_outlined,
                                size: 46,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                loc.translate('no_projects_title'),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                loc.translate('no_projects_message'),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          itemCount: filteredProjects.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 18),
                          itemBuilder: (context, index) {
                            final project = filteredProjects[index];
                            return ProjectCard(
                              project: project,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProjectDetailPage(projectId: project.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
