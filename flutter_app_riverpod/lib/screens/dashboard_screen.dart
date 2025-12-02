import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/theme_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync theme when it changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncThemeToWebView();
    });
  }

  Future<void> _syncThemeToWebView() async {
    if (!mounted) return;
    
    try {
      final themeMode = ref.read(themeProvider);
      bool isDark;
      if (themeMode == ThemeMode.dark) {
        isDark = true;
      } else if (themeMode == ThemeMode.light) {
        isDark = false;
      } else {
        isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
      }
      
      final themeValue = isDark ? 'dark' : 'light';
      
      final jsCode = '''
        (function() {
          localStorage.setItem('theme_preference', '$themeValue');
          
          if (${isDark.toString()}) {
            document.documentElement.classList.add('dark');
          } else {
            document.documentElement.classList.remove('dark');
          }
          
          window.dispatchEvent(new CustomEvent('flutter-theme-changed', { 
            detail: { isDark: ${isDark.toString()} } 
          }));
        })();
      ''';
      
      await _controller.runJavaScript(jsCode);
    } catch (e) {
      print('Error syncing theme to WebView: $e');
    }
  }

  void _initializeWebView() {
    String url;
    if (Platform.isAndroid) {
      url = 'http://10.0.2.2:4200';
    } else if (Platform.isIOS) {
      url = 'http://localhost:4200';
    } else {
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
            if (mounted) {
              setState(() {
                _isLoading = false;
                _error = null;
                _retryCount = 0;
                _isRetrying = false;
              });
              _syncThemeToWebView();
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _error = _getErrorMessage(error);
              });
            }
          },
          onHttpError: (HttpResponseError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _error = 'HTTP Error ${error.response?.statusCode ?? "Unknown"}: Failed to load dashboard';
              });
            }
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
      await Future.delayed(Duration(milliseconds: 500 * _retryCount));
      await _controller.reload();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Internal Tools Dashboard'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
                _retryCount = 0;
                _isRetrying = false;
              });
              _controller.reload();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading || (_error != null && !_isLoading))
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Padding(
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
                                      _isRetrying = false;
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
                                    _isRetrying = false;
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
            ),
        ],
      ),
    );
  }
}
