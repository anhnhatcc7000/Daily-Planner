import 'package:flutter/material.dart';
import 'package:notifications_tut/Setting/customizable.screen.dart';
import 'package:notifications_tut/Setting/reorderable.task.dart';
import 'package:notifications_tut/Setting/statistics.screen.dart';
import 'package:notifications_tut/Setting/task.list.screen.dart';
import 'package:notifications_tut/Setting/theme.provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cài đặt',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          Column(
            children: [
              ListTile(
                title: const Text('Thống kê công việc'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TaskStatisticsScreen(),
                    ),
                  );
                },
              ),
              const Divider(), // Add underline here
              ListTile(
                title: const Text('Chủ đề tối/sáng'),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
              ),
              const Divider(), // Add underline here
              ListTile(
                title: const Text('Tùy chỉnh giao diện'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CustomizableUIScreen(),
                    ),
                  );
                },
              ),
              const Divider(), // Add underline here
              ListTile(
                title: const Text('Thông báo nhiệm vụ'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TaskListForReminderScreen(),
                    ),
                  );
                },
              ),
              const Divider(), // Add underline here
              ListTile(
                title: const Text('Danh sách công việc kéo thả'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DragDropTaskListScreen(),
                    ),
                  );
                },
              ),
              const Divider(), 
            ],
          ),
        ],
      ),
    );
  }
}
