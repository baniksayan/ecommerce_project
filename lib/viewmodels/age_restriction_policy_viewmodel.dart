import 'base_viewmodel.dart';
import '../models/age_verification_list_model.dart';
import '../services/api_service.dart';

class AgeRestrictionPolicyViewModel extends BaseViewModel {
  final ApiService _apiService = ApiService();

  List<AgeVerificationData> _sections = [];
  List<AgeVerificationData> get sections => _sections;

  Future<void> fetchSections() async {
    setLoading(true);
    clearError();

    try {
      final response = await _apiService.getAgeVerifications();
      if (response.success == true && response.data != null) {
        _sections = response.data!;
      } else {
        _sections = [];
      }
    } catch (e) {
      setError('Failed to fetch age restriction policies.');
    } finally {
      setLoading(false);
    }
  }
}
