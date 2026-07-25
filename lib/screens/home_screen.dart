import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);

    // Apply search filter on top of existing status/category filters
    final displayedTodos = todoProvider.todos.where((todo) {
      return todo.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              )
            : const Text('Todo Dashboard'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchQuery = '';
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Filters (All / Pending / Completed)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<TodoFilter>(
              segments: const [
                ButtonSegment(value: TodoFilter.all, label: Text('All')),
                ButtonSegment(value: TodoFilter.pending, label: Text('Pending')),
                ButtonSegment(value: TodoFilter.completed, label: Text('Done')),
              ],
              selected: {todoProvider.activeFilter},
              onSelectionChanged: (selected) {
                todoProvider.setFilter(selected.first);
              },
            ),
          ),

          // Category Chips Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Categories'),
                  selected: todoProvider.activeCategory == null,
                  onSelected: (_) => todoProvider.setCategoryFilter(null),
                ),
                ...TodoCategory.values.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: FilterChip(
                      label: Text(cat.name),
                      selected: todoProvider.activeCategory == cat,
                      onSelected: (_) => todoProvider.setCategoryFilter(cat),
                    ),
                  );
                }),
              ],
            ),
          ),

          const Divider(),

          // List View
          Expanded(
            child: displayedTodos.isEmpty
                ? const Center(child: Text('No tasks found.'))
                : ListView.builder(
                    itemCount: displayedTodos.length,
                    itemBuilder: (context, index) {
                      final todo = displayedTodos[index];
                      return TodoTile(
                        todo: todo,
                        onToggle: () => todoProvider.toggleTodoStatus(todo.id),
                        onDelete: () => todoProvider.deleteTodo(todo.id),
                        onEdit: () => _showAddOrEditTodoModal(context, todo: todo),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEditTodoModal(context),
        label: const Text('New Task'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showAddOrEditTodoModal(BuildContext context, {Todo? todo}) {
    final titleController = TextEditingController(text: todo?.title ?? '');
    TodoCategory selectedCategory = todo?.category ?? TodoCategory.work;
    DateTime selectedDate = todo?.dueDate ?? DateTime.now();
    final isEditing = todo != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEditing ? 'Edit Task' : 'New Task',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TodoCategory>(
                    value: selectedCategory,
                    items: TodoCategory.values
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.name.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (cat) {
                      if (cat != null) setModalState(() => selectedCategory = cat);
                    },
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Due: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        child: const Text('Pick Date'),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isNotEmpty) {
                        final provider =
                            Provider.of<TodoProvider>(context, listen: false);
                        if (isEditing) {
                          final updatedTodo = Todo(
                            id: todo.id,
                            title: titleController.text.trim(),
                            dueDate: selectedDate,
                            category: selectedCategory,
                            isCompleted: todo.isCompleted,
                          );
                          provider.deleteTodo(todo.id);
                          provider.addTodo(updatedTodo);
                        } else {
                          provider.addTodo(
                            Todo(
                              id: DateTime.now().toString(),
                              title: titleController.text.trim(),
                              dueDate: selectedDate,
                              category: selectedCategory,
                            ),
                          );
                        }
                        Navigator.pop(ctx);
                      }
                    },
                    child: Text(isEditing ? 'Save Changes' : 'Add Task'),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}