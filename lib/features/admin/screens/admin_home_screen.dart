import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/admin_provider.dart';

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
            onRefresh: () => provider.loadDashboardStats(),
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
                                ),
                                _StatCard(
                                  title: 'Registrations',
                                  value: stats['totalRegistrations']?.toString() ?? '0',
                                  icon: Icons.people,
                                  color: AppColors.secondary,
                                ),
                                _StatCard(
                                  title: 'Check-ins',
                                  value: stats['totalCheckIns']?.toString() ?? '0',
                                  icon: Icons.check_circle,
                                  color: AppColors.success,
                                ),
                                _StatCard(
                                  title: 'Attendance',
                                  value: '${stats['attendanceRate']?.toString() ?? '0'}%',
                                  icon: Icons.analytics,
                                  color: AppColors.accent,
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
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.displaySmall.copyWith(
              color: color,
              fontSize: 28, // Fix font size for better fit
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
    );
  }
}

