import 'package:flutter/material.dart';
import '../models/job.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const JobCard({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: job.companyLogo != null ? CircleAvatar(backgroundImage: NetworkImage(job.companyLogo!)) : Icon(Icons.business),
        title: Text(job.title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${job.companyName} - ${job.location}'),
        trailing: Text(job.salaryDisplay, style: TextStyle(fontSize: 12)),
        onTap: onTap,
      ),
    );
  }
}