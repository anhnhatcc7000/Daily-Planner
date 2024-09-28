import 'package:flutter/material.dart';
import 'package:notifications_tut/DBhelper/db_helper.dart';
import 'package:notifications_tut/models/task.model.dart';
import 'package:notifications_tut/notification/notification.dart';

class AddNewTaskScreen extends StatefulWidget {
  final Task? task; // Nếu có Task thì là chỉnh sửa, nếu null thì là thêm mới
  final Function refreshTaskList;

  const AddNewTaskScreen({super.key, this.task, required this.refreshTaskList});

  @override
  // ignore: library_private_types_in_public_api
  _AddNewTaskScreenState createState() => _AddNewTaskScreenState();
}

class _AddNewTaskScreenState extends State<AddNewTaskScreen> {
  DateTime? _selectedDate;
  final _taskController = TextEditingController();
  final _locationController = TextEditingController();
  final _leaderController = TextEditingController();
  final _noteController = TextEditingController();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String _selectedStatus = 'Tạo mới';
  final List<String> _statusOptions = [
    'Tạo mới',
    'Thực hiện',
    'Thành công',
    'Kết thúc'
  ];

  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _taskController.text = widget.task!.content;
      _locationController.text = widget.task!.location;
      _leaderController.text = widget.task!.leader;
      _noteController.text = widget.task!.note;
      _selectedStatus = widget.task!.status;
      // Format ngày
      String originalDate = widget.task!.date;
      List<String> dateParts = originalDate.split('/');
      String formattedDate =
          "${dateParts[2]}-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}";
      _selectedDate = DateTime.parse(formattedDate);

      List<String> timeParts = widget.task!.time.split('->');
      _startTime = _parseTimeOfDay(timeParts[0]);
      _endTime = _parseTimeOfDay(timeParts[1]);
    }
  }

  TimeOfDay _parseTimeOfDay(String time) {
  final parts = time.split(' ').where((part) => part.trim().isNotEmpty).toList();
  
  // Kiểm tra nếu không có "AM/PM" (định dạng 24 giờ)
  if (parts.length == 1) {
    final timeParts = parts[0].split(':');
    if (timeParts.length < 2) {
      throw FormatException('Invalid time format: $time');
    }

    int hour = int.parse(timeParts[0].trim());
    final int minute = int.parse(timeParts[1].trim());

    return TimeOfDay(hour: hour, minute: minute);
  }

  // Nếu có "AM/PM", xử lý định dạng 12 giờ
  if (parts.length < 2) throw FormatException('Invalid time format: $time');

  final timeParts = parts[0].split(':');
  if (timeParts.length < 2) {
    throw FormatException('Invalid time format: $time');
  }

  int hour = int.parse(timeParts[0].trim());
  final int minute = int.parse(timeParts[1].trim());

  if (parts[1].toUpperCase() == 'PM' && hour != 12) {
    hour += 12;
  } else if (parts[1].toUpperCase() == 'AM' && hour == 12) {
    hour = 0;
  }

  return TimeOfDay(hour: hour, minute: minute);
}


  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

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

  Future<void> _saveTask() async {
    Task task;

    if (widget.task == null) {
      // Nếu là nhiệm vụ mới
      task = Task(
        date: _selectedDate != null
            ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
            : '',
        content: _taskController.text,
        time: _startTime != null && _endTime != null
            ? "${_startTime!.format(context)} -> ${_endTime!.format(context)}"
            : '',
        location: _locationController.text,
        leader: _leaderController.text,
        note: _noteController.text,
        status: _selectedStatus,
        // isReminderEnabled: 1,
        // reminderTime: 0,
      );
      int taskId = await _dbHelper.insertTask(task);
      task = task.copyWith(id: taskId);
    } else {
      task = widget.task!.copyWith(
        date: _selectedDate != null
            ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
            : '',
        content: _taskController.text,
        time: _startTime != null && _endTime != null
            ? "${_startTime!.format(context)} -> ${_endTime!.format(context)}"
            : '',
        location: _locationController.text,
        leader: _leaderController.text,
        note: _noteController.text,
        status: _selectedStatus,
        // isReminderEnabled: 1,
        // reminderTime: 0,
      );
      await _dbHelper.updateTask(task);
    }

    // Lên lịch thông báo
    // await showImmediateNotification(task);
    // await scheduleNotification(task, task.reminderTime);
    // await scheduleExactNotification(task); 
    await NotificationService.scheduleNotification(task);


    widget.refreshTaskList();
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'Chọn giờ';
    return time.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          widget.task == null ? 'Thêm công việc mới' : 'Chỉnh sửa công việc',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text('Ngày tháng:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Text(
                    _selectedDate != null
                        ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                        : 'Chọn ngày',
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.blue),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Nội dung công việc',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _taskController,
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
                      child: Text(_formatTimeOfDay(_startTime),
                          style: const TextStyle(fontSize: 16)),
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
                      child: Text(_formatTimeOfDay(_endTime),
                          style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Địa điểm',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Nhập địa điểm',
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
              const SizedBox(height: 16),
              const Text('Trạng thái kiểm duyệt',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _selectedStatus,
                isExpanded: true,
                items: _statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status, style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () async {
                    await _saveTask();
                  },
                  child: Text(
                    widget.task == null
                        ? 'Lưu công việc'
                        : 'Cập nhật công việc',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
