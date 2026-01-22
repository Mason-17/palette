import 'dart:convert';
import 'package:flutter/material.dart';

/// Represents a single color in a palette
class PaletteColor {
  final String id;
  final Color color;
  final String? name; // Optional name for the color

  PaletteColor({
    required this.id,
    required this.color,
    this.name,
  });

  // Convert Color to hex string for storage
  String get hexString {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  // Create from hex string
  static Color colorFromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hex': hexString,
      'name': name,
    };
  }

  factory PaletteColor.fromJson(Map<String, dynamic> json) {
    return PaletteColor(
      id: json['id'] as String,
      color: colorFromHex(json['hex'] as String),
      name: json['name'] as String?,
    );
  }

  PaletteColor copyWith({
    String? id,
    Color? color,
    String? name,
  }) {
    return PaletteColor(
      id: id ?? this.id,
      color: color ?? this.color,
      name: name ?? this.name,
    );
  }
}

/// Represents a color palette with multiple colors
class ColorPalette {
  final String id;
  final String name;
  final List<PaletteColor> colors;
  final DateTime createdAt;
  final DateTime updatedAt;

  ColorPalette({
    required this.id,
    required this.name,
    required this.colors,
    required this.createdAt,
    required this.updatedAt,
  });

  // Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colors': colors.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ColorPalette.fromJson(Map<String, dynamic> json) {
    return ColorPalette(
      id: json['id'] as String,
      name: json['name'] as String,
      colors: (json['colors'] as List)
          .map((c) => PaletteColor.fromJson(c as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory ColorPalette.fromJsonString(String jsonString) {
    return ColorPalette.fromJson(jsonDecode(jsonString));
  }

  ColorPalette copyWith({
    String? id,
    String? name,
    List<PaletteColor>? colors,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ColorPalette(
      id: id ?? this.id,
      name: name ?? this.name,
      colors: colors ?? this.colors,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Helper to generate unique IDs
class IdGenerator {
  static String generate() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}