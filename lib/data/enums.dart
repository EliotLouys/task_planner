
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