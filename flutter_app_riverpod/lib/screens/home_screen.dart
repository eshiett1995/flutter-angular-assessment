import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'messages_screen.dart';
import 'dashboard_screen.dart';
import '../providers/message_provider.dart';
import '../providers/ui_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);
    final currentIndex = ref.watch(currentTabIndexProvider);

    final List<Widget> screens = [
      const MessagesScreen(),
      const DashboardScreen(),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          // Use StateProvider instead of setState
          ref.read(currentTabIndexProvider.notifier).state = index;
          // Mark messages as read when viewing Messages screen
          if (index == 0) {
            ref.read(messageProvider.notifier).markAsRead();
          }
        },
        destinations: [
          NavigationDestination(
            icon: Badge(
              label: unreadCount > 0 ? Text('$unreadCount') : null,
              isLabelVisible: unreadCount > 0,
              child: const Icon(Icons.chat_bubble_outline),
            ),
            selectedIcon: Badge(
              label: unreadCount > 0 ? Text('$unreadCount') : null,
              isLabelVisible: unreadCount > 0,
              child: const Icon(Icons.chat_bubble),
            ),
            label: 'Messages',
          ),
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }
}
