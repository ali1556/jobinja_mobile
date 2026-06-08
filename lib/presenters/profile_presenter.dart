import '../services/mock_api_service.dart';
import '../models/user.dart';

abstract class ProfileView {
  void showLoading(); void hideLoading(); void onProfileLoaded(User user); void onLogoutSuccess(); void onError(String message);
}
abstract class EditProfileView {
  void showLoading(); void hideLoading(); void onProfileUpdated(User user); void onError(String message);
}

class ProfilePresenter {
  final MockApiService _api = MockApiService();
  ProfileView? _view;
  EditProfileView? _editView;

  void attachView(ProfileView view) => _view = view;
  void detachView() => _view = null;
  void attachEditView(EditProfileView view) => _editView = view;
  void detachEditView() => _editView = null;

  Future<void> loadUserProfile() async {
    _view?.showLoading();
    try { final user = await _api.getCurrentUser(); _view?.onProfileLoaded(user); }
    catch (e) { _view?.onError(e.toString()); }
    finally { _view?.hideLoading(); }
  }

  Future<void> logout() async {
    _view?.showLoading();
    try { await _api.logout(); _view?.onLogoutSuccess(); }
    catch (e) { _view?.onError(e.toString()); }
    finally { _view?.hideLoading(); }
  }

  Future<void> updateProfile(String name, String email, String? avatarPath) async {
    _editView?.showLoading();
    try { final user = await _api.updateUserProfile(name, email, avatarPath: avatarPath); _editView?.onProfileUpdated(user); }
    catch (e) { _editView?.onError(e.toString()); }
    finally { _editView?.hideLoading(); }
  }
}