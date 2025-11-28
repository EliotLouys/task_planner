// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zbeub_task_plan/data/enums.dart';
import 'package:zbeub_task_plan/data/settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/SettingsPage'),
      builder: (_) => const SettingsPage(),
    );
  }

  // Helper function to handle max tasks input validation and update
  void _submitMaxTasks(
    BuildContext context,
    SettingsProvider settings,
    String value,
  ) {
    final parsedValue = int.tryParse(value);

    // 1. Basic validation and check if the value actually changed
    if (parsedValue != null &&
        parsedValue >= 1 &&
        parsedValue <= 20 &&
        parsedValue != settings.maxTasksForToday) {
      settings.setMaxTasks(parsedValue); // Save and notify listeners
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum de tâches défini à $parsedValue.')),
      );
    } else if (parsedValue != null && (parsedValue < 1 || parsedValue > 20)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un nombre entre 1 et 20.'),
        ),
      );
    }
    // Dismiss keyboard after submission (important for clean UI)
    FocusScope.of(context).unfocus();
  }

  // Helper function to handle time selection and update the provider
  Future<void> _selectTime(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: settings.dailyReminderTime,
    );

    if (newTime != null) {
      await settings.setDailyReminderTime(newTime);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Rappel quotidien mis à jour à ${newTime.format(context)}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDarkMode = settingsProvider.themeMode == AppThemeMode.dark;

    // Using a TextEditingController to manage the field's value
    // and initialize it with the current provider state.
    final maxTasksController = TextEditingController(
      text: settingsProvider.maxTasksForToday.toString(),
    );

    // FocusNode for detecting when the user leaves the field
    final maxTasksFocusNode = FocusNode();

    // Listen to focus changes to trigger submission when focus is lost
    maxTasksFocusNode.addListener(() {
      if (!maxTasksFocusNode.hasFocus) {
        _submitMaxTasks(context, settingsProvider, maxTasksController.text);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // 1. Heure du Rappel Quotidien
          ListTile(
            title: const Text('Heure du Rappel Quotidien'),
            subtitle: const Text('Rappel pour planifier les tâches du jour.'),
            trailing: TextButton(
              onPressed: () => _selectTime(context, settingsProvider),
              child: Text(
                settingsProvider.dailyReminderTime.format(context),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const Divider(),

          // 2. Mode Sombre (App Theme: Light or Dark)
          SwitchListTile(
            title: const Text('Mode Sombre'),
            subtitle: const Text(
              'Change l\'apparence de l\'application (Mode Clair/Sombre).',
            ),
            value: isDarkMode,
            onChanged: (bool value) {
              settingsProvider.toggleThemeMode(value);
            },
          ),
          const Divider(),

          // 3. Maximum de Tâches pour Aujourd'hui
          ListTile(
            title: const Text('Maximum de Tâches pour Aujourd\'hui'),
            subtitle: const Text('Nombre maximum de tâches autorisées (1-20).'),
            trailing: SizedBox(
              width: 60,
              child: TextFormField(
                // Controller manages the display value
                controller: maxTasksController,
                // FocusNode detects loss of focus
                focusNode: maxTasksFocusNode,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                ),
                // Handles submission via "Enter" key
                onFieldSubmitted: (value) {
                  _submitMaxTasks(context, settingsProvider, value);
                },
                // Ensures the focus listener works when tapping outside
                onTapOutside: (event) {
                  maxTasksFocusNode.unfocus();
                },
              ),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
