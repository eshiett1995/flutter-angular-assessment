import 'package:flutter/material.dart';
import 'messages_screen.dart';
import 'dashboard_screen.dart';
import '../services/message_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _unreadCount = 0;
  final MessageService _messageService = MessageService.instance;

  final List<Widget> _screens = [
    const MessagesScreen(),
    const DashboardScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Listen to unread count changes
    _messageService.unreadCountStream.listen((count) {
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    });
    // Get initial unread count
    _unreadCount = _messageService.unreadCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Mark messages as read when viewing Messages screen
          if (index == 0) {
            _messageService.markAsRead();
          }
        },
        destinations: [
          NavigationDestination(
            icon: Badge(
              label: _unreadCount > 0 ? Text('$_unreadCount') : null,
              isLabelVisible: _unreadCount > 0,
              child: const Icon(Icons.chat_bubble_outline),
            ),
            selectedIcon: Badge(
              label: _unreadCount > 0 ? Text('$_unreadCount') : null,
              isLabelVisible: _unreadCount > 0,
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

