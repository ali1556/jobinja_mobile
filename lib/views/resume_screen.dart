// views/resume_screen.dart
import 'package:flutter/material.dart';
import '../presenters/resume_presenter.dart';
import '../models/user.dart';
import '../models/resume.dart';
import '../models/company.dart';
import '../widgets/custom_button.dart';
import '../utils/validators.dart';

class ResumeScreen extends StatefulWidget {
  final User user;
  const ResumeScreen({required this.user});

  @override
  _ResumeScreenState createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> implements ResumeView {
  final ResumePresenter _presenter = ResumePresenter();
  late Resume _resume;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  List<Company> _companies = [];

  // Controllers for dynamic fields
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _presenter.attachView(this);
    _loadData();
  }

  Future<void> _loadData() async {
    await _presenter.loadResume(widget.user);
    _companies = await _presenter.getCompanies();
  }

  @override
  void dispose() {
    _presenter.detachView();
    _aboutController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    // Update resume object from controllers and lists
    _resume.about = _aboutController.text.trim().isEmpty ? null : _aboutController.text.trim();
    _resume.phoneNumber = _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();
    _presenter.updateResume(widget.user.id, _resume);
  }

  // Language management
  void _addLanguage() {
    showDialog(
      context: context,
      builder: (_) => _LanguageDialog(
        onAdd: (lang) {
          setState(() => _resume.languages.add(lang));
        },
      ),
    );
  }

  void _removeLanguage(int index) {
    setState(() => _resume.languages.removeAt(index));
  }

  // Skill management
  void _addSkill() {
    showDialog(
      context: context,
      builder: (_) => _SkillDialog(
        onAdd: (skill) {
          setState(() => _resume.skills.add(skill));
        },
      ),
    );
  }

  void _removeSkill(int index) {
    setState(() => _resume.skills.removeAt(index));
  }

  // Work experience management
  void _addWorkExperience() {
    showDialog(
      context: context,
      builder: (_) => _WorkExperienceDialog(
        companies: _companies,
        onAdd: (exp) {
          setState(() => _resume.workExperiences.add(exp));
        },
      ),
    );
  }

  void _removeWorkExperience(int index) {
    setState(() => _resume.workExperiences.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Resume'), centerTitle: true),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Completion score card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text('Resume Completeness', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    LinearProgressIndicator(value: _resume.completionScore() / 100),
                    SizedBox(height: 8),
                    Text('${_resume.completionScore()}% complete'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // About
            TextFormField(
              controller: _aboutController,
              decoration: InputDecoration(
                labelText: 'About me',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 16),
            // Phone
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.phone,
              validator: (v) => v != null && v.isNotEmpty ? Validators.phone(v) : null,
            ),
            SizedBox(height: 24),

            // Languages section
            _buildSectionTitle('Languages', Icons.language, _addLanguage),
            ..._resume.languages.asMap().entries.map((entry) {
              int idx = entry.key;
              Language lang = entry.value;
              return ListTile(
                title: Text('${lang.name} - ${lang.level.display}'),
                trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => _removeLanguage(idx)),
              );
            }),
            if (_resume.languages.isEmpty) Text('No languages added', style: TextStyle(color: Colors.grey)),

            SizedBox(height: 16),

            // Skills section
            _buildSectionTitle('Skills', Icons.build, _addSkill),
            Wrap(
              spacing: 8,
              children: _resume.skills.asMap().entries.map((entry) {
                int idx = entry.key;
                String skill = entry.value;
                return Chip(
                  label: Text(skill),
                  onDeleted: () => _removeSkill(idx),
                );
              }).toList(),
            ),
            if (_resume.skills.isEmpty) Text('No skills added', style: TextStyle(color: Colors.grey)),

            SizedBox(height: 16),

            // Work Experience section
            _buildSectionTitle('Work Experience', Icons.work, _addWorkExperience),
            ..._resume.workExperiences.asMap().entries.map((entry) {
              int idx = entry.key;
              WorkExperience exp = entry.value;
              return Card(
                child: ListTile(
                  title: Text(exp.companyName),
                  subtitle: Text('${_formatDate(exp.startDate)} - ${exp.endDate != null ? _formatDate(exp.endDate!) : 'Present'}'),
                  trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => _removeWorkExperience(idx)),
                ),
              );
            }),
            if (_resume.workExperiences.isEmpty) Text('No work experience added', style: TextStyle(color: Colors.grey)),

            SizedBox(height: 32),
            if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
            if (_successMessage != null) Text(_successMessage!, style: TextStyle(color: Colors.green)),
            CustomButton(onPressed: _save, text: 'Save Resume', isLoading: _isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, VoidCallback onAdd) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Spacer(),
          IconButton(icon: Icon(Icons.add), onPressed: onAdd),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}';

  // ResumeView implementation
  @override
  void showLoading() => setState(() => _isLoading = true);
  @override
  void hideLoading() => setState(() => _isLoading = false);
  @override
  void onResumeLoaded(Resume resume) {
    setState(() {
      _resume = resume;
      _aboutController.text = resume.about ?? '';
      _phoneController.text = resume.phoneNumber ?? '';
      _error = null;
    });
  }
  @override
  void onResumeUpdated() {
    setState(() {
      _successMessage = 'Resume saved successfully!';
      _error = null;
    });
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) setState(() => _successMessage = null);
    });
  }
  @override
  void onError(String message) => setState(() => _error = message);
}

// Dialog for adding a language
class _LanguageDialog extends StatefulWidget {
  final Function(Language) onAdd;
  const _LanguageDialog({required this.onAdd});

  @override
  __LanguageDialogState createState() => __LanguageDialogState();
}

class __LanguageDialogState extends State<_LanguageDialog> {
  final TextEditingController _nameController = TextEditingController();
  ProficiencyLevel _level = ProficiencyLevel.intermediate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Language'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Language')),
          SizedBox(height: 8),
          DropdownButtonFormField<ProficiencyLevel>(
            value: _level,
            items: ProficiencyLevel.values.map((l) => DropdownMenuItem(value: l, child: Text(l.display))).toList(),
            onChanged: (val) => setState(() => _level = val!),
            decoration: InputDecoration(labelText: 'Proficiency'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              widget.onAdd(Language(name: _nameController.text.trim(), level: _level));
              Navigator.pop(context);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}

// Dialog for adding a skill
class _SkillDialog extends StatelessWidget {
  final Function(String) onAdd;
  final TextEditingController _controller = TextEditingController();
  _SkillDialog({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Skill'),
      content: TextField(controller: _controller, decoration: InputDecoration(labelText: 'Skill name')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              onAdd(_controller.text.trim());
              Navigator.pop(context);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}

// Dialog for adding work experience
class _WorkExperienceDialog extends StatefulWidget {
  final List<Company> companies;
  final Function(WorkExperience) onAdd;
  const _WorkExperienceDialog({required this.companies, required this.onAdd});

  @override
  __WorkExperienceDialogState createState() => __WorkExperienceDialogState();
}

class __WorkExperienceDialogState extends State<_WorkExperienceDialog> {
  Company? _selectedCompany;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _currentlyWorking = false;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Work Experience'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Company>(
              value: _selectedCompany,
              items: widget.companies.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
              onChanged: (val) => setState(() => _selectedCompany = val),
              decoration: InputDecoration(labelText: 'Company'),
              validator: (val) => val == null ? 'Select a company' : null,
            ),
            SizedBox(height: 8),
            ListTile(
              title: Text('Start Date'),
              subtitle: Text(_formatDate(_startDate)),
              onTap: () async {
                final date = await showDatePicker(context: context, initialDate: _startDate, firstDate: DateTime(2000), lastDate: DateTime.now());
                if (date != null) setState(() => _startDate = date);
              },
            ),
            Row(
              children: [
                Checkbox(value: _currentlyWorking, onChanged: (val) => setState(() => _currentlyWorking = val!)),
                Text('Currently working here'),
              ],
            ),
            if (!_currentlyWorking)
              ListTile(
                title: Text('End Date'),
                subtitle: Text(_endDate != null ? _formatDate(_endDate!) : 'Not set'),
                onTap: () async {
                  final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: _startDate, lastDate: DateTime.now());
                  if (date != null) setState(() => _endDate = date);
                },
              ),
            TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Description (optional)'), maxLines: 3),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_selectedCompany != null) {
              widget.onAdd(WorkExperience(
                companyId: _selectedCompany!.id,
                companyName: _selectedCompany!.name,
                startDate: _startDate,
                endDate: _currentlyWorking ? null : _endDate,
                description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
              ));
              Navigator.pop(context);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}