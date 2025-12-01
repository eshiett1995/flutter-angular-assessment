import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    // Determine the correct URL based on platform
    String url;
    if (Platform.isAndroid) {
      // For Android emulator, use 10.0.2.2 to access host machine's localhost
      url = 'http://10.0.2.2:4200';
    } else if (Platform.isIOS) {
      // For iOS simulator, use localhost
      url = 'http://localhost:4200';
    } else {
      // For web/desktop
      url = 'http://localhost:4200';
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _error = _getErrorMessage(error);
            });
          },
          onHttpError: (HttpResponseError error) {
            setState(() {
              _isLoading = false;
              _error = 'HTTP Error ${error.response?.statusCode ?? "Unknown"}: Failed to load dashboard';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  String _getErrorMessage(WebResourceError error) {
    if (error.description.contains('Failed host lookup') || 
        error.description.contains('Network is unreachable')) {
      return 'Cannot connect to the Angular server. Please ensure:\n\n'
          '1. The Angular app is running on port 4200\n'
          '2. Your device/emulator can access localhost\n'
          '3. No firewall is blocking the connection';
    } else if (error.description.contains('Connection refused')) {
      return 'Connection refused. The Angular server may not be running.\n\n'
          'To start it, run: cd webpage && npm start';
    } else {
      return 'Failed to load dashboard: ${error.description}\n\n'
          'Make sure the Angular app is running on port 4200.';
    }
  }

  Future<void> _retryLoad() async {
    if (_isRetrying || _retryCount >= _maxRetries) return;

    setState(() {
      _isRetrying = true;
      _isLoading = true;
      _error = null;
      _retryCount++;
    });

    try {
      await Future.delayed(Duration(seconds: _retryCount));
      await _controller.reload();
      
      // Wait a bit to see if it loads successfully
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRetrying = false;
          _isLoading = false;
          if (_retryCount >= _maxRetries) {
            _error = 'Failed to load after $_maxRetries attempts. Please check your connection and try again.';
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internal Tools Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_error != null && !_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_retryCount < _maxRetries) ...[
                      ElevatedButton.icon(
                        onPressed: _isRetrying ? null : _retryLoad,
                        icon: _isRetrying
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh),
                        label: Text(_isRetrying
                            ? 'Retrying...'
                            : _retryCount > 0
                                ? 'Retry (${_retryCount}/$_maxRetries)'
                                : 'Retry'),
                      ),
                      if (_retryCount > 0) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _retryCount = 0;
                              _error = null;
                              _isLoading = true;
                            });
                            _controller.reload();
                          },
                          child: const Text('Reset and Try Again'),
                        ),
                      ],
                    ] else ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _retryCount = 0;
                            _error = null;
                            _isLoading = true;
                          });
                          _controller.reload();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Start Over'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'To start the Angular server, run:\ncd webpage && npm start',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

