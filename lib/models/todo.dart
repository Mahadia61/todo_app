enum TodoCategory { work, personal, study, shopping, health }

class Todo {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TodoCategory category;
  bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    required this.category,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'category': category.name,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      category: TodoCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TodoCategory.work,
      ),
      isCompleted: map['isCompleted'] == 1,
    );
  }
}