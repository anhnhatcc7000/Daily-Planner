import 'package:flutter/material.dart';
import 'package:notifications_tut/Calendar/task.detail.screen.dart';
import 'package:notifications_tut/DBhelper/db_helper.dart';
import 'package:notifications_tut/models/task.model.dart';

class DragDropTaskListScreen extends StatefulWidget {
  const DragDropTaskListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DragDropTaskListScreenState createState() => _DragDropTaskListScreenState();
}

class _DragDropTaskListScreenState extends State<DragDropTaskListScreen> {
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
      _tasks = tasks..sort((a, b) => a.priority.compareTo(b.priority));
    });
  }

  void _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Task movedTask = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, movedTask);
    });

    for (int i = 0; i < _tasks.length; i++) {
      final updatedTask = _tasks[i];
      updatedTask.priority = i + 1;
      await _dbHelper.updateTask(updatedTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
        title: const Text('Danh sách công việc (Kéo thả)', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blueAccent,
      ),
      body: _tasks.isEmpty
          ? const Center(
              child: Text(
                'Không có công việc nào.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              child: ReorderableListView(
                onReorder: _onReorder,
                children: _tasks.map((task) {
                  return Card(
                    key: ValueKey(task.id),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailScreen(
                          task: task,
                          refreshTaskList: _loadTasks,
                        ),
                      ),
                    );
                      },
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        task.content,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4.0),
                          Text(
                            "Thời gian: ${task.time}",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            "Ngày: ${task.date}",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4.0),
                          Row(
                            children: [
                              const Text("Trạng thái: "),
                              _buildStatusIndicator(task.status),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.drag_handle, color: Colors.blueAccent),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'Thành công' || 'Tạo mới':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'Thực hiện':
        statusColor = Colors.orange;
        statusIcon = Icons.sync_alt;
        break;
      default:
        statusColor = Colors.red;
        statusIcon = Icons.error_outline;
        break;
    }

    return Row(
      children: [
        Icon(statusIcon, color: statusColor, size: 18),
        const SizedBox(width: 4),
        Text(
          status,
          style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
