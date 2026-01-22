import 'dart:io';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

final asyncPrefs = SharedPreferencesAsync();

class Color {
  final String name;
  int red = 0;
  int green = 0;
  int blue = 0;

  Color(this.name);

  Color.fromJson(Map<String, dynamic> json):
    name = json['name'] as String,
    red = json['red'] as int,
    green = json['green'] as int,
    blue = json['blue'] as int;

  //Convert Color object to a MAP!!!
  Map<String, dynamic> toJson() => {
    'name': name,
    'red': red,
    'green': green,
    'blue': blue
  };

  save() async {
    //first, call jsonEncode to create map, then convert said map to a string.
    String json = jsonEncode(this);
    final file = File("$name.color");
    await file.writeAsString(json);
    print("saved!!");
  }

  static load(String n) async{
    //read string from file
    final file = File("$n.color");
    final content = await file.readAsString();
    //this next step makes a map, not a string!!
    final decoded = await jsonDecode(content);
    return decoded;
  }
}