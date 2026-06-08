import '../services/mock_api_service.dart';

class JobAlertPresenter {
  final MockApiService _api = MockApiService();
  JobAlertView? _view;

  void attachView(JobAlertView view) => _view = view;
  void detachView() => _view = null;

  Future<void> loadAlerts() async {
    _view?.showLoading();
    try { final alerts = await _api.getJobAlerts(); _view?.showAlerts(alerts); }
    catch (e) { _view?.onError(e.toString()); }
    finally { _view?.hideLoading(); }
  }

  Future<void> createAlert(String keyword, String? location) async {
    _view?.showLoading();
    try { await _api.createJobAlert(keyword, location); _view?.onAlertCreated(); }
    catch (e) { _view?.onError(e.toString()); }
    finally { _view?.hideLoading(); }
  }

  Future<void> deleteAlert(String alertId) async {
    _view?.showLoading();
    try { await _api.deleteJobAlert(alertId); _view?.onAlertDeleted(); }
    catch (e) { _view?.onError(e.toString()); }
    finally { _view?.hideLoading(); }
  }
}

abstract class JobAlertView {
  void showLoading(); void hideLoading(); void showAlerts(List<Map<String, dynamic>> alerts);
  void onAlertCreated(); void onAlertDeleted(); void onError(String message);
}