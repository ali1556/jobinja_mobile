import '../services/mock_api_service.dart';
import '../models/company.dart';
import '../models/job.dart';

class CompanyPresenter {
  final MockApiService _api = MockApiService();
  CompanyView? _view;

  void attachView(CompanyView view) => _view = view;
  void detachView() => _view = null;

  Future<void> loadCompanyData(String companySlug) async {
    _view?.showLoading();
    try {
      final company = await _api.getCompany(companySlug);
      final jobs = await _api.getCompanyJobs(companySlug);
      _view?.onCompanyDataLoaded(company, jobs);
    } catch (e) {
      _view?.onError(e.toString());
    } finally {
      _view?.hideLoading();
    }
  }
}

abstract class CompanyView {
  void showLoading();
  void hideLoading();
  void onCompanyDataLoaded(Company company, List<Job> jobs);
  void onError(String message);
}