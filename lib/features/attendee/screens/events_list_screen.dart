import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/event_provider.dart';
import '../widgets/event_card.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/shimmer_widget.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Events')),
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.events.isEmpty) {
            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                   return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth > 900 ? 3 : 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 6,
                    itemBuilder: (_, __) => const ShimmerWidget.rectangular(height: 200),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, __) => const ShimmerWidget.rectangular(height: 280),
                );
              },
            );
          }

          if (provider.error != null && provider.events.isEmpty) {
            return ErrorRetryWidget(
              message: provider.error!,
              onRetry: () => provider.fetchEvents(refresh: true),
            );
          }

          if (provider.events.isEmpty) {
            return EmptyStateWidget(
              title: 'No Events Found',
              subtitle: 'Check back later for upcoming events!',
              icon: Icons.event_busy,
              action: ElevatedButton(
                onPressed: () => provider.fetchEvents(refresh: true),
                child: const Text('Refresh'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchEvents(refresh: true),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth > 900 ? 3 : 2,
                      childAspectRatio: 0.85, // Adjusted ratio for card content
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: provider.events.length,
                    itemBuilder: (context, index) {
                      final event = provider.events[index];
                      return EventCard(
                        event: event,
                        onTap: () => context.push('/attendee/events/${event.id}'),
                      );
                    },
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final event = provider.events[index];
                    return EventCard(
                      event: event,
                      onTap: () => context.push('/attendee/events/${event.id}'),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
