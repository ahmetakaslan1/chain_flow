import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain/providers/theme_provider.dart';
import 'package:chain/providers/project_provider.dart';
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:chain/models/project.dart';
import 'package:chain/services/notification_service.dart';
import 'package:chain/l10n/app_localizations.dart';
import 'package:chain/providers/locale_provider.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box _settingsBox;
  late int _chainAnalysisThreshold;
  late TimeOfDay _notificationTime;

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box('settings');
    _chainAnalysisThreshold = _settingsBox.get('chainAnalysisThreshold', defaultValue: 3);
    final savedHour = _settingsBox.get('notificationHour', defaultValue: 21);
    final savedMinute = _settingsBox.get('notificationMinute', defaultValue: 0);
    _notificationTime = TimeOfDay(hour: savedHour, minute: savedMinute);
  }

  Future<void> _selectTime(BuildContext context) async {
    final loc = context.loc;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );
    if (picked != null && picked != _notificationTime) {
      setState(() {
        _notificationTime = picked;
        _settingsBox.put('notificationHour', picked.hour);
        _settingsBox.put('notificationMinute', picked.minute);
      });
      final notificationService = Provider.of<NotificationService>(context, listen: false);
      await notificationService.scheduleSavedDailyReminder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('notification_time_saved'))),
        );
      }
    }
  }

  Future<void> _exportData() async {
    final loc = context.loc;
    try {
      final projects = Provider.of<ProjectProvider>(context, listen: false).projects;
      final jsonString = jsonEncode(projects.map((p) => p.toJson()).toList());

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/chainflow_data.json';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('export_success', params: {'path': filePath}))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('error_export', params: {'error': e.toString()}))),
      );
    }
  }

  Future<void> _importData() async {
    final loc = context.loc;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String jsonString = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(jsonString);

        final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
        await projectProvider.clearAllProjects();

        for (var projectJson in jsonList) {
          final project = Project.fromJson(projectJson as Map<String, dynamic>);
          await projectProvider.addProject(project);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.translate('import_success'))),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('import_cancelled'))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('error_import', params: {'error': e.toString()}))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final loc = context.loc;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('settings')),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(loc.translate('dark_mode')),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
          ListTile(
            title: Text(loc.translate('notification_time')),
            subtitle: Text(_notificationTime.format(context)),
            onTap: () => _selectTime(context),
          ),
          ListTile(
            title: Text(loc.translate('chain_analysis_threshold')),
            subtitle: Text(
              loc.translate('warn_after', params: {'days': _chainAnalysisThreshold.toString()}),
            ),
          ),
          Slider(
            value: _chainAnalysisThreshold.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: _chainAnalysisThreshold.toString(),
            onChanged: (value) {
              setState(() {
                _chainAnalysisThreshold = value.toInt();
                _settingsBox.put('chainAnalysisThreshold', _chainAnalysisThreshold);
              });
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              loc.translate('language'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'tr',
                  label: Text(loc.translate('turkish')),
                ),
                ButtonSegment(
                  value: 'en',
                  label: Text(loc.translate('english')),
                ),
              ],
              selected: {localeProvider.locale.languageCode},
              onSelectionChanged: (value) {
                final selected = value.first;
                localeProvider.setLocale(Locale(selected));
                Intl.defaultLocale = selected == 'en' ? 'en_US' : 'tr_TR';
                Provider.of<NotificationService>(context, listen: false).scheduleSavedDailyReminder();
                setState(() {});
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(loc.translate('export_data')),
            onTap: _exportData,
          ),
          ListTile(
            title: Text(loc.translate('import_data')),
            onTap: _importData,
          ),
        ],
      ),
    );
  }
}
