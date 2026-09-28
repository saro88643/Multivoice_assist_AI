class HistoryModel {
  final int? id;
  final String question;
  final String answer;
  final String dateTime;

  HistoryModel({
    this.id,
    required this.question,
    required this.answer,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'dateTime': dateTime,
    };
  }

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      id: map['id'] as int?,
      question: map['question']?.toString() ?? '',
      answer: map['answer']?.toString() ?? '',
      dateTime: map['dateTime']?.toString() ?? '',
    );
  }

  HistoryModel copyWith({
    int? id,
    String? question,
    String? answer,
    String? dateTime,
  }) {
    return HistoryModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
