import '../services/mock_api_service.dart';

class ContactPresenter {
  final MockApiService _api = MockApiService();
  ContactView? _view;

  void attachView(ContactView view) => _view = view;
  void detachView() => _view = null;

  Future<void> sendContact(String name, String email, String message) async {
    _view?.showLoading();
    try { await _api.sendContact(name, email, message); _view?.onContactSent(); }
    catch (e) { _view?.onError(e.toString()); }
    finally { _view?.hideLoading(); }
  }
}

abstract class ContactView {
  void showLoading(); void hideLoading(); void onContactSent(); void onError(String message);
}