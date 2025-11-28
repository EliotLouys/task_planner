enum TasksCategories { personal, professional }

String getTasksCategoryName(TasksCategories category) {
  switch (category) {
    case TasksCategories.personal:
      return 'Tâches persos';
    case TasksCategories.professional:
      return 'Tâches pro';
  }
}

enum ImportanceLevel { important, notImportant }

String getImportanceLevelName(ImportanceLevel level) {
  switch (level) {
    case ImportanceLevel.important:
      return 'Important';
    case ImportanceLevel.notImportant:
      return 'Pas important';
  }
}

enum UrgencyLevel { urgent, notUrgent }

String getUrgencyLevelName(UrgencyLevel level) {
  switch (level) {
    case UrgencyLevel.urgent:
      return 'Urgent';
    case UrgencyLevel.notUrgent:
      return 'Pas urgent';
  }
}

enum ReminderValues {
  none,
  thirtyMinutesBefore,
  oneHourBefore,
  twoHoursBefore,
  oneDayBefore,
}

String getReminderValueName(ReminderValues value) {
  switch (value) {
    case ReminderValues.none:
      return 'Aucun rappel';
    case ReminderValues.thirtyMinutesBefore:
      return '30 minutes avant';
    case ReminderValues.oneHourBefore:
      return '1 heure avant';
    case ReminderValues.twoHoursBefore:
      return '2 heures avant';
    case ReminderValues.oneDayBefore:
      return '1 jour avant';
  }
}

enum AppThemeMode { light, dark, system }
