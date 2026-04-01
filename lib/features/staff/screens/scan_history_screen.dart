import 'package:flutter/material.dart';
import '../../../../data/repositories/ticket_repository.dart';
import '../../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  final TicketRepository _ticketRepository = TicketRepository();
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final result = await _ticketRepository.getScanHistory();
      setState(() { _history = result; });
    } catch (e) {
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDay = DateTime(dt.year, dt.month, dt.day);

    if (itemDay == today) return 'Today';
    if (itemDay == yesterday) return 'Yesterday';
    return DateFormat('EEEE, MMM d, y').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scan History'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_history.length} total',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadHistory, child: const Text('Retry')),
                    ],
                  ),
                )
              : _history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text('No scan history yet',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadHistory,
                      child: _buildGroupedList(),
                    ),
    );
  }

  Widget _buildGroupedList() {
    // Build grouped sections: group by date label
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in _history) {
      final raw = item['checkedInAt'];
      final dt = raw != null ? DateTime.parse(raw).toLocal() : DateTime.now();
      final label = _dateLabel(dt);
      grouped.putIfAbsent(label, () => []).add(item);
    }

    // Preserve insertion order (already sorted: newest first from backend)
    final items = <Widget>[];
    for (final group in grouped.entries) {
      // Section header
      items.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  group.key,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${group.value.length} scan${group.value.length == 1 ? '' : 's'}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      );

      // Cards for each scan
      for (final item in group.value) {
        final user = item['user'] is Map ? item['user'] as Map : {};
        final event = item['event'] is Map ? item['event'] as Map : {};
        final raw = item['checkedInAt'];
        final dt = raw != null ? DateTime.parse(raw).toLocal() : DateTime.now();

        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
              ),
              color: Colors.white,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Colors.green[50],
                  child: Text(
                    (user['name'] as String? ?? 'U').substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  user['name'] ?? 'Unknown User',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.event, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event['name'] ?? 'Unknown Event',
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('h:mm a').format(dt),
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    if (user['email'] != null)
                      Text(
                        user['email'],
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Checked In',
                    style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    items.add(const SizedBox(height: 20));

    return ListView(children: items);
  }
}


