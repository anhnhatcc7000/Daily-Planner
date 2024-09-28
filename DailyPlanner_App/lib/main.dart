import 'package:flutter/material.dart';
import 'package:notifications_tut/Setting/theme.provider.dart';
import 'package:notifications_tut/welcome.login/welcome.screen.dart';
import 'package:provider/provider.dart';
import 'notification/notification.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  tz.initializeTimeZones();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.currentThemeMode,
      theme: themeProvider.currentTheme,
      darkTheme: themeProvider.darkTheme,
      home: const WelcomeScreen(),
    );
  }
}


