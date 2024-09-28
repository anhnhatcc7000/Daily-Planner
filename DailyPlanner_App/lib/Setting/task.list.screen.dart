import 'package:flutter/material.dart';
import 'package:notifications_tut/DBhelper/db_helper.dart';
import 'package:notifications_tut/Setting/task.noti.dart';
import 'package:notifications_tut/models/task.model.dart';

class TaskListForReminderScreen extends StatefulWidget {
  const TaskListForReminderScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TaskListForReminderScreenState createState() =>
      _TaskListForReminderScreenState();
}

class _TaskListForReminderScreenState extends State<TaskListForReminderScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final tasks = await _dbHelper.getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Thành công' || 'Tạo mới':
        return Colors.green;
      case 'Thực hiện':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Chọn nhiệm vụ để đặt nhắc nhở',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _tasks.isEmpty
            ? const Center(
                child: Text(
                  'Không có công việc nào.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        "Nhiệm vụ: ${task.content}",
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 18, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text("Thời gian: ${task.time}",
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text("Ngày: ${task.date}",
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          Row(
                            children: [
                              const Text("Trạng thái: "),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2.0, horizontal: 6.0),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(task.status),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  task.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.notifications, color: Colors.blueAccent),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskReminderScreen(task: task),
                          ),
                        ).then((value) {
                          if (value == true) {
                            _loadTasks();
                          }
                        });
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
