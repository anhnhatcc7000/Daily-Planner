import 'package:flutter/material.dart';
import 'package:notifications_tut/DBhelper/db_helper.dart';
import 'package:notifications_tut/models/task.model.dart';
import 'package:pie_chart/pie_chart.dart';


class TaskStatisticsScreen extends StatefulWidget {
  const TaskStatisticsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TaskStatisticsScreenState createState() => _TaskStatisticsScreenState();
}

class _TaskStatisticsScreenState extends State<TaskStatisticsScreen> {
  final DBHelper _dbHelper = DBHelper();

  Map<String, double> _taskData = {
    "Tạo mới": 0,
    "Thực hiện": 0,
    "Thành công": 0,
    "Kết thúc": 0,
  };

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTaskStatistics(); 
  }

  Future<void> _loadTaskStatistics() async {
    List<Task> tasks = await _dbHelper.getTasks(); 

    int newTasks = tasks.where((task) => task.status == 'Tạo mới').length;
    int inProgressTasks = tasks.where((task) => task.status == 'Thực hiện').length;
    int successfulTasks = tasks.where((task) => task.status == 'Thành công').length;
    int finishedTasks = tasks.where((task) => task.status == 'Kết thúc').length;

    setState(() {
      _taskData = {
        "Tạo mới": newTasks.toDouble(),
        "Thực hiện": inProgressTasks.toDouble(),
        "Thành công": successfulTasks.toDouble(),
        "Kết thúc": finishedTasks.toDouble(),
      };
      _isLoading = false; 
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorList = <Color>[
      Colors.blue,   
      Colors.orange, 
      Colors.green, 
      Colors.purple,
    ];

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
        title: const Text('Thống kê công việc', style: TextStyle(color: Colors.white),)
        ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: PieChart(
                      dataMap: _taskData,
                      animationDuration: const Duration(milliseconds: 800),
                      chartLegendSpacing: 32,
                      chartRadius: MediaQuery.of(context).size.width / 2,
                      colorList: colorList,
                      initialAngleInDegree: 0,
                      chartType: ChartType.ring,
                      ringStrokeWidth: 32,
                      centerText: "Công việc",
                      legendOptions: const LegendOptions(
                        showLegendsInRow: false,
                        legendPosition: LegendPosition.right,
                        showLegends: true,
                        legendShape: BoxShape.circle,
                        legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      chartValuesOptions: const ChartValuesOptions(
                        showChartValueBackground: true,
                        showChartValues: true,
                        showChartValuesInPercentage: true,
                        showChartValuesOutside: false,
                        decimalPlaces: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
