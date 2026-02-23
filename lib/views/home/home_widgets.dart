import 'package:flutter/material.dart';
import '../../core/responsive/media_query_helper.dart';
import '../../data/models/plant_model.dart';

/// Pure UI widget for displaying a PlantModel.
/// Emits events instead of handling logic itself.
class PlantCard extends StatelessWidget {
  final PlantModel plant;
  final VoidCallback onFavoriteToggled;

  const PlantCard({
    Key? key,
    required this.plant,
    required this.onFavoriteToggled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: MediaQueryHelper.scaleHeight(16)),
      padding: EdgeInsets.all(MediaQueryHelper.scaleWidth(16)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQueryHelper.scaleWidth(60),
            height: MediaQueryHelper.scaleWidth(60),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.eco,
              color: theme.primaryColor,
              size: MediaQueryHelper.scaleWidth(32),
            ),
          ),
          SizedBox(width: MediaQueryHelper.scaleWidth(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.name,
                  style: theme.textTheme.displaySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: MediaQueryHelper.scaleHeight(4)),
                Text(
                  '\$${plant.price.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              plant.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: plant.isFavorite
                  ? Colors.redAccent
                  : theme.iconTheme.color,
            ),
            onPressed: onFavoriteToggled,
          ),
        ],
      ),
    );
  }
}
