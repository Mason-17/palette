import 'package:flutter/foundation.dart';
import '../models/palette_models.dart';
import '../services/palette_storage_service.dart';

/// Manages the state of all color palettes in the app
class PaletteProvider extends ChangeNotifier {
  final PaletteStorageService _storageService = PaletteStorageService();
  
  List<ColorPalette> _palettes = [];
  bool _isLoading = false;
  
  /// Get all palettes
  List<ColorPalette> get palettes => _palettes;
  
  /// Check if data is currently loading
  bool get isLoading => _isLoading;
  
  /// Load all palettes from storage
  Future<void> loadPalettes() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _palettes = await _storageService.getAllPalettes();
      // Sort by most recently updated
      _palettes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      print('Error loading palettes: $e');
      _palettes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Add a new palette
  Future<void> addPalette(ColorPalette palette) async {
    try {
      await _storageService.savePalette(palette);
      _palettes.insert(0, palette); // Add to beginning (most recent)
      notifyListeners();
    } catch (e) {
      print('Error adding palette: $e');
      rethrow;
    }
  }
  
  /// Update an existing palette
  Future<void> updatePalette(ColorPalette palette) async {
    try {
      // Update the updatedAt timestamp
      final updatedPalette = palette.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _storageService.savePalette(updatedPalette);
      
      // Update in local list
      final index = _palettes.indexWhere((p) => p.id == updatedPalette.id);
      if (index != -1) {
        _palettes[index] = updatedPalette;
        // Move to top since it was just updated
        final temp = _palettes.removeAt(index);
        _palettes.insert(0, temp);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error updating palette: $e');
      rethrow;
    }
  }
  
  /// Delete a palette
  Future<void> deletePalette(String id) async {
    try {
      await _storageService.deletePalette(id);
      _palettes.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting palette: $e');
      rethrow;
    }
  }
  
  /// Get a single palette by ID
  ColorPalette? getPaletteById(String id) {
    try {
      return _palettes.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Create a new empty palette with default values
  ColorPalette createNewPalette({String name = 'New Palette'}) {
    final now = DateTime.now();
    return ColorPalette(
      id: IdGenerator.generate(),
      name: name,
      colors: [],
      createdAt: now,
      updatedAt: now,
    );
  }
  
  /// Add a color to a palette
  Future<void> addColorToPalette(String paletteId, PaletteColor color) async {
    final palette = getPaletteById(paletteId);
    if (palette == null) return;
    
    final updatedPalette = palette.copyWith(
      colors: [...palette.colors, color],
    );
    
    await updatePalette(updatedPalette);
  }
  
  /// Remove a color from a palette
  Future<void> removeColorFromPalette(String paletteId, String colorId) async {
    final palette = getPaletteById(paletteId);
    if (palette == null) return;
    
    final updatedColors = palette.colors.where((c) => c.id != colorId).toList();
    final updatedPalette = palette.copyWith(colors: updatedColors);
    
    await updatePalette(updatedPalette);
  }
  
  /// Update a color in a palette
  Future<void> updateColorInPalette(
    String paletteId,
    String colorId,
    PaletteColor newColor,
  ) async {
    final palette = getPaletteById(paletteId);
    if (palette == null) return;
    
    final updatedColors = palette.colors.map((c) {
      return c.id == colorId ? newColor : c;
    }).toList();
    
    final updatedPalette = palette.copyWith(colors: updatedColors);
    await updatePalette(updatedPalette);
  }
}