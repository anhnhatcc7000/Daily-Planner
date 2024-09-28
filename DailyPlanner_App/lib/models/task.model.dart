import 'package:intl/intl.dart';

class Task {
  final int? id;
  final String date;
  final String content;
  final String time; 
  final String location;
  final String leader;
  final String note;
  final String status;
  final int isReminderEnabled;
  final int reminderTime;
  int priority;

  Task({
    this.id,
    required this.date,
    required this.content,
    required this.time,
    required this.location,
    required this.leader,
    required this.note,
    required this.status,
    this.isReminderEnabled = 1,
    this.reminderTime = 0,
    this.priority = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'content': content,
      'time': time,
      'location': location,
      'leader': leader,
      'note': note,
      'status': status,
      'isReminderEnabled': isReminderEnabled,
      'reminderTime': reminderTime,
      'priority': priority,
    };
  }

  Task copyWith({
    int? id,
    String? date,
    String? content,
    String? time,
    String? location,
    String? leader,
    String? note,
    String? status,
    int? isReminderEnabled,
    int? reminderTime,
    int? priority,
  }) {
    return Task(
      id: id ?? this.id,
      date: date ?? this.date,
      content: content ?? this.content,
      time: time ?? this.time,
      location: location ?? this.location,
      leader: leader ?? this.leader,
      note: note ?? this.note,
      status: status ?? this.status,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      priority: priority ?? this.priority,
    );
  }

  DateTime? getReminderDateTime() {
    try {
      DateFormat dateFormat = DateFormat("dd/MM/yyyy");
      DateTime parsedDate = dateFormat.parse(date);
      print("Parsed Date: $parsedDate");

      // Tách thời gian bắt đầu từ chuỗi "8:11 PM -> 9:00 PM" 
      String startTime = time.split(' -> ')[0]; 
      print("Start Time: $startTime");

      // Parse thời gian bắt đầu với định dạng 12 giờ (AM/PM)
      DateFormat timeFormat =
          DateFormat("h:mm a"); 
      DateTime parsedTime = timeFormat.parse(startTime);
      print("Parsed Time: $parsedTime");

      DateTime taskDateTime = DateTime(parsedDate.year, parsedDate.month,
          parsedDate.day, parsedTime.hour, parsedTime.minute);
      print("Task DateTime: $taskDateTime");

      if (isReminderEnabled == 1) {
        DateTime reminderDateTime =
            taskDateTime.subtract(Duration(minutes: reminderTime));
        print(
            "Reminder DateTime (after subtracting reminder time): $reminderDateTime");
        return reminderDateTime;
      }

      return taskDateTime;
    } catch (e) {
      print("Lỗi khi chuyển đổi thời gian: $e");
      return null;
    }
  }
}
