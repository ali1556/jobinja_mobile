import 'package:flutter/material.dart';
import '../models/job.dart';
import '../views/company_screen.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const JobCard({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: job.companyLogo != null 
                ? CircleAvatar(backgroundImage: NetworkImage(job.companyLogo!)) 
                : Icon(Icons.business),
            title: Text(job.title, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CompanyScreen(companySlug: job.companySlug),
                  ),
                );
              },
              child: Text(
                '${job.companyName} - ${job.location}',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            trailing: Text(job.salaryDisplay, style: TextStyle(fontSize: 12)),
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}