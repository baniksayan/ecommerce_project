import 'base_viewmodel.dart';
import '../data/models/plant_model.dart';

/// ViewModel containing business logic for the Home Screen.
class HomeViewModel extends BaseViewModel {
  List<PlantModel> _plants = [];
  List<PlantModel> get plants => _plants;

  Future<void> fetchPlants() async {
    setLoading(true);
    clearError();

    try {
      // Simulate network request loading time
      await Future.delayed(const Duration(milliseconds: 1500));

      _plants = [
        PlantModel(
          id: '1',
          name: 'Monstera Deliciosa',
          price: 29.99,
          isFavorite: true,
        ),
        PlantModel(
          id: '2',
          name: 'Fiddle Leaf Fig',
          price: 45.00,
          isFavorite: false,
        ),
        PlantModel(
          id: '3',
          name: 'Snake Plant',
          price: 15.50,
          isFavorite: false,
        ),
        PlantModel(id: '4', name: 'ZZ Plant', price: 22.00, isFavorite: true),
      ];
    } catch (e) {
      setError('Failed to fetch plants from the enchanted forest.');
    } finally {
      setLoading(false);
    }
  }

  void toggleFavorite(String id) {
    final index = _plants.indexWhere((p) => p.id == id);
    if (index != -1) {
      _plants[index] = _plants[index].copyWith(
        isFavorite: !_plants[index].isFavorite,
      );
      notifyListeners();
    }
  }
}
