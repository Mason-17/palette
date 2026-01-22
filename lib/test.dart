//import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

import 'classes/color.dart';
import 'classes/palette.dart';
import 'dart:io';

void main() {
  print("Hi!");

  Color a = Color("apple red");
  a.red = 255;
  a.blue = 0;
  a.green = 0;

  a.save();

  String name = "apple red";
  
}





