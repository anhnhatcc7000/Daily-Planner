import 'package:flutter/material.dart';
import 'package:notifications_tut/DBhelper/db_helper.dart';
import 'package:notifications_tut/Task/new.task.screen.dart';
import 'package:notifications_tut/models/task.model.dart';


class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _refreshTaskList();
  }

  void _refreshTaskList() async {
    final tasks = await _dbHelper.getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Danh sách công việc',
          style: TextStyle(color: Colors.white),
        ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: task.status == 'Thành công'
                                          ? Colors.green
                                          : task.status == 'Thực hiện'
                                              ? Colors.orange
                                              : Colors.grey,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      task.content,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Ngày: ${task.date}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Thời gian: ${task.time}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Trạng thái: ${task.status}',
                                  style: TextStyle(
                                    color: task.status == 'Thành công' || task.status == 'Tạo mới'
                                        ? Colors.green
                                        : task.status == 'Thực hiện'
                                            ? Colors.orange
                                            : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddNewTaskScreen(
                                        task: task,
                                        refreshTaskList: _refreshTaskList,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final shouldDelete =
                                      await _showDeleteConfirmationDialog();
                                  if (shouldDelete) {
                                    await _dbHelper.deleteTask(task.id!);
                                    _refreshTaskList();
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddNewTaskScreen(refreshTaskList: _refreshTaskList)),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return (await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Xóa công việc'),
              content:
                  const Text('Bạn có chắc chắn muốn xóa công việc này không?'),
              actions: [
                TextButton(
                  child:
                      const Text('Hủy', style: TextStyle(color: Colors.black)),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(),
                  child:
                      const Text('Xóa', style: TextStyle(color: Colors.white)),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        )) ??
        false;
  }
}
