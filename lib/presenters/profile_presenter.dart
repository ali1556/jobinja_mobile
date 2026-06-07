import '../services/mock_api_service.dart';
import '../models/user.dart';

// View contract for Profile
abstract class ProfileView {
  void showLoading();
  void hideLoading();
  void onProfileLoaded(User user);
  void onLogoutSuccess();
  void onError(String message);
}

class ProfilePresenter {
  final MockApiService _api = MockApiService();
  ProfileView? _view;

  void attachView(ProfileView view) => _view = view;
  void detachView() => _view = null;

  Future<void> loadUserProfile() async {
    _view?.showLoading();
    try {
      final user = await _api.getCurrentUser();
      _view?.onProfileLoaded(user);
    } catch (e) {
      _view?.onError(e.toString());
    } finally {
      _view?.hideLoading();
    }
  }

  Future<void> logout() async {
    _view?.showLoading();
    try {
      await _api.logout();
      _view?.onLogoutSuccess();
    } catch (e) {
      _view?.onError(e.toString());
    } finally {
      _view?.hideLoading();
    }
  }
}