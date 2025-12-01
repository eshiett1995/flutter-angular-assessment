import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messaging_app/main.dart';

void main() {
  testWidgets('App launches and shows home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MessagingApp());
    await tester.pumpAndSettle();

    // Verify that the app shows the messages screen by default
    expect(find.text('Support Chat'), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);
  });

  testWidgets('Navigation between Messages and Dashboard works', (WidgetTester tester) async {
    await tester.pumpWidget(const MessagingApp());
    await tester.pumpAndSettle();

    // Verify Messages screen is shown
    expect(find.text('Support Chat'), findsOneWidget);

    // Tap on Dashboard tab
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();

    // Verify Dashboard screen is shown
    expect(find.text('Internal Tools Dashboard'), findsOneWidget);

    // Tap back on Messages tab
    await tester.tap(find.text('Messages'));
    await tester.pumpAndSettle();

    // Verify Messages screen is shown again
    expect(find.text('Support Chat'), findsOneWidget);
  });

  testWidgets('Messages screen shows welcome message or empty state', (WidgetTester tester) async {
    await tester.pumpWidget(const MessagingApp());
    await tester.pumpAndSettle();

    // Check for welcome message or empty state
    final welcomeText = find.textContaining('Welcome to our support chat');
    final emptyStateText = find.textContaining('No messages yet');
    
    // At least one of these should be present
    final hasWelcome = welcomeText.evaluate().isNotEmpty;
    final hasEmptyState = emptyStateText.evaluate().isNotEmpty;
    
    expect(
      hasWelcome || hasEmptyState,
      isTrue,
      reason: 'Should show either welcome message or empty state',
    );
  });

  testWidgets('User can send a message', (WidgetTester tester) async {
    await tester.pumpWidget(const MessagingApp());
    await tester.pumpAndSettle();

    // Find the text field
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Enter a message
    await tester.enterText(textField, 'Hello, this is a test message');
    await tester.pump();

    // Find and tap the send button
    final sendButton = find.byIcon(Icons.send);
    expect(sendButton, findsOneWidget);
    await tester.tap(sendButton);
    await tester.pump();

    // Wait for message to appear
    await tester.pumpAndSettle();

    // Verify the message appears in the chat
    expect(find.text('Hello, this is a test message'), findsOneWidget);
  });

  testWidgets('Clear messages functionality works', (WidgetTester tester) async {
    await tester.pumpWidget(const MessagingApp());
    await tester.pumpAndSettle();

    // Send a message first
    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Test message');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    // Verify message is there
    expect(find.text('Test message'), findsOneWidget);

    // Tap clear button
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    // Confirm deletion in dialog
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    // Message should be gone (or replaced with welcome message)
    expect(find.text('Test message'), findsNothing);
  });
}
