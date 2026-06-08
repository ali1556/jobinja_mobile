import 'package:flutter/material.dart';
import '../presenters/company_presenter.dart';
import '../models/company.dart';
import '../models/job.dart';
import '../widgets/job_card.dart';
import 'job_detail_screen.dart';

class CompanyScreen extends StatefulWidget {
  final String companySlug;
  const CompanyScreen({required this.companySlug});

  @override
  _CompanyScreenState createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> implements CompanyView {
  final CompanyPresenter _presenter = CompanyPresenter();
  Company? _company;
  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _presenter.attachView(this);
    _presenter.loadCompanyData(widget.companySlug);
  }

  @override
  void dispose() {
    _presenter.detachView();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_company?.name ?? 'Company'), centerTitle: true),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error', style: TextStyle(color: Colors.red)))
          : _company == null
          ? Center(child: Text('No company data'))
          : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.blue.shade50,
              child: Row(children: [
                CircleAvatar(radius: 40, backgroundColor: Colors.blue.shade200, child: Icon(Icons.business, size: 40, color: Colors.blue.shade800)),
                SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_company!.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  if (_company!.industry != null) Text(_company!.industry!, style: TextStyle(color: Colors.grey.shade700)),
                  if (_company!.website != null) Text(_company!.website!, style: TextStyle(color: Colors.blue.shade700)),
                ])),
              ]),
            ),
            if (_company!.description != null)
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('About Company', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(_company!.description!, style: TextStyle(height: 1.3)),
                ]),
              ),
            Padding(padding: EdgeInsets.all(16), child: Text('Open Positions (${_jobs.length})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            _jobs.isEmpty ? Padding(padding: EdgeInsets.all(16), child: Text('No open positions')) : ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), itemCount: _jobs.length, itemBuilder: (ctx, i) => JobCard(job: _jobs[i], onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: _jobs[i].id))))),
          ],
        ),
      ),
    );
  }

  @override void showLoading() => setState(() => _isLoading = true);
  @override void hideLoading() => setState(() => _isLoading = false);
  @override void onCompanyDataLoaded(Company company, List<Job> jobs) => setState(() { _company = company; _jobs = jobs; _error = null; });
  @override void onError(String message) => setState(() => _error = message);
}