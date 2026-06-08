import 'package:flutter/material.dart';
import '../presenters/job_alert_presenter.dart';

class JobAlertsScreen extends StatefulWidget {
  @override
  _JobAlertsScreenState createState() => _JobAlertsScreenState();
}

class _JobAlertsScreenState extends State<JobAlertsScreen> implements JobAlertView {
  final JobAlertPresenter _presenter = JobAlertPresenter();
  List<Map<String, dynamic>> _alerts = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _presenter.attachView(this);
    _presenter.loadAlerts();
  }

  @override
  void dispose() {
    _presenter.detachView();
    _keywordController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _createAlert() {
    if (_keywordController.text.trim().isNotEmpty) {
      _presenter.createAlert(_keywordController.text.trim(), _locationController.text.trim().isEmpty ? null : _locationController.text.trim());
      _keywordController.clear();
      _locationController.clear();
    }
  }

  void _deleteAlert(String id) => _presenter.deleteAlert(id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Job Alerts'), centerTitle: true),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error', style: TextStyle(color: Colors.red)))
          : Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(children: [
              TextField(controller: _keywordController, decoration: InputDecoration(labelText: 'Keyword (e.g., Flutter)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              SizedBox(height: 8),
              TextField(controller: _locationController, decoration: InputDecoration(labelText: 'Location (optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              SizedBox(height: 12),
              ElevatedButton(onPressed: _createAlert, child: Text('Create Alert'), style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 45))),
            ]),
          ),
          Expanded(
            child: _alerts.isEmpty
                ? Center(child: Text('No job alerts. Create one above.'))
                : ListView.builder(
              itemCount: _alerts.length,
              itemBuilder: (ctx, i) {
                final alert = _alerts[i];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(alert['keyword'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: alert['location'] != null ? Text(alert['location']) : null,
                    trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteAlert(alert['id'])),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override void showLoading() => setState(() => _isLoading = true);
  @override void hideLoading() => setState(() => _isLoading = false);
  @override void showAlerts(List<Map<String, dynamic>> alerts) => setState(() { _alerts = alerts; _error = null; });
  @override void onAlertCreated() => _presenter.loadAlerts();
  @override void onAlertDeleted() => _presenter.loadAlerts();
  @override void onError(String message) => setState(() => _error = message);
}