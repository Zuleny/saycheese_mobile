import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static final Preferences _instance = new Preferences._internal();

  factory Preferences() {
    return _instance;
  }

  Preferences._internal();

  SharedPreferences prefs;

  initPrefs() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    this.prefs = await _prefs;
  }

  get color {
    return this.prefs.getInt('color') ?? 1;
  }

  set color(int value) {
    this.prefs.setInt('color', value);
  }

  Color getColor(color) {
    switch (color) {
      case 1:
        return Colors.deepPurple[600];
        break;
      case 2:
        return Colors.deepOrangeAccent;
        break;
      case 3:
        return Colors.blue[600];
        break;
      case 4:
        return Colors.green[600];
        break;
      default:
        return Colors.teal[600];
    }
  }

  Color getSecondaryColor(color) {
    switch (color) {
      case 1:
        return Colors.deepPurple[900];
        break;
      case 2:
        return Colors.deepOrangeAccent[700];
        break;
      case 3:
        return Colors.blue[900];
        break;
      case 4:
        return Colors.green[900];
        break;
      default:
        return Colors.teal[900];
    }
  }

  getLoginBackgroundColor() {
    return [Color(0xFFFFE5B5), Color(0xFFE5CFF8), Color(0xFFC6E4F5)];
  }

  List<double> getColorFilter() {
    return [
      1,
      -0.2,
      0,
      0,
      0,
      0,
      1,
      0,
      -0.1,
      0,
      0,
      1.2,
      1,
      0.1,
      0,
      0,
      0,
      1.7,
      1,
      0
    ];
  }
}
