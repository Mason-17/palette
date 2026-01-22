import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/palette_models.dart'; // Import the models we created

/// Service for persisting color palettes locally
class PaletteStorageService {
  static const String _palettesKey = 'color_palettes';
  
  /// Save a single palette
  Future<void> savePalette(ColorPalette palette) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing palettes
    final palettes = await getAllPalettes();
    
    // Find if palette with this ID already exists
    final existingIndex = palettes.indexWhere((p) => p.id == palette.id);
    
    if (existingIndex != -1) {
      // Update existing palette
      palettes[existingIndex] = palette;
    } else {
      // Add new palette
      palettes.add(palette);
    }
    
    // Convert all palettes to JSON and save
    final jsonList = palettes.map((p) => p.toJson()).toList();
    await prefs.setString(_palettesKey, jsonEncode(jsonList));
  }
  
  /// Get all saved palettes
  Future<List<ColorPalette>> getAllPalettes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_palettesKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => ColorPalette.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If there's any error parsing, return empty list
      print('Error loading palettes: $e');
      return [];
    }
  }
  
  /// Get a single palette by ID
  Future<ColorPalette?> getPaletteById(String id) async {
    final palettes = await getAllPalettes();
    try {
      return palettes.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Delete a palette
  Future<void> deletePalette(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final palettes = await getAllPalettes();
    
    // Remove the palette with matching ID
    palettes.removeWhere((p) => p.id == id);
    
    // Save updated list
    final jsonList = palettes.map((p) => p.toJson()).toList();
    await prefs.setString(_palettesKey, jsonEncode(jsonList));
  }
  
  /// Delete all palettes
  Future<void> deleteAllPalettes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_palettesKey);
  }
  
  /// Check if a palette exists
  Future<bool> paletteExists(String id) async {
    final palette = await getPaletteById(id);
    return palette != null;
  }
}