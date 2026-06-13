import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences as our persistent offline storage
  final prefs = await SharedPreferences.getInstance();

  runApp(BusinessMoneyManagerApp(prefs: prefs));
}
