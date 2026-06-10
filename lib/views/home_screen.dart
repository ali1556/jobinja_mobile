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
  int _minSalary = 0;
  bool _isRemote = false;
  String _sortBy = 'publishedAt';      // 'publishedAt' or 'salary'
  int _currentPage = 1;
  int _totalCount = 0;
  final int _pageSize = 10;

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
      minSalary: _minSalary > 0 ? _minSalary : null,
      isRemote: _isRemote ? true : null,
      sortBy: _sortBy,
      page: _currentPage,
      pageSize: _pageSize,
    );
  }

  void _resetAndLoad() {
    setState(() => _currentPage = 1);
    _loadJobs();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        String tempLocation = _selectedLocation;
        int tempMinSalary = _minSalary;
        bool tempRemote = _isRemote;
        String tempSortBy = _sortBy;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Filter & Sort Jobs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: tempLocation.isEmpty ? null : tempLocation,
                    hint: Text('All provinces'),
                    items: ['All provinces', 'Tehran', 'Isfahan', 'Shiraz', 'Mashhad']
                        .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
                        .toList(),
                    onChanged: (val) => setSheetState(() => tempLocation = val ?? ''),
                    decoration: InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(labelText: 'Minimum Salary (Million)'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setSheetState(() => tempMinSalary = int.tryParse(val) ?? 0),
                  ),
                  SizedBox(height: 12),
                  Row(children: [
                    Checkbox(value: tempRemote, onChanged: (val) => setSheetState(() => tempRemote = val!)),
                    Text('Remote only'),
                  ]),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: tempSortBy,
                    items: [
                      DropdownMenuItem(value: 'publishedAt', child: Text('Newest first')),
                      DropdownMenuItem(value: 'salary', child: Text('Highest salary first')),
                    ],
                    onChanged: (val) => setSheetState(() => tempSortBy = val!),
                    decoration: InputDecoration(labelText: 'Sort by', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (tempLocation == 'All provinces') {_selectedLocation = '';}
                        else {_selectedLocation = tempLocation;}
                        _minSalary = tempMinSalary;
                        _isRemote = tempRemote;
                        _sortBy = tempSortBy;
                      });
                      _resetAndLoad();
                      Navigator.pop(ctx);
                    },
                    child: Text('Apply Filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
      _loadJobs();
    }
  }

  void _goToNextPage() {
    if (_currentPage * _pageSize < _totalCount) {
      setState(() => _currentPage++);
      _loadJobs();
    }
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
                    onSubmitted: (_) => _resetAndLoad(),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(30)),
                  child: IconButton(
                    icon: Icon(Icons.filter_list, color: Colors.blue.shade700),
                    onPressed: _showFilterSheet,
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
                : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: _jobs.length,
                    itemBuilder: (ctx, i) => JobCard(
                      job: _jobs[i],
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: _jobs[i].id))),
                    ),
                  ),
                ),
                if (_totalCount > _pageSize)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(icon: Icon(Icons.chevron_left), onPressed: _goToPreviousPage),
                        Text('Page $_currentPage of ${((_totalCount - 1) ~/ _pageSize) + 1}'),
                        IconButton(icon: Icon(Icons.chevron_right), onPressed: _goToNextPage),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void showJobs(List<Job> jobs, int totalCount, int currentPage) {
    setState(() {
      _jobs = jobs;
      _totalCount = totalCount;
      _currentPage = currentPage;
      _error = null;
    });
  }

  @override void showLoading() => setState(() => _isLoading = true);
  @override void hideLoading() => setState(() => _isLoading = false);
  @override void onError(String message) => setState(() => _error = message);
}