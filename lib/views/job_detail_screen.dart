import 'package:flutter/material.dart';
import '../presenters/job_presenter.dart';  // contains JobDetailView
import '../models/job.dart';
import '../widgets/loading_widget.dart';

class JobDetailScreen extends StatefulWidget {
  final String jobId;
  const JobDetailScreen({required this.jobId});

  @override
  _JobDetailScreenState createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> implements JobDetailView {
  final JobPresenter _presenter = JobPresenter();
  Job? _job;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _presenter.attachDetailView(this);
    _loadJob();
  }

  void _loadJob() {
    _presenter.getJobDetail(widget.jobId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Job Details')),
      body: _isLoading
          ? LoadingWidget()
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _job == null
          ? Center(child: Text('No data'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_job!.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('${_job!.companyName} - ${_job!.location}'),
            SizedBox(height: 8),
            Text('Contract: ${_job!.contractType}'),
            Text('Salary: ${_job!.salaryDisplay}'),
            Text('Posted: ${_job!.publishedAt}'),
            if (_job!.isRemote) Text('Remote: Yes'),
            SizedBox(height: 16),
            Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_job!.description ?? 'No description'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Applied to ${_job!.title}')),
                );
              },
              child: Text('Apply Now'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void showLoading() => setState(() => _isLoading = true);
  @override
  void hideLoading() => setState(() => _isLoading = false);
  @override
  void onJobLoaded(Job job) => setState(() { _job = job; _error = null; });
  @override
  void onError(String message) => setState(() => _error = message);
}