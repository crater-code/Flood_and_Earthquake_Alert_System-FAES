// lib/screens/ngo_report_management_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';

class NGOReportManagementScreen extends StatefulWidget {
  const NGOReportManagementScreen({super.key});

  @override
  State<NGOReportManagementScreen> createState() => _NGOReportManagementScreenState();
}

class _NGOReportManagementScreenState extends State<NGOReportManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.getAllReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              leading: Navigator.canPop(context) ? IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: () => Navigator.pop(context),
              ) : null,
              title: const Text('Manage Reports'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        
        final reports = snapshot.data ?? [];
        
        return Scaffold(
          appBar: AppBar(
            leading: Navigator.canPop(context) ? IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: () => Navigator.pop(context),
            ) : null,
            title: const Text('Manage Reports'),
          ),
          body: reports.isEmpty 
            ? const Center(
                child: Text(
                  'No reports available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: reports.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) {
                  final report = reports[i];
                  return ListTile(
                    leading: Icon(
                      _getReportIcon(report['type']),
                      color: _getReportColor(report['type']),
                    ),
                    title: Text(report['title'] ?? 'Emergency Report'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Severity: ${report['severity']} • Status: ${report['status']}'),
                        Text(
                          'Location: ${report['locationName'] ?? 'Unknown'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          'Reported by: ${report['userName'] ?? 'Anonymous'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    trailing: DropdownButton<String>(
                      value: report['status'],
                      items: const [
                        DropdownMenuItem(value: 'ACTIVE', child: Text('Active')), 
                        DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')), 
                        DropdownMenuItem(value: 'RESOLVED', child: Text('Resolved'))
                      ],
                      onChanged: (newStatus) {
                        if (newStatus != null) {
                          // For demo purposes, this would update the report status
                          // In a real app, this would call ApiService.updateReportStatus
                          print('Status changed to: $newStatus for report ${report['id']}');
                          
                          // Trigger a rebuild to show the change
                          setState(() {});
                        }
                      },
                    ),
                    onTap: () {
                      _showReportDetails(context, report);
                    },
                  );
                },
              ),
        );
      },
    );
  }

  IconData _getReportIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'FLOOD':
        return Icons.water_drop;
      case 'EARTHQUAKE':
        return Icons.terrain;
      case 'FIRE':
        return Icons.local_fire_department;
      case 'LANDSLIDE':
        return Icons.landscape;
      default:
        return Icons.warning;
    }
  }

  Color _getReportColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'FLOOD':
        return Colors.blue;
      case 'EARTHQUAKE':
        return Colors.orange;
      case 'FIRE':
        return Colors.red;
      case 'LANDSLIDE':
        return Colors.brown;
      default:
        return Colors.purple;
    }
  }

  void _showReportDetails(BuildContext context, Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report['title'] ?? 'Emergency Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${report['type']}'),
            Text('Severity: ${report['severity']}'),
            Text('Status: ${report['status']}'),
            Text('Location: ${report['locationName']}'),
            Text('Reported by: ${report['userName']}'),
            const SizedBox(height: 8),
            Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(report['description'] ?? 'No description'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
