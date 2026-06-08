import 'package:flutter/material.dart';
import '../presenters/job_presenter.dart';
import '../models/job.dart';
import '../widgets/custom_button.dart';
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
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _presenter.attachDetailView(this);
    _loadJob();
  }

  void _loadJob() => _presenter.getJobDetail(widget.jobId);
  void _apply() async {
    setState(() => _isApplying = true);
    try {
      await _presenter.applyToJob(widget.jobId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Applied to ${_job!.title}!'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to apply: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Job Details', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: _isLoading
          ? LoadingWidget()
          : _error != null
          ? Center(child: Text('Error: $_error', style: TextStyle(color: Colors.red)))
          : _job == null
          ? Center(child: Text('No data'))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_job!.title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
            SizedBox(height: 8),
            Row(children: [Icon(Icons.business, size: 16, color: Colors.grey.shade600), SizedBox(width: 4), Text('${_job!.companyName} · ${_job!.location}', style: TextStyle(fontSize: 16))]),
            SizedBox(height: 16),
            _infoRow(Icons.work_outline, 'Contract Type', _job!.contractType),
            _infoRow(Icons.attach_money, 'Salary', _job!.salaryDisplay),
            _infoRow(Icons.calendar_today, 'Posted', _job!.publishedAt),
            if (_job!.isRemote) _infoRow(Icons.wifi, 'Remote', 'Yes'),
            SizedBox(height: 24),
            Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(_job!.description ?? 'No description', style: TextStyle(fontSize: 16, height: 1.4)),
            SizedBox(height: 32),
            CustomButton(onPressed: _apply, text: 'Apply Now', isLoading: _isApplying),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(children: [Icon(icon, size: 20, color: Colors.blue.shade600), SizedBox(width: 12), Text('$label: ', style: TextStyle(fontWeight: FontWeight.w500)), Expanded(child: Text(value))]),
    );
  }

  @override void showLoading() => setState(() => _isLoading = true);
  @override void hideLoading() => setState(() => _isLoading = false);
  @override void onJobLoaded(Job job) => setState(() { _job = job; _error = null; });
  @override void onError(String message) => setState(() => _error = message);
}