import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../../attendee/providers/event_provider.dart';

/// Admin home screen
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboardStats();
      context.read<EventProvider>().fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              context.read<AdminProvider>().reset();
              context.read<EventProvider>().reset();
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          final stats = provider.dashboardStats ?? {};
          final isLoading = provider.isLoading;

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadDashboardStats();
              if (context.mounted) {
                await context.read<EventProvider>().fetchEvents(refresh: true);
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user?.name ?? 'Admin'}',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage your events and analytics',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Responsive Stats Grid
                  isLoading && stats.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 600;
                            return GridView.count(
                              crossAxisCount: isWide ? 4 : 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: isWide ? 1.5 : 1.2,
                              children: [
                                _StatCard(
                                  title: 'Total Events',
                                  value: stats['totalEvents']?.toString() ?? '0',
                                  icon: Icons.event,
                                  color: AppColors.primary,
                                  onTap: () => _showDetailsBottomSheet(context, 'events', provider),
                                ),
                                _StatCard(
                                  title: 'Registrations',
                                  value: stats['totalRegistrations']?.toString() ?? '0',
                                  icon: Icons.people,
                                  color: AppColors.secondary,
                                  onTap: () => _showDetailsBottomSheet(context, 'registrations', provider),
                                ),
                                _StatCard(
                                  title: 'Check-ins',
                                  value: stats['totalCheckIns']?.toString() ?? '0',
                                  icon: Icons.check_circle,
                                  color: AppColors.success,
                                  onTap: () => _showDetailsBottomSheet(context, 'checkins', provider),
                                ),
                                _StatCard(
                                  title: 'Attendance',
                                  value: '${stats['attendanceRate']?.toString() ?? '0'}%',
                                  icon: Icons.analytics,
                                  color: AppColors.accent,
                                  onTap: () => _showDetailsBottomSheet(context, 'attendance', provider),
                                ),
                              ],
                            );
                          },
                        ),

                  const SizedBox(height: 32),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: AppTextStyles.headlineSmall,
                  ),

                  const SizedBox(height: 16),

                  CustomButton(
                    text: 'Create Event',
                    icon: Icons.add,
                    onPressed: () => context.push('/admin/events/create'),
                    variant: ButtonVariant.gradient,
                  ),

                  const SizedBox(height: 12),

                  CustomButton(
                    text: 'Manage Events',
                    icon: Icons.event_note,
                    onPressed: () => context.push('/admin/events'),
                    variant: ButtonVariant.outline,
                  ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDetailsBottomSheet(BuildContext context, String type, AdminProvider adminProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: _buildBottomSheetContent(type, adminProvider, controller),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomSheetContent(String type, AdminProvider adminProvider, ScrollController controller) {
    if (type == 'events') {
       final events = context.read<EventProvider>().events;
       return Column(
          children: [
             Text('Total Events', style: AppTextStyles.headlineSmall),
             const SizedBox(height: 16),
             Expanded(
                child: ListView.builder(
                   controller: controller,
                   itemCount: events.length,
                   itemBuilder: (ctx, i) => ListTile(
                      leading: const Icon(Icons.event_available, color: AppColors.primary),
                      title: Text(events[i].name, style: AppTextStyles.titleMedium), 
                      subtitle: Text(events[i].location),
                   ),
                )
             )
          ]
       );
    }
    
    final allRegs = adminProvider.allRegistrations;

    // Group by event _id (not name) so same-named events stay separate
    // Store a Map from eventId -> { 'label': 'Name • Location • Date', 'regs': [...] }
    final Map<String, Map<String, dynamic>> groupedById = {};
    for (var reg in allRegs) {
       final eventData = reg['event'] as Map<String, dynamic>?;
       final eventId = eventData?['_id'] ?? eventData?['id'] ?? 'unknown';
       if (!groupedById.containsKey(eventId)) {
          final name = eventData?['name'] ?? 'Unknown Event';
          final location = eventData?['location'] ?? '';
          final rawDate = eventData?['date'];
          String dateStr = '';
          if (rawDate != null) {
             try {
                final dt = DateTime.parse(rawDate.toString());
                dateStr = '${dt.day}/${dt.month}/${dt.year}';
             } catch (_) {}
          }
          final label = [name, if (location.isNotEmpty) location, if (dateStr.isNotEmpty) dateStr].join(' • ');
          groupedById[eventId] = {'label': label, 'regs': <Map<String, dynamic>>[]};
       }
       (groupedById[eventId]!['regs'] as List<Map<String, dynamic>>).add(reg);
    }

    if (type == 'registrations') {
       return Column(
          children: [
             Text('Registrations per Event', style: AppTextStyles.headlineSmall),
             const SizedBox(height: 16),
             Expanded(
                child: ListView.builder(
                   controller: controller,
                   itemCount: groupedById.keys.length,
                   itemBuilder: (ctx, i) {
                      final eventId = groupedById.keys.elementAt(i);
                      final group = groupedById[eventId]!;
                      final label = group['label'] as String;
                      final regs = group['regs'] as List<Map<String, dynamic>>;
                      return ExpansionTile(
                         leading: const Icon(Icons.people, color: AppColors.secondary),
                         title: Text('${regs.length} registered', style: AppTextStyles.titleMedium),
                         subtitle: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                         children: regs.map((r) {
                            final userData = r['user'] as Map<String, dynamic>?;
                            return ListTile(
                               leading: const Icon(Icons.person, size: 20),
                               title: Text(userData?['name'] ?? 'Unknown'),
                               subtitle: Text(userData?['email'] ?? ''),
                            );
                         }).toList(),
                      );
                   },
                )
             )
          ]
       );
    }

    if (type == 'checkins') {
       return Column(
          children: [
             Text('Check-ins per Event', style: AppTextStyles.headlineSmall),
             const SizedBox(height: 16),
             Expanded(
                child: ListView.builder(
                   controller: controller,
                   itemCount: groupedById.keys.length,
                   itemBuilder: (ctx, i) {
                      final eventId = groupedById.keys.elementAt(i);
                      final group = groupedById[eventId]!;
                      final label = group['label'] as String;
                      final regs = (group['regs'] as List<Map<String, dynamic>>).where((r) => r['status'] == 'checked-in').toList();
                      if (regs.isEmpty) return const SizedBox.shrink();
                      return ExpansionTile(
                         leading: const Icon(Icons.check_circle, color: AppColors.success),
                         title: Text('${regs.length} checked in', style: AppTextStyles.titleMedium),
                         subtitle: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                         children: regs.map((r) {
                            final userData = r['user'] as Map<String, dynamic>?;
                            return ListTile(
                               leading: const Icon(Icons.check, size: 20, color: AppColors.success),
                               title: Text(userData?['name'] ?? 'Unknown'),
                               subtitle: Text(userData?['email'] ?? ''),
                            );
                         }).toList(),
                      );
                   },
                )
             )
          ]
       );
    }

    if (type == 'attendance') {
       return Column(
          children: [
             Text('Attendance Rates', style: AppTextStyles.headlineSmall),
             const SizedBox(height: 16),
             Expanded(
                child: ListView.builder(
                   controller: controller,
                   itemCount: groupedById.keys.length,
                   itemBuilder: (ctx, i) {
                      final eventId = groupedById.keys.elementAt(i);
                      final group = groupedById[eventId]!;
                      final label = group['label'] as String;
                      final regs = group['regs'] as List<Map<String, dynamic>>;
                      final checkedIn = regs.where((r) => r['status'] == 'checked-in').length;
                      final rate = regs.isEmpty ? 0.0 : (checkedIn / regs.length);
                      return ListTile(
                         title: Text(label, style: AppTextStyles.titleMedium),
                         contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                         subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               const SizedBox(height: 12),
                               LinearProgressIndicator(
                                 value: rate, 
                                 minHeight: 8,
                                 borderRadius: BorderRadius.circular(4),
                                 color: AppColors.accent, 
                                 backgroundColor: Colors.grey[200]
                               ),
                               const SizedBox(height: 8),
                               Text('${(rate * 100).toStringAsFixed(1)}% ($checkedIn / ${regs.length} attendees arrived)')
                            ]
                         )
                      );
                   },
                )
             )
          ]
       );
    }

    return const Center(child: Text('Unknown type'));
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    value,
                    style: AppTextStyles.displaySmall.copyWith(
                      color: color,
                      fontSize: 24, // Reduced font size for better fit
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

