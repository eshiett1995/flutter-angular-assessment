import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'providers/theme_provider.dart';

// ProviderObserver for debugging - logs provider updates
class AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // Only log in debug mode to avoid performance issues
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      final providerName = provider.name ?? provider.runtimeType.toString();
      print('🔄 Provider updated: $providerName');
    }
  }

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      final providerName = provider.name ?? provider.runtimeType.toString();
      print('➕ Provider added: $providerName');
    }
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      final providerName = provider.name ?? provider.runtimeType.toString();
      print('🗑️ Provider disposed: $providerName');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      observers: [AppProviderObserver()],
      child: const MessagingApp(),
    ),
  );
}

class MessagingApp extends ConsumerWidget {
  const MessagingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);

    return MaterialApp(
      title: 'Messaging App (Riverpod)',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
