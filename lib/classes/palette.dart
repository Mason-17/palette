import 'color.dart';
import 'dart:io';
import 'dart:convert';

class Palette {
  String? name;

  List<Color> colors = [];

  Palette() {
    name = "New Palette";
  }

  Palette.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String;
    colors = json['colors'] as List<Color>;
  }


  void add(Color c, [List<Color>? others]) {
    colors.add(c);
    if (others != null) {
      for (Color i in others) {
        colors.add(i);
      }
    }
  }

  void remove(Color c, [List<Color>? others]) {
    colors.remove(c);
    if (others != null) {
      for (Color i in others) {
        colors.remove(i);
      }
    }
  }

  void listColors() {
    for (Color c in colors) {
      print("${c.name}");
    }
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'colors': colors,
  };



  void save() {
    var file = File("$name.palette");
    var contents = this.toJson();
    String jsonString = jsonEncode(contents);
    file.writeAsString(jsonString);
  }

  load() async {
    var file = File("$name.palette");
    final jStr = await file.readAsString();
    final Map<String, dynamic> map = jsonDecode(jStr) as Map<String, dynamic>;
    Palette.fromJson(map);
  }
}