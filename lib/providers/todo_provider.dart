import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

enum TodoFilter { all, pending, completed }

class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  TodoFilter _filter = TodoFilter.all;
  TodoCategory? _selectedCategory;
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  TodoProvider() {
    loadTodos();
  }

  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();
    _todos = await DatabaseService.instance.fetchTodos();
    _isLoading = false;
    notifyListeners();
  }

  List<Todo> get todos {
    return _todos.where((todo) {
      final matchesFilter = switch (_filter) {
        TodoFilter.pending => !todo.isCompleted,
        TodoFilter.completed => todo.isCompleted,
        TodoFilter.all => true,
      };
      final matchesCategory =
          _selectedCategory == null || todo.category == _selectedCategory;
      return matchesFilter && matchesCategory;
    }).toList();
  }

  List<Todo> get allTodos => List.unmodifiable(_todos);
  TodoFilter get activeFilter => _filter;
  TodoCategory? get activeCategory => _selectedCategory;

  Future<void> addTodo(Todo todo) async {
    _todos.add(todo);
    notifyListeners();
    await DatabaseService.instance.insertTodo(todo);

    // Schedule notification for task due date
    await NotificationService().scheduleNotification(
      todo.id.hashCode,
      todo.title,
      todo.dueDate,
    );
  }

  Future<void> toggleTodoStatus(String id) async {
    final index = _todos.indexWhere((item) => item.id == id);
    if (index != -1) {
      _todos[index].isCompleted = !_todos[index].isCompleted;
      notifyListeners();
      await DatabaseService.instance.updateTodo(_todos[index]);
    }
  }

  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((item) => item.id == id);
    notifyListeners();
    await DatabaseService.instance.deleteTodo(id);

    // Cancel scheduled notification if task is deleted
    await NotificationService().cancelNotification(id.hashCode);
  }

  void setFilter(TodoFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setCategoryFilter(TodoCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Analytics Helpers
  int get countCompleted => _todos.where((t) => t.isCompleted).length;
  int get countPending => _todos.where((t) => !t.isCompleted).length;

  Map<TodoCategory, int> get categoryCounts {
    final Map<TodoCategory, int> counts = {for (var c in TodoCategory.values) c: 0};
    for (var todo in _todos) {
      counts[todo.category] = (counts[todo.category] ?? 0) + 1;
    }
    return counts;
  }

  Map<int, int> get weeklyCounts {
    final Map<int, int> weekdayCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    final now = DateTime.now();
    for (var todo in _todos) {
      if (todo.dueDate.year == now.year &&
          todo.dueDate.difference(now).inDays.abs() <= 7) {
        weekdayCounts[todo.dueDate.weekday] =
            (weekdayCounts[todo.dueDate.weekday] ?? 0) + 1;
      }
    }
    return weekdayCounts;
  }
}