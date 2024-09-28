import 'package:flutter/material.dart';
import 'package:notifications_tut/Setting/theme.provider.dart';
import 'package:provider/provider.dart';

class CustomizableUIScreen extends StatelessWidget {
  const CustomizableUIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
        title: const Text('Tùy chỉnh giao diện',style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn màu chủ đạo:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _colorOption(context, Colors.blue, themeProvider),
                _colorOption(context, Colors.purple, themeProvider),
                _colorOption(context, Colors.red, themeProvider),
                _colorOption(context, Colors.green, themeProvider),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Chọn font chữ:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: themeProvider.fontFamily,
              onChanged: (String? newFont) {
                if (newFont != null) {
                  themeProvider.setFontFamily(newFont);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: 'Roboto',
                  child: Text('Roboto'),
                ),
                DropdownMenuItem(
                  value: 'Lobster',
                  child: Text('Lobster'),
                ),
                DropdownMenuItem(
                  value: 'Montserrat',
                  child: Text('Montserrat'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Center(
            //   child: ElevatedButton(
            //     onPressed: () {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(content: Text('Giao diện đã được cập nhật!')),
            //       );
            //     },
            //     child: const Text('Lưu cài đặt', style: TextStyle(color: Colors.white),),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _colorOption(BuildContext context, Color color, ThemeProvider provider) {
    return GestureDetector(
      onTap: () {
        provider.setPrimaryColor(color); 
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: provider.primaryColor == color ? Colors.black : Colors.transparent,
            width: 3,
          ),
        ),
      ),
    );
  }
}
