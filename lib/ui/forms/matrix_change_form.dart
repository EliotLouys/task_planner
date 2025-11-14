// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zbeub_task_plan/data/enums.dart';
import 'package:zbeub_task_plan/data/tasks.dart';
import 'package:zbeub_task_plan/theme/app_theme.dart';

// Function to show the bottom sheet for matrix change
void showMatrixChangeModal(
  BuildContext context, {
  required Tasks taskToUpdate,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return MatrixChangeForm(
        taskToUpdate: taskToUpdate,
      );
    },
  );
}

class MatrixChangeForm extends StatefulWidget {
  const MatrixChangeForm({
    super.key,
    required this.taskToUpdate,
  });

  final Tasks taskToUpdate;

  @override
  State<MatrixChangeForm> createState() => _MatrixChangeFormState();
}

class _MatrixChangeFormState extends State<MatrixChangeForm> {
  late ImportanceLevel _selectedImportance;
  late UrgencyLevel _selectedUrgency;
  
  @override
  void initState() {
    super.initState();
    _selectedImportance = widget.taskToUpdate.isImportant;
    _selectedUrgency = widget.taskToUpdate.isUrgent;
  }

  void _submitForm() {
    final updatedTask = Tasks(
      id: widget.taskToUpdate.id,
      title: widget.taskToUpdate.title,
      description: widget.taskToUpdate.description,
      dueDate: widget.taskToUpdate.dueDate,
      isCompleted: widget.taskToUpdate.isCompleted,
      category: widget.taskToUpdate.category,
      isImportant: _selectedImportance,
      isUrgent: _selectedUrgency,
      reminderValue: widget.taskToUpdate.reminderValue,
    );

    context.read<TasksProvider>().updateTask(updatedTask);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final quadrantColor = AppTheme.getQuadrantColor(
      importance: _selectedImportance,
      urgency: _selectedUrgency,
    );

    return Container(
      // The modal content padding
      padding: const EdgeInsets.all(24),
      // Removed the explicit maxHeight constraint here as SingleChildScrollView handles it better
      
      // FIX: Wrap the Column in SingleChildScrollView to handle overflow
      child: SingleChildScrollView(
        // The Column is now constrained by the scroll view and its content size
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Modifier la Matrice pour "${widget.taskToUpdate.title}"',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16), // Reduced height from 20

            // 1. Importance Dropdown
            DropdownButtonFormField<ImportanceLevel>(
              decoration: const InputDecoration(
                labelText: 'Importance',
                border: OutlineInputBorder(),
              ),
              value: _selectedImportance,
              items: ImportanceLevel.values.map((ImportanceLevel level) {
                return DropdownMenuItem<ImportanceLevel>(
                  value: level,
                  child: Text(getImportanceLevelName(level)),
                );
              }).toList(),
              onChanged: (ImportanceLevel? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedImportance = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 12),

            // 2. Urgency Dropdown
            DropdownButtonFormField<UrgencyLevel>(
              decoration: const InputDecoration(
                labelText: 'Urgence',
                border: OutlineInputBorder(),
              ),
              value: _selectedUrgency,
              items: UrgencyLevel.values.map((UrgencyLevel level) {
                return DropdownMenuItem<UrgencyLevel>(
                  value: level,
                  child: Text(getUrgencyLevelName(level)),
                );
              }).toList(),
              onChanged: (UrgencyLevel? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedUrgency = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16), // Reduced height from 20

            // 3. Visual Feedback
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: quadrantColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: quadrantColor, width: 1.5),
              ),
              child: Text(
                'Nouvelle position: ${getImportanceLevelName(_selectedImportance)} / ${getUrgencyLevelName(_selectedUrgency)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: quadrantColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16), // Reduced height from 20

            // 4. Submit Button
            ElevatedButton.icon(
              onPressed: _submitForm,
              icon: const Icon(Icons.change_circle),
              label: const Text('Confirmer la Matrice'),
            ),
            const SizedBox(height: 8), // Added small padding at the very bottom for safety
          ],
        ),
      ),
    );
  }
}