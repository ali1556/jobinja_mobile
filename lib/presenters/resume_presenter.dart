import '../models/company.dart';
import '../models/resume.dart';
import '../models/user.dart';
import '../services/mock_api_service.dart';

abstract class ResumeView {
  void showLoading();
  void hideLoading();
  void onResumeLoaded(Resume resume);
  void onResumeUpdated();
  void onError(String message);
}

class ResumePresenter {
  final MockApiService _api = MockApiService();
  ResumeView? _view;

  void attachView(ResumeView view) => _view = view;
  void detachView() => _view = null;

  Future<void> loadResume(User user) async {
    _view?.showLoading();
    try {
      final resume = await _api.getResume(user);
      _view?.onResumeLoaded(resume);
    } catch (e) {
      _view?.onError(e.toString());
    } finally {
      _view?.hideLoading();
    }
  }

  Future<void> updateResume(int userId, Resume resume) async {
    _view?.showLoading();
    try {
      await _api.updateResume(userId, resume);
      _view?.onResumeUpdated();
    } catch (e) {
      _view?.onError(e.toString());
    } finally {
      _view?.hideLoading();
    }
  }

  Future<List<Company>> getCompanies() => _api.getCompanies();
}