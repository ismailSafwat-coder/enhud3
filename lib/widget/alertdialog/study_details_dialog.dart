import 'package:flutter/material.dart';

class StudyDetailsDialog extends StatefulWidget {
  final String unitTitle;
  final List<Map<String, dynamic>> tasks;
  final Function(List<Map<String, dynamic>> updatedTasks) onUpdate;

  const StudyDetailsDialog({
    super.key,
    required this.unitTitle,
    required this.tasks,
    required this.onUpdate,
  });

  @override
  _StudyDetailsDialogState createState() => _StudyDetailsDialogState();
}

class _StudyDetailsDialogState extends State<StudyDetailsDialog> {
  late List<Map<String, dynamic>> _currentTasks;
  final TextEditingController _newTaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentTasks = List<Map<String, dynamic>>.from(
      widget.tasks.map((task) => Map<String, dynamic>.from(task)),
    );
  }

  void _addNewTask() {
    if (_newTaskController.text.trim().isNotEmpty) {
      setState(() {
        _currentTasks.add({
          'title': _newTaskController.text.trim(),
          'done': false,
        });
        _newTaskController.clear();
      });
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Task"),
          content: TextField(
            controller: _newTaskController,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Enter task name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _addNewTask();
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('• ${widget.unitTitle} :',
          textAlign: TextAlign.left,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _currentTasks.length,
          itemBuilder: (context, index) {
            final task = _currentTasks[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                task['title'],
                style: TextStyle(
                  decoration: task['done'] ? TextDecoration.lineThrough : null,
                ),
              ),
              leading: Checkbox(
                value: task['done'],
                onChanged: (bool? value) {
                  setState(() {
                    _currentTasks[index]['done'] = value!;
                  });
                },
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _currentTasks.removeAt(index);
                  });
                },
              ),
            );
          },
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsPadding: const EdgeInsets.only(bottom: 12.0),
      actions: [
        TextButton(
          onPressed: _showAddTaskDialog,
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue.withOpacity(0.1),
          ),
          child: const Text("New"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onUpdate(_currentTasks);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, foregroundColor: Colors.white),
          child: const Text("Done"),
        ),
      ],
    );
  }
}
