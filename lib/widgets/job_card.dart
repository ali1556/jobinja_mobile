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
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: job.companyLogo != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(job.companyLogo!, fit: BoxFit.cover),
                )
                    : Icon(Icons.business, size: 30, color: Colors.blue[600]),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CompanyScreen(companySlug: job.companySlug),
                          ),
                        );
                      },
                      child: Text(
                        '${job.companyName} · ${job.location}',
                        style: TextStyle(color: Colors.blue[700], fontSize: 12),
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.work_outline, size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(job.contractType, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        SizedBox(width: 12),
                        Icon(Icons.attach_money, size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(job.salaryDisplay, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (job.isRemote)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Remote', style: TextStyle(fontSize: 10, color: Colors.green[800])),
                    ),
                  SizedBox(height: 4),
                  Text(
                    job.publishedAt,
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}