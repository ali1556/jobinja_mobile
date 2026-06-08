import 'package:flutter/material.dart';
import '../presenters/job_presenter.dart';
import '../models/job.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_widget.dart';
import 'job_detail_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements JobView {
  final JobPresenter _presenter = JobPresenter();
  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _selectedLocation = '';

  @override
  void initState() {
    super.initState();
    _presenter.attachView(this);
    _loadJobs();
  }

  void _loadJobs() {
    _presenter.loadJobs(
      keyword: _searchController.text.isEmpty ? null : _searchController.text,
      location: _selectedLocation.isEmpty ? null : _selectedLocation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jobinja', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.blue.shade700),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: Offset(0, 2))]),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search job or company',
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    onSubmitted: (_) => _loadJobs(),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(30)),
                  child: IconButton(
                    icon: Icon(Icons.filter_list, color: Colors.blue.shade700),
                    onPressed: () => _showLocationFilter(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? LoadingWidget()
                : _error != null
                ? Center(child: Text('Error: $_error', style: TextStyle(color: Colors.red)))
                : _jobs.isEmpty
                ? Center(child: Text('No jobs found', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)))
                : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: _jobs.length,
              itemBuilder: (ctx, i) => JobCard(
                job: _jobs[i],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: _jobs[i].id))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationFilter() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Select Province'),
        content: DropdownButton<String>(
          value: _selectedLocation.isEmpty ? null : _selectedLocation,
          hint: Text('All provinces'),
          items: ['Tehran', 'Isfahan', 'Shiraz', 'Mashhad'].map((loc) => DropdownMenuItem(value: loc, child: Text(loc))).toList(),
          onChanged: (val) {
            setState(() => _selectedLocation = val ?? '');
            Navigator.pop(context);
            _loadJobs();
          },
        ),
      ),
    );
  }

  @override void showJobs(List<Job> jobs) => setState(() { _jobs = jobs; _error = null; });
  @override void showLoading() => setState(() => _isLoading = true);
  @override void hideLoading() => setState(() => _isLoading = false);
  @override void onError(String message) => setState(() => _error = message);
}