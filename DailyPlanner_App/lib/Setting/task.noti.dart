import 'package:flutter/material.dart';
import 'package:notifications_tut/DBhelper/db_helper.dart';
import 'package:notifications_tut/models/task.model.dart';
import 'package:notifications_tut/notification/notification.dart';

class TaskReminderScreen extends StatefulWidget {
  final Task task;

  const TaskReminderScreen({super.key, required this.task});

  @override
  _TaskReminderScreenState createState() => _TaskReminderScreenState();
}

class _TaskReminderScreenState extends State<TaskReminderScreen> {
  bool _isReminderEnabled = true; // Toggle state for enabling/disabling reminder
  int _selectedReminderTime = 0;  // Selected reminder time in minutes before the task
  final List<int> _reminderOptions = [0, 5, 10, 15, 30]; // Reminder time options
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _isReminderEnabled = widget.task.isReminderEnabled == 1;
    _selectedReminderTime = widget.task.reminderTime;
  }

  Future<void> _updateReminderStatus(bool isEnabled) async {
    Task updatedTask = Task(
      id: widget.task.id,
      date: widget.task.date,
      content: widget.task.content,
      time: widget.task.time,
      location: widget.task.location,
      leader: widget.task.leader,
      note: widget.task.note,
      status: widget.task.status,
      isReminderEnabled: isEnabled ? 1 : 0, 
      reminderTime: _selectedReminderTime,  
    );

    await _dbHelper.updateTask(updatedTask); 

    if (isEnabled) {
      await NotificationService.scheduleNotification(updatedTask); 
    }

    setState(() {
      _isReminderEnabled = isEnabled;
    });
  }

  Future<void> _saveReminder() async {
    Task updatedTask = Task(
      id: widget.task.id,
      date: widget.task.date,
      content: widget.task.content,
      time: widget.task.time,
      location: widget.task.location,
      leader: widget.task.leader,
      note: widget.task.note,
      status: widget.task.status,
      isReminderEnabled: _isReminderEnabled ? 1 : 0,
      reminderTime: _selectedReminderTime,
    );

    await _dbHelper.updateTask(updatedTask); 

    if (_isReminderEnabled) {
      await NotificationService.scheduleNotification(updatedTask); 
    }

    Navigator.pop(context, true);  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Cài đặt thông báo nhiệm vụ', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nhiệm vụ: ${widget.task.content}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bật thông báo:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Switch(
                          value: _isReminderEnabled,
                          activeColor: Colors.blueAccent,
                          onChanged: (value) {
                            _updateReminderStatus(value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chọn thời gian nhắc nhở trước:',
                      style: TextStyle(fontSize: 16),
                    ),
                    DropdownButton<int>(
                      value: _selectedReminderTime,
                      onChanged: _isReminderEnabled
                          ? (int? newValue) {
                              setState(() {
                                _selectedReminderTime = newValue!;
                              });
                            }
                          : null,
                      items: _reminderOptions.map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value phút'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _saveReminder,  
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Lưu cài đặt',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
