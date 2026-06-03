import '../services/mock_api_service.dart';
import '../models/job.dart';

// View contract for job list
abstract class JobView {
  void showLoading();
  void hideLoading();
  void showJobs(List<Job> jobs);
  void onError(String message);
}

// View contract for job detail
abstract class JobDetailView {
  void showLoading();
  void hideLoading();
  void onJobLoaded(Job job);
  void onError(String message);
}

class JobPresenter {
  final MockApiService _api = MockApiService();
  JobView? _view;
  JobDetailView? _detailView;

  void attachView(JobView view) => _view = view;
  void detachView() => _view = null;

  void attachDetailView(JobDetailView view) => _detailView = view;
  void detachDetailView() => _detailView = null;

  Future<void> loadJobs({String? keyword, String? location}) async {
    _view?.showLoading();
    try {
      final jobs = await _api.getJobs(keyword: keyword, location: location);
      _view?.showJobs(jobs);
    } catch (e) {
      _view?.onError(e.toString());
    } finally {
      _view?.hideLoading();
    }
  }

  Future<void> getJobDetail(String jobId) async {
    _detailView?.showLoading();
    try {
      final job = await _api.getJobDetail(jobId);
      _detailView?.onJobLoaded(job);
    } catch (e) {
      _detailView?.onError(e.toString());
    } finally {
      _detailView?.hideLoading();
    }
  }
}