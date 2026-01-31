import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      // Connectivity().onConnectivityChanged is a Stream<List<ConnectivityResult>> in version 6.0+
      stream: Connectivity().onConnectivityChanged, // The plus package
      builder: (context, snapshot) {
         final connectivity = snapshot.data;
         final isOffline = connectivity != null && connectivity.contains(ConnectivityResult.none);
         
         // In many cases, on connectivity changed might not emit immediately.
         // We might want to assume online or check async initially, but StreamBuilder handles updates.
         // If snapshot doesn't have data yet, we assume online.
         
         if (snapshot.hasData && isOffline) {
             return Container(
                 color: const Color(0xFFEF4444), // Red color
                 padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                 width: double.infinity,
                 child: const Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(Icons.wifi_off, color: Colors.white, size: 16),
                     SizedBox(width: 8),
                     Text(
                       'You are currently offline',
                       textAlign: TextAlign.center,
                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                     ),
                   ],
                 ),
             );
         }
         return const SizedBox.shrink();
      }
    );
  }
}
