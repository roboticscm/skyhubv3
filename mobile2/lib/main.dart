import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skyone/global/variable.dart';
import 'package:skyone/system/register.dart';
import 'package:skyone/system/the_app/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SharedPreferences.setMockInitialValues ({});
  storage = await SharedPreferences.getInstance();

  loadSettingsFromStorage();
  registerController();
  runApp(TheApp());
}

