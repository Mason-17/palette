import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/palette_provider.dart';
import '../widgets/palette_card.dart';
import 'palette_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Palettes'),
        elevation: 0,
      ),
      body: Consumer<PaletteProvider>(
        builder: (context, provider, child) {
          // Show loading indicator while loading
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show empty state if no palettes
          if (provider.palettes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.palette_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No palettes yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to create your first palette',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            );
          }

          // Show grid of palette cards
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate number of columns based on screen width
                int crossAxisCount;
                if (constraints.maxWidth > 1200) {
                  crossAxisCount = 6; // Very wide screens
                } else if (constraints.maxWidth > 900) {
                  crossAxisCount = 4; // Desktop/tablet landscape
                } else if (constraints.maxWidth > 600) {
                  crossAxisCount = 3; // Tablet portrait
                } else {
                  crossAxisCount = 2; // Mobile
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85, // Slightly taller than wide
                  ),
                  itemCount: provider.palettes.length,
                  itemBuilder: (context, index) {
                    final palette = provider.palettes[index];
                    return PaletteCard(
                      palette: palette,
                      onTap: () {
                        // Navigate to detail screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaletteDetailScreen(
                              paletteId: palette.id,
                            ),
                          ),
                        );
                      },
                      onDelete: () async {
                        // Show confirmation dialog
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Palette'),
                            content: Text(
                              'Are you sure you want to delete "${palette.name}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await provider.deletePalette(palette.id);
                        }
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final provider = context.read<PaletteProvider>();
          
          // Create a new empty palette
          final newPalette = provider.createNewPalette();
          await provider.addPalette(newPalette);
          
          // Navigate to detail screen to edit it
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaletteDetailScreen(
                  paletteId: newPalette.id,
                ),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}