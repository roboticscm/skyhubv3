import 'package:flutter/material.dart';

enum AppTheme { suntechLight, suntechDark, greenLight, greenDart, blueLight, blueDart, redLight, redDart }

const bodyTextTheme = TextTheme(
  button: TextStyle(fontSize: 18),

);

final appThemeData = {
  AppTheme.suntechLight: ThemeData(secondaryHeaderColor: const Color(0xFF00abbf).withBlue(230).withGreen(230).withRed(230), accentColor: Colors.red, brightness: Brightness.light, primaryColor: const Color(0xFF00abbf), textTheme: bodyTextTheme),
  AppTheme.suntechDark: ThemeData(secondaryHeaderColor: const Color(0xFF03727f).withBlue(230).withGreen(230).withRed(230), accentColor: Colors.red, brightness: Brightness.dark, primaryColor: const Color(0xFF03727f), textTheme: bodyTextTheme),
  
  AppTheme.greenLight: ThemeData(secondaryHeaderColor: Colors.green.withBlue(230).withGreen(230).withRed(230), accentColor: Colors.red, brightness: Brightness.light, primaryColor: Colors.green, textTheme: bodyTextTheme),
  AppTheme.greenDart: ThemeData(secondaryHeaderColor: Colors.green.withBlue(230).withGreen(230).withRed(230), accentColor: Colors.red, brightness: Brightness.dark, primaryColor: Colors.green[700], textTheme: bodyTextTheme),
  
  AppTheme.blueLight: ThemeData(accentColor: Colors.red, brightness: Brightness.light, primaryColor: Colors.blue, textTheme: bodyTextTheme),
  AppTheme.blueDart: ThemeData(accentColor: Colors.red, brightness: Brightness.dark, primaryColor: Colors.blue[700], textTheme: bodyTextTheme),
  
  AppTheme.redLight: ThemeData(accentColor: Colors.red, brightness: Brightness.light, primaryColor: Colors.red, textTheme: bodyTextTheme),
  AppTheme.redDart: ThemeData(accentColor: Colors.red, brightness: Brightness.dark, primaryColor: Colors.red[700], textTheme: bodyTextTheme),
};
