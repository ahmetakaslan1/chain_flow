import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:chain/models/project.dart';
import 'package:chain/providers/project_provider.dart';
import 'package:chain/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _projectNameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _projectNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final TimeOfDay initialTime = TimeOfDay.fromDateTime(_selectedDate);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day, initialTime.hour, initialTime.minute);
      });
    }
  }

  void _saveProject() {
    final loc = context.loc;
    if (_formKey.currentState!.validate()) {
      final newProject = Project(
        id: const Uuid().v4(),
        name: _projectNameController.text,
        startDate: _selectedDate,
      );
      Provider.of<ProjectProvider>(context, listen: false).addProject(newProject);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('project_saved'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final localeTag = Intl.canonicalizedLocale(Localizations.localeOf(context).toLanguageTag());
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('add_project')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _projectNameController,
                decoration: InputDecoration(
                  labelText: loc.translate('project_name'),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.translate('project_name');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${loc.translate('start_date_label')}: ${DateFormat.yMMMd(localeTag).format(_selectedDate)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text(loc.translate('select_date')),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              FilledButton(
                onPressed: _saveProject,
                child: Text(loc.translate('save')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
