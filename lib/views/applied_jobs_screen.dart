import 'package:flutter/material.dart';
import '../presenters/job_presenter.dart';
import '../models/job.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_widget.dart';
import 'job_detail_screen.dart';

class AppliedJobsScreen extends StatefulWidget {
  @override
  _AppliedJobsScreenState createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> implements AppliedJobsView {
  final JobPresenter _presenter = JobPresenter();
  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _presenter.attachAppliedJobsView(this);
    _presenter.loadAppliedJobs();
  }

  @override
  void dispose() {
    _presenter.detachAppliedJobsView();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Applied Jobs'), centerTitle: true),
      body: _isLoading
          ? LoadingWidget()
          : _error != null
          ? Center(child: Text('Error: $_error', style: TextStyle(color: Colors.red)))
          : _jobs.isEmpty
          ? Center(child: Text('You have not applied to any jobs yet.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)))
          : ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: _jobs.length,
        itemBuilder: (ctx, i) => JobCard(job: _jobs[i], onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: _jobs[i].id)))),
      ),
    );
  }

  @override void showLoading() => setState(() => _isLoading = true);
  @override void hideLoading() => setState(() => _isLoading = false);
  @override void showAppliedJobs(List<Job> jobs) => setState(() { _jobs = jobs; _error = null; });
  @override void onError(String message) => setState(() => _error = message);
}

