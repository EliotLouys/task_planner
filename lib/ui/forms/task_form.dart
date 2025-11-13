// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zbeub_task_plan/data/enums.dart';
import 'package:zbeub_task_plan/data/tasks.dart';
import 'package:zbeub_task_plan/theme/app_theme.dart';
import 'package:zbeub_task_plan/ui/forms/matrix_change_form.dart';

// Function to show the bottom sheet
void showTaskFormModal(
  BuildContext context, {
  required TasksCategories initialCategory,
  required ImportanceLevel initialImportanceString,
  required UrgencyLevel initialUrgencyString,
  Tasks? taskToEdit, 

}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows the sheet to take up more space
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return TaskFormModal(
        initialCategory: initialCategory,
        initialImportanceString: initialImportanceString,
        initialUrgencyString: initialUrgencyString,
        taskToEdit: taskToEdit,
      );
    },
  );
}

class TaskFormModal extends StatefulWidget {
  const TaskFormModal({
    super.key,
    required this.initialCategory,
    required this.initialImportanceString,
    required this.initialUrgencyString,
    this.taskToEdit, 
  });

  final TasksCategories initialCategory;
  final ImportanceLevel initialImportanceString;
  final UrgencyLevel initialUrgencyString;
  final Tasks? taskToEdit;
  
  @override
  State<TaskFormModal> createState() => _TaskFormModalState();
}

class _TaskFormModalState extends State<TaskFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  late UrgencyLevel _selectedUrgency;
  late ImportanceLevel _selectedImportance;
  late TasksCategories _selectedCategory;

  bool get isEditing => widget.taskToEdit != null; // Helper to check mode

  Future<void> _selectDateAndTime(BuildContext context) async {
    // 1. Pick Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate == null) return;

    // 2. Pick Time (only if a date was picked)
    // Use the time component of the current _selectedDate as initial time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );

    if (pickedTime != null) {
      setState(() {
        // Combine the date and the selected time
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    } else {
      // If time is not picked, set time to 00:00 or current time
       setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final task = widget.taskToEdit!;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedDate = task.dueDate;
      _selectedCategory = task.category;
      _selectedUrgency = task.isUrgent;
      _selectedImportance = task.isImportant;
    } else {
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      _selectedCategory = widget.initialCategory;
      _selectedUrgency = widget.initialUrgencyString;
      _selectedImportance = widget.initialImportanceString;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }



  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final task = Tasks(
        id: isEditing ? widget.taskToEdit!.id : null, 
        isCompleted: isEditing ? widget.taskToEdit!.isCompleted : false,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _selectedDate,
        category: widget.taskToEdit?.category ?? _selectedCategory,
        isImportant: widget.taskToEdit?.isImportant ?? _selectedImportance,
        isUrgent: widget.taskToEdit?.isUrgent ?? _selectedUrgency,
      );

      // Use the appropriate provider method
      if (isEditing) {
        context.read<TasksProvider>().updateTask(task);
      } else {
        context.read<TasksProvider>().addTask(task);
      }

      Navigator.pop(context);
    }
  }

  void _launchMatrixChangeForm() {
    if (widget.taskToEdit != null) {
      // 1. Close the current task form (crucial for good UX)
      Navigator.pop(context); 
      
      // 2. Launch the new modal with the task to be updated
      showMatrixChangeModal(
        context,
        taskToUpdate: widget.taskToEdit!,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // Determine the space needed when the keyboard is open
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    final displayTask = widget.taskToEdit ?? Tasks(
      title: 'N/A', 
      description: '',
      dueDate: _selectedDate,
      category: _selectedCategory,
      isImportant: _selectedImportance,
      isUrgent: _selectedUrgency,
    );

    // Get the color for the display box
    final quadrantColor = AppTheme.getQuadrantColor(
      importance: displayTask.isImportant, 
      urgency: displayTask.isUrgent,
    );
    
    return Padding(
      // Ensure the content is visible above the keyboard
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        padding: const EdgeInsets.all(24),
        // Ensures minimal size is based on content
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Essential for modal bottom sheet
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Nouvelle Tâche',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // 1. Title Input
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Titre de la tâche',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un titre.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // 2. Description Input
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optionnel)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Due Date Picker
                ListTile(
                  title: Text('Échéance: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} ${_selectedDate.hour}:${_selectedDate.minute}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDateAndTime(context),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),

                // 4. Matrix Info (Non-editable as it's passed from the quadrant)
                InkWell(
                  onTap: isEditing ? _launchMatrixChangeForm : null, // Only clickable when editing
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: quadrantColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: isEditing 
                        ? Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1)
                        : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEditing ? 'Catégories (Cliquer pour changer)' : 'Catégories ', 
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Catégorie: ${getTasksCategoryName(displayTask.category)}'),
                        Text('Importance: ${getImportanceLevelName(displayTask.isImportant)}'),
                        Text('Urgence: ${getUrgencyLevelName(displayTask.isUrgent)}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // 5. Submit Button
                ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.check),
                  label: const Text('Ajouter la Tâche'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
