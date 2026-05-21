class SchoolClass {
  final String id;
  final String teacherId;
  final String name;
  final DateTime createdAt;
  final String studentSortPreference;

  SchoolClass({
    required this.id,
    required this.teacherId,
    required this.name,
    required this.createdAt,
    this.studentSortPreference = 'custom',
  });

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return SchoolClass(
      id: json['id'] as String,
      teacherId: json['teacher_id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      studentSortPreference: json['student_sort_preference'] as String? ?? 'custom',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacher_id': teacherId,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'student_sort_preference': studentSortPreference,
    };
  }
}
