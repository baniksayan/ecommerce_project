/// Simple pure data Model without business logic or Flutter UI bindings
class PlantModel {
  final String id;
  final String name;
  final double price;
  final bool isFavorite;

  PlantModel({
    required this.id,
    required this.name,
    required this.price,
    this.isFavorite = false,
  });

  PlantModel copyWith({
    String? id,
    String? name,
    double? price,
    bool? isFavorite,
  }) {
    return PlantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
