import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(todo.id),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggle();
          return false; // Keep item visible, just toggle status
        } else {
          onDelete();
          return true; // Remove item
        }
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          onTap: onEdit,
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (_) => onToggle(),
            activeColor: theme.colorScheme.primary,
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Row(
            children: [
              Chip(
                label: Text(
                  todo.category.name.toUpperCase(),
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
                backgroundColor: _getCategoryColor(todo.category),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 8),
              Icon(Icons.calendar_today, size: 12, color: theme.hintColor),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM d, yyyy').format(todo.dueDate),
                style: TextStyle(fontSize: 12, color: theme.hintColor),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
            onPressed: onEdit,
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(TodoCategory category) {
    return switch (category) {
      TodoCategory.work => Colors.blue,
      TodoCategory.personal => Colors.purple,
      TodoCategory.study => Colors.orange,
      TodoCategory.shopping => Colors.green,
      TodoCategory.health => Colors.pink,
    };
  }
}