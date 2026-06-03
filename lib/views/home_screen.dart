import 'package:flutter/material.dart';
import '../presenters/job_presenter.dart';
import '../models/job.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_widget.dart';
import 'job_detail_screen.dart';

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
      appBar: AppBar(title: Text('Jobinja'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search job or company',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: _loadJobs,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: () => _showLocationFilter(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? LoadingWidget()
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _jobs.isEmpty
                        ? Center(child: Text('No jobs found'))
                        : ListView.builder(
                            itemCount: _jobs.length,
                            itemBuilder: (ctx, i) => JobCard(
                              job: _jobs[i],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => JobDetailScreen(jobId: _jobs[i].id),
                                ),
                              ),
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
          items: ['Tehran', 'Isfahan', 'Shiraz', 'Mashhad']
              .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
              .toList(),
          onChanged: (val) {
            setState(() => _selectedLocation = val ?? '');
            Navigator.pop(context);
            _loadJobs();
          },
        ),
      ),
    );
  }

  @override
  void showJobs(List<Job> jobs) => setState(() { _jobs = jobs; _error = null; });
  @override
  void showLoading() => setState(() => _isLoading = true);
  @override
  void hideLoading() => setState(() => _isLoading = false);
  @override
  void onError(String message) => setState(() => _error = message);
}