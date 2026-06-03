import '../services/mock_api_service.dart';
import '../models/user.dart';

class AuthPresenter {
  final MockApiService _api = MockApiService();
  AuthView? _view;

  void attachView(AuthView view) => _view = view;
  void detachView() => _view = null;

  Future<void> signup(String name, String email, String password) async {
    _view?.showLoading();
    try {
      final result = await _api.signup(name, email, password);
      _view?.onSignupSuccess(result['user'] as User, result['token'] as String);
    } catch (e) {
      _view?.onError(e.toString());
    } finally {
      _view?.hideLoading();
    }
  }

  Future<void> login(String email, String password) async {
    _view?.showLoading();
    try {
      final result = await _api.login(email, password);
      _view?.onLoginSuccess(result['user'] as User, result['token'] as String);
    } catch (e) {
      _view?.onError(e.toString());
    } finally {
      _view?.hideLoading();
    }
  }
}

abstract class AuthView {
  void showLoading();
  void hideLoading();
  void onSignupSuccess(User user, String token);
  void onLoginSuccess(User user, String token);
  void onError(String message);
}