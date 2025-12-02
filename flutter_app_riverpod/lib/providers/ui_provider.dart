import 'package:flutter_riverpod/flutter_riverpod.dart';

// Emoji picker visibility state - autoDispose since it's UI-only
final emojiPickerVisibleProvider = StateProvider.autoDispose<bool>((ref) => false);

// Current tab index in home screen - persists across navigation
final currentTabIndexProvider = StateProvider<int>((ref) => 0);

