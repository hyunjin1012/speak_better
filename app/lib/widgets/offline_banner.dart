import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';

/// Provider for connectivity status
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  final connectivity = Connectivity();
  return connectivity.onConnectivityChanged;
});

/// Banner widget that shows when device is offline
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);
    // Detect language from locale
    final locale = Localizations.localeOf(context);
    final isKorean = locale.languageCode == 'ko';

    return connectivityAsync.when(
      data: (results) {
        final isOffline = results.contains(ConnectivityResult.none);
        if (!isOffline) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: AppPadding.allSm,
          color: Colors.orange,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 16),
              AppSpacing.widthSm,
              Text(
                isKorean ? '오프라인 모드' : 'Offline Mode',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
