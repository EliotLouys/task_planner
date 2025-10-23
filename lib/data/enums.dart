
enum TasksCategories {
  personal,
  professional,
}

String getTasksCategoryName(TasksCategories category) {
  switch (category) {
    case TasksCategories.personal:
      return 'Tâches persos';
    case TasksCategories.professional:
      return 'Tâches pro';
  }
}

enum ImportanceLevel {
  important,
  notImportant,
}

String getImportanceLevelName(ImportanceLevel level) {
  switch (level) {
    case ImportanceLevel.important:
      return 'Important';
    case ImportanceLevel.notImportant:
      return 'Pas important';
  }
}

enum UrgencyLevel {
  urgent,
  notUrgent,
}

String getUrgencyLevelName(UrgencyLevel level) {
  switch (level) {
    case UrgencyLevel.urgent:
      return 'Urgent';
    case UrgencyLevel.notUrgent:
      return 'Pas urgent';
  }
}