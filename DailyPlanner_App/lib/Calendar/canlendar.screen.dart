import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';  // Đảm bảo import đúng package
import 'package:notifications_tut/Calendar/task.detail.screen.dart';
import 'package:notifications_tut/DBhelper/db_helper.dart';
import 'package:notifications_tut/Setting/theme.provider.dart';
import 'package:notifications_tut/models/task.model.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<DateTime, List<Task>> _taskEvents;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _taskEvents = {};
    initializeDateFormatting('vi_VN').then((_) {
      _loadTasks();  
    });
  }

  void _loadTasks() async {
    final tasks = await _dbHelper.getTasks();
    Map<DateTime, List<Task>> events = {};

    for (var task in tasks) {
      List<String> dateParts = task.date.split('/');
      String formattedDate =
          "${dateParts[2]}-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}";
      DateTime taskDate = _getDateOnly(DateTime.parse(formattedDate));

      if (events.containsKey(taskDate)) {
        events[taskDate]!.add(task);
      } else {
        events[taskDate] = [task];
      }
    }

    setState(() {
      _taskEvents = events;
      _selectedDay = _getDateOnly(DateTime.now());
    });
  }

  DateTime _getDateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = _getDateOnly(selectedDay);
      _focusedDay = _getDateOnly(focusedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primaryColor = themeProvider.primaryColor;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Lịch công việc',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TableCalendar(
              locale: 'vi_VN',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, _getDateOnly(day)),
              eventLoader: (day) {
                return _taskEvents[_getDateOnly(day)] ?? [];
              },
              onDaySelected: _onDaySelected,
              calendarFormat: CalendarFormat.month,
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(color: primaryColor),
                outsideDaysVisible: false,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    return _buildEventMarker(day, events, primaryColor);
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: _buildTaskListForSelectedDay(primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEventMarker(DateTime day, List events, Color primaryColor) {
    return Positioned(
      bottom: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: events.map((event) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskListForSelectedDay(Color primaryColor) {
    final tasks = _taskEvents[_selectedDay] ?? [];

    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          'Không có công việc trong ngày này.',
          style: TextStyle(fontSize: 16.0, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Danh sách công việc trong ngày:',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
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
                      Text('Thời gian: ${task.time}', style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(height: 4),
                      Text(
                        'Trạng thái: ${task.status}',
                        style: TextStyle(
                          color: task.status == 'Thành công' || task.status == 'Tạo mới'
                              ? Colors.green
                              : task.status == 'Thực hiện'
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
