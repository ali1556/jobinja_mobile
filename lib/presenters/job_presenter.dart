import '../services/mock_api_service.dart';
import '../models/job.dart';

abstract class JobView { void showLoading(); void hideLoading(); void showJobs(List<Job> jobs, int totalCount, int currentPage); void onError(String message); }
abstract class JobDetailView { void showLoading(); void hideLoading(); void onJobLoaded(Job job); void onError(String message); }
abstract class AppliedJobsView { void showLoading(); void hideLoading(); void showAppliedJobs(List<Job> jobs); void onError(String message); }

class JobPresenter {
  final MockApiService _api = MockApiService();
  JobView? _view;
  JobDetailView? _detailView;
  AppliedJobsView? _appliedJobsView;

  void attachView(JobView view) => _view = view;
  void detachView() => _view = null;
  void attachDetailView(JobDetailView view) => _detailView = view;
  void detachDetailView() => _detailView = null;
  void attachAppliedJobsView(AppliedJobsView view) => _appliedJobsView = view;
  void detachAppliedJobsView() => _appliedJobsView = null;

  Future<void> loadJobs({
    String? keyword,
    String? location,
    int? minSalary,
    bool? isRemote,
    String? sortBy,
    int page = 1,
    int pageSize = 10,
  }) async {
    _view?.showLoading();
    try {
      final result = await _api.getJobs(
        keyword: keyword,
        location: location,
        minSalary: minSalary,
        isRemote: isRemote,
        sortBy: sortBy,
        page: page,
        pageSize: pageSize,
      );
      _view?.showJobs(result['jobs'] as List<Job>, result['totalCount'] as int, result['page'] as int);
    } catch (e) {
      _view?.onError(e.toString());
    } finally {
      _view?.hideLoading();
    }
  }

  Future<void> getJobDetail(String jobId) async {
    _detailView?.showLoading();
    try { final job = await _api.getJobDetail(jobId); _detailView?.onJobLoaded(job); }
    catch (e) { _detailView?.onError(e.toString()); }
    finally { _detailView?.hideLoading(); }
  }

  Future<void> loadAppliedJobs() async {
    _appliedJobsView?.showLoading();
    try { final jobs = await _api.getAppliedJobs(); _appliedJobsView?.showAppliedJobs(jobs); }
    catch (e) { _appliedJobsView?.onError(e.toString()); }
    finally { _appliedJobsView?.hideLoading(); }
  }

  Future<void> applyToJob(String jobId) async {
    await _api.applyToJob(jobId);
  }
}