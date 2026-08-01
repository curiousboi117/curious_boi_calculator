class Calculation {
  final String id;
  final String expression;
  final String result;
  final DateTime timestamp;
  final bool isFavorite;

  Calculation({
    required this.id,
    required this.expression,
    required this.result,
    required this.timestamp,
    this.isFavorite = false,
  });

  Calculation copyWith({
    String? id,
    String? expression,
    String? result,
    DateTime? timestamp,
    bool? isFavorite,
  }) {
    return Calculation(
      id: id ?? this.id,
      expression: expression ?? this.expression,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expression': expression,
      'result': result,
      'timestamp': timestamp.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory Calculation.fromJson(Map<String, dynamic> json) {
    return Calculation(
      id: json['id'] as String,
      expression: json['expression'] as String,
      result: json['result'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
