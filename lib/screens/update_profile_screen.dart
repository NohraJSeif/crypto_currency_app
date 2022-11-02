import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_theme.dart';

class UpdateProfileScreen extends StatelessWidget {
  UpdateProfileScreen({super.key});

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();

  Future<void> saveData(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  void saveUserProfile() async {
    await saveData('name', name.text);
    await saveData('email', email.text);
    print("Data saved");
  }

  bool isDarkModeEnabled = AppTheme.isDarkModeEnabled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkModeEnabled ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text("Profile Update"),
      ),
      body: Column(
        children: [
          customTextField("Name", name, false),
          customTextField("Email", email, false),
          ElevatedButton(
            onPressed: () {
              saveUserProfile();
            },
            child: const Text("Save Profile"),
          )
        ],
      ),
    );
  }

  Widget customTextField(
      String title, TextEditingController controller, bool isNumericalField) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: isDarkModeEnabled ? Colors.white : Colors.grey),
          ),
          hintText: title,
          hintStyle: TextStyle(
            color: isDarkModeEnabled ? Colors.white : Colors.black,
          ),
        ),
        keyboardType: isNumericalField ? TextInputType.number : null,
      ),
    );
  }
}
