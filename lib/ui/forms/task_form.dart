import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zbeub_task_plan/data/enums.dart';
import 'package:zbeub_task_plan/data/tasks.dart';


// Function to show the bottom sheet
void showTaskFormModal(
  BuildContext context, {
  required TasksCategories initialCategory,
  required ImportanceLevel initialImportanceString,
  required UrgencyLevel initialUrgencyString,
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
  });

  final TasksCategories initialCategory;
  final ImportanceLevel initialImportanceString;
  final UrgencyLevel initialUrgencyString;

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

  @override
  void initState() {
    super.initState();
    // Initialize fields based on the selected matrix quadrant (passed from TaskPage)
    _selectedCategory = widget.initialCategory;
    _selectedUrgency = widget.initialUrgencyString;
    _selectedImportance = widget.initialImportanceString;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Handles displaying the Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Handles form submission
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newTask = Tasks(
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _selectedDate,
        category: _selectedCategory,
        isImportant: _selectedImportance,
        isUrgent: _selectedUrgency,
      );

      // Use context.read to access the provider for a one-time write operation
      context.read<TasksProvider>().addTask(newTask);

      // Close the bottom sheet
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the space needed when the keyboard is open
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

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
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optionnel)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Due Date Picker
                ListTile(
                  title: Text('Échéance: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),

                // 4. Matrix Info (Non-editable as it's passed from the quadrant)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Catégorie: ${getTasksCategoryName(_selectedCategory)}', 
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Importance: ${getImportanceLevelName(widget.initialImportanceString)}',
                        style: const TextStyle(color: Colors.black54)),
                      Text('Urgence: ${getUrgencyLevelName(widget.initialUrgencyString)}',
                        style: const TextStyle(color: Colors.black54)),
                    ],
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
