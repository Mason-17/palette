import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/palette_provider.dart';
import '../models/palette_models.dart';

class PaletteDetailScreen extends StatefulWidget {
  final String paletteId;

  const PaletteDetailScreen({
    super.key,
    required this.paletteId,
  });

  @override
  State<PaletteDetailScreen> createState() => _PaletteDetailScreenState();
}

class _PaletteDetailScreenState extends State<PaletteDetailScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<PaletteProvider>();
    final palette = provider.getPaletteById(widget.paletteId);
    _nameController = TextEditingController(text: palette?.name ?? 'New Palette');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName(PaletteProvider provider, ColorPalette palette) async {
    if (_nameController.text.trim().isNotEmpty) {
      final updated = palette.copyWith(name: _nameController.text.trim());
      await provider.updatePalette(updated);
    }
  }

  Future<void> _addColor(PaletteProvider provider) async {
    final color = await _showColorPicker(context);
    if (color != null) {
      final paletteColor = PaletteColor(
        id: IdGenerator.generate(),
        color: color,
      );
      await provider.addColorToPalette(widget.paletteId, paletteColor);
    }
  }

  Future<Color?> _showColorPicker(BuildContext context) async {
    return showDialog<Color>(
      context: context,
      builder: (context) => const _ColorPickerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaletteProvider>(
      builder: (context, provider, child) {
        final palette = provider.getPaletteById(widget.paletteId);

        if (palette == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Palette Not Found')),
            body: const Center(child: Text('This palette no longer exists')),
          );
        }

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              _saveName(provider, palette);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Edit Palette'),
              elevation: 0,
            ),
            body: Column(
              children: [
                // Name input section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Palette Name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _saveName(provider, palette),
                    onEditingComplete: () => _saveName(provider, palette),
                  ),
                ),

                // Colors section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Colors (${palette.colors.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _addColor(provider),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Color'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Color list
                Expanded(
                  child: palette.colors.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.palette_outlined,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              const Text('No colors yet'),
                              const SizedBox(height: 8),
                              const Text(
                                'Tap "Add Color" to get started',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: palette.colors.length,
                          itemBuilder: (context, index) {
                            final color = palette.colors[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: color.color,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.3),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  color.hexString,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: color.name != null
                                    ? Text(color.name!)
                                    : null,
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: Theme.of(context).colorScheme.error,
                                  onPressed: () async {
                                    await provider.removeColorFromPalette(
                                      widget.paletteId,
                                      color.id,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Separate stateful widget for the color picker dialog
class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog();

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  double _hue = 0;
  double _saturation = 1.0;
  double _value = 1.0;
  late TextEditingController _hexController;
  bool _isUpdatingFromSliders = false;

  Color get _currentColor {
    return HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();
  }

  String get _hexString {
    return _currentColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    // Initialize controller with the hex value from initial slider positions
    _hexController = TextEditingController(text: _hexString);
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _updateFromHex(String hexValue) {
    // Remove # if present
    hexValue = hexValue.replaceAll('#', '').trim();
    
    // Validate hex (must be 6 characters)
    if (hexValue.length != 6) return;
    
    try {
      // Parse hex to color
      final color = Color(int.parse('FF$hexValue', radix: 16));
      final hsv = HSVColor.fromColor(color);
      
      setState(() {
        _hue = hsv.hue;
        _saturation = hsv.saturation;
        _value = hsv.value;
      });
    } catch (e) {
      // Invalid hex, ignore
    }
  }

  void _updateHexField() {
    if (!_isUpdatingFromSliders) {
      _isUpdatingFromSliders = true;
      _hexController.text = _hexString;
      _isUpdatingFromSliders = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a Color'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hue slider
            _buildColorSlider(
              label: 'Hue',
              value: _hue,
              max: 360,
              onChanged: (value) {
                setState(() {
                  _hue = value;
                  _updateHexField();
                });
              },
            ),
            const SizedBox(height: 16),
            // Saturation slider
            _buildColorSlider(
              label: 'Saturation',
              value: _saturation,
              max: 1,
              onChanged: (value) {
                setState(() {
                  _saturation = value;
                  _updateHexField();
                });
              },
            ),
            const SizedBox(height: 16),
            // Value/Brightness slider
            _buildColorSlider(
              label: 'Brightness',
              value: _value,
              max: 1,
              onChanged: (value) {
                setState(() {
                  _value = value;
                  _updateHexField();
                });
              },
            ),
            const SizedBox(height: 24),
            // Color preview
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: _currentColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            // Hex code input field
            TextField(
              controller: _hexController,
              decoration: const InputDecoration(
                labelText: 'Hex Color',
                prefixText: '#',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
              maxLength: 6,
              onChanged: (value) {
                if (!_isUpdatingFromSliders) {
                  _updateFromHex(value);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _currentColor),
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildColorSlider({
    required String label,
    required double value,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: value,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}