import 'package:flutter/material.dart';
import 'package:notifications_tut/DBhelper/db_helper.dart';
import 'package:notifications_tut/models/task.model.dart';


class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final Function refreshTaskList;

  const TaskDetailScreen(
      {super.key, required this.task, required this.refreshTaskList});

  @override
  // ignore: library_private_types_in_public_api
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _contentController;
  late TextEditingController _noteController;
  late TextEditingController _locationController;
  late TextEditingController _leaderController;

  final List<String> _statusOptions = [
    'Tạo mới',
    'Thực hiện',
    'Thành công',
    'Kết thúc'
  ];
  late String _selectedStatus;

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.task.content);
    _noteController = TextEditingController(text: widget.task.note);
    _locationController = TextEditingController(text: widget.task.location);
    _leaderController = TextEditingController(text: widget.task.leader);
    _selectedStatus = widget.task.status;

    // Parse thời gian từ task hiện tại
    List<String> timeParts = widget.task.time.split('->');
    _startTime = _parseTimeOfDay(timeParts[0].trim());
    _endTime = _parseTimeOfDay(timeParts[1].trim());

    _selectedDate = _parseDate(widget.task.date);
  }

  @override
  void dispose() {
    _contentController.dispose();
    _noteController.dispose();
    _locationController.dispose();
    _leaderController.dispose();
    super.dispose();
  }

  // Hàm để chọn ngày tháng
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Hàm để chọn thời gian bắt đầu
  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  // Hàm để chọn thời gian kết thúc
  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  // Hàm format thời gian cho dễ đọc
  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'Chọn giờ';
    return time.format(context);
  }

  TimeOfDay _parseTimeOfDay(String time) {
    // Tách phần giờ và phút
    final parts = time.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1].split(' ')[0]);

    // Kiểm tra xem có phần AM/PM không
    String period = 'AM'; // Mặc định là AM nếu không có phần AM/PM
    if (parts[1].contains(' ')) {
      period = parts[1].split(' ')[1]; // Lấy phần AM hoặc PM nếu có
    }

    // Chuyển đổi giờ sang hệ 24 giờ nếu là PM
    if (period == 'PM' && hour != 12) {
      hour += 12;
    }
    // Nếu là 12 AM thì chuyển giờ thành 0
    if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  // Hàm parse ngày từ chuỗi
  DateTime _parseDate(String dateString) {
    List<String> dateParts = dateString.split('/');
    return DateTime(int.parse(dateParts[2]), int.parse(dateParts[1]),
        int.parse(dateParts[0]));
  }

  // Hàm để lưu công việc
  Future<void> _updateTask() async {
    String formattedDate =
        "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
    String formattedTime =
        "${_formatTimeOfDay(_startTime)} -> ${_formatTimeOfDay(_endTime)}";

    Task updatedTask = Task(
      id: widget.task.id,
      content: _contentController.text,
      time: formattedTime,
      status: _selectedStatus,
      note: _noteController.text,
      location: _locationController.text,
      leader: _leaderController.text,
      date: formattedDate,
    );
    await _dbHelper.updateTask(updatedTask);
    widget.refreshTaskList();
    Navigator.pop(context);
  }

  Future<void> _deleteTask() async {
    await _dbHelper.deleteTask(widget.task.id!);
    widget.refreshTaskList();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Chi tiết công việc',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final shouldDelete = await _showDeleteConfirmationDialog();
              if (shouldDelete) {
                await _deleteTask();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text('Nội dung công việc',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'Nhập nội dung công việc',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Thời gian',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _selectStartTime(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _formatTimeOfDay(_startTime),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('đến', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _selectEndTime(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _formatTimeOfDay(_endTime),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Trạng thái',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                items: _statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Địa điểm',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Nhập địa điểm (vd: online)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Chủ trì',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _leaderController,
                decoration: InputDecoration(
                  hintText: 'Nhập tên người chủ trì',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Ghi chú',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: 'Nhập ghi chú',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _updateTask,
                  child: const Text('Cập nhật công việc',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
