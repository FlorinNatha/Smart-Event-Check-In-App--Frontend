import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/scan_provider.dart';
import '../../../core/widgets/common_widgets.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ScanProvider>().fetchHistory();
            },
          ),
        ],
      ),
      body: Consumer<ScanProvider>(
        builder: (context, provider, child) {
          if (provider.scanHistory.isEmpty) {
            return EmptyStateWidget(
              title: 'No Recent Scans',
              subtitle: 'Your ticket validation history will appear here.',
              icon: Icons.history,
              action: ElevatedButton(
                onPressed: () => provider.fetchHistory(),
                child: const Text('Refresh'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchHistory(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.scanHistory.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final log = provider.scanHistory[index];
                final timestamp = DateTime.tryParse(log['timestamp']) ?? DateTime.now();
                final isSuccess = log['status'] == 'valid';
                final details = log['details'] as Map<String, dynamic>? ?? {};

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSuccess ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                      child: Icon(
                        isSuccess ? Icons.check : Icons.close,
                        color: isSuccess ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      details['attendeeName'] ?? 'Unknown Attendee',
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      DateFormat.jms().format(timestamp),
                      style: AppTextStyles.bodySmall,
                    ),
                    trailing: Text(
                      isSuccess ? 'VALID' : 'INVALID',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSuccess ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

