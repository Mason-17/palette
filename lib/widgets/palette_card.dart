import 'package:flutter/material.dart';
import '../models/palette_models.dart';

class PaletteCard extends StatelessWidget {
  final ColorPalette palette;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PaletteCard({
    super.key,
    required this.palette,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Color preview section
            Expanded(
              child: palette.colors.isEmpty
                  ? _buildEmptyState(context)
                  : _buildColorPreview(),
            ),
            
            // Palette info section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          palette.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: onDelete,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${palette.colors.length} ${palette.colors.length == 1 ? 'color' : 'colors'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.palette_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildColorPreview() {
    // Show colors in a grid pattern
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate how many colors to show per row based on total colors
        int colorsPerRow;
        if (palette.colors.length <= 2) {
          colorsPerRow = palette.colors.length;
        } else if (palette.colors.length <= 4) {
          colorsPerRow = 2;
        } else {
          colorsPerRow = 3;
        }

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: colorsPerRow,
          ),
          itemCount: palette.colors.length,
          itemBuilder: (context, index) {
            return Container(
              color: palette.colors[index].color,
            );
          },
        );
      },
    );
  }
}