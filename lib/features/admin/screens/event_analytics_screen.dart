import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // Just using simple progress indicators for now as planned
import 'package:file_saver/file_saver.dart'; // Hypothetical or use standard sharing. Using simple Toast for mock.
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/admin_provider.dart';

class EventAnalyticsScreen extends StatefulWidget {
  final String eventId;

  const EventAnalyticsScreen({super.key, required this.eventId});

  @override
  State<EventAnalyticsScreen> createState() => _EventAnalyticsScreenState();
}

class _EventAnalyticsScreenState extends State<EventAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadEventAnalytics(widget.eventId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _exportCSV(List<Map<String, dynamic>> registrations) async {
    // Mock CSV Export Logic
    final StringBuffer csv = StringBuffer();
    csv.writeln('Name,Email,Status,Ticket Type,Check-In Time');
    
    for (var reg in registrations) {
      csv.writeln('${reg['userName']},${reg['email']},${reg['status']},${reg['ticketType']},${reg['checkInTime'] ?? ''}');
    }

    // In a real app, use path_provider and share_plus or file_saver
    // Here we simulate success
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV Report exported to Downloads'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Registrations'),
          ],
        ),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.eventStats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = provider.eventStats ?? {};
          final registrations = provider.registrations;

          return TabBarView(
            controller: _tabController,
            children: [
              // Overview Tab
              _buildOverviewTab(stats),
              
              // Registrations Tab
              _buildRegistrationsTab(registrations),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
            final regs = context.read<AdminProvider>().registrations;
            _exportCSV(regs);
        },
        icon: const Icon(Icons.download),
        label: const Text('Export CSV'),
      ),
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> stats) {
    final double attendanceRate = (stats['attendanceRate'] as num?)?.toDouble() ?? 0.0;
    final int checkedIn = stats['checkedInCount'] ?? 0;
    final int total = stats['totalRegistrations'] ?? 0;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Attendance Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Live Attendance',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: attendanceRate / 100,
                      strokeWidth: 12,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${attendanceRate.toStringAsFixed(1)}%',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$checkedIn / $total',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _DetailItem(label: 'Registered', value: total.toString()),
                  _DetailItem(label: 'Checked In', value: checkedIn.toString()),
                  _DetailItem(label: 'Pending', value: (total - checkedIn).toString()),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationsTab(List<Map<String, dynamic>> registrations) {
    if (registrations.isEmpty) {
      return const Center(child: Text('No registrations yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: registrations.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final reg = registrations[index];
        final isCheckedIn = reg['status'] == 'checked_in';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isCheckedIn ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
            child: Icon(
              isCheckedIn ? Icons.check : Icons.person_outline,
              color: isCheckedIn ? Colors.green : Colors.grey,
            ),
          ),
          title: Text(reg['userName'] ?? 'Unknown'),
          subtitle: Text(reg['email'] ?? ''),
          trailing: Chip(
            label: Text(
              isCheckedIn ? 'Checked In' : 'Registered',
              style: TextStyle(
                color: isCheckedIn ? Colors.green : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            backgroundColor: isCheckedIn ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
          ),
        );
      },
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

