import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/sip_service_manager.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPage({Key? key, required this.url, required this.title})
    : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? webViewController;
  bool isLoading = true;
  String? errorMessage;
  bool _hasShownPermissionDialog = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndInitialize();
  }

  @override
  void dispose() {
    SipServiceManager.stopService();
    super.dispose();
  }

  Future<void> _checkPermissionsAndInitialize() async {
    try {
      // Request camera and microphone permissions
      await Permission.camera.request();
      await Permission.microphone.request();
      await Permission.location.request();

      // Start SIP service
      await SipServiceManager.startService();
    } catch (e) {
      // Silent fail
    }
  }

  @override
  Widget build(BuildContext context) {
    final blue = const Color(0xFF1E3A8A);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (webViewController != null)
            IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              onPressed: _launchNativeCamera,
              tooltip: 'Open Camera',
            ),
          if (webViewController != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => webViewController?.reload(),
            ),
        ],
      ),
      body: Stack(
        children: [
          if (errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        errorMessage = null;
                        isLoading = true;
                      });
                      _checkPermissionsAndInitialize();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          else
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsBackForwardNavigationGestures: true,
                allowsLinkPreview: true,
                geolocationEnabled: true,
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                domStorageEnabled: true,
                databaseEnabled: true,
                hardwareAcceleration: true, // Enable for better performance
                safeBrowsingEnabled: false,
                thirdPartyCookiesEnabled: true,
                userAgent:
                    "Mozilla/5.0 (Linux; Android 11; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
                cacheEnabled: true,
                cacheMode: CacheMode.LOAD_DEFAULT,
                supportZoom: false,
                builtInZoomControls: false,
                displayZoomControls: false,
                textZoom: 100,
                minimumFontSize: 1,
                networkAvailable: true,
                allowFileAccess: false,
                allowFileAccessFromFileURLs: false,
                allowUniversalAccessFromFileURLs: false,
                // Additional settings for stability
                useOnDownloadStart: false,
                useOnLoadResource: false,
                useShouldOverrideUrlLoading: false,
                useShouldInterceptAjaxRequest: false,
                useShouldInterceptFetchRequest: false,
                useOnRenderProcessGone: true,
                // WebView process isolation
                // Enable camera-friendly features
                javaScriptCanOpenWindowsAutomatically: true,
                allowsInlineMediaPlayback: true,
                allowsAirPlayForMediaPlayback: true,
                allowsPictureInPictureMediaPlayback: true,
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                if (mounted) {
                  setState(() {
                    isLoading = true;
                  });
                }
              },
              onLoadStop: (controller, url) async {
                if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }

                if (!_hasShownPermissionDialog && mounted) {
                  _hasShownPermissionDialog = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showWebViewPermissionDialog();
                  });
                }

                _injectNavigationPreventionScript();
              },
              onReceivedError: (controller, request, error) {
                if (mounted) {
                  setState(() {
                    errorMessage = 'Failed to load page: ${error.description}';
                    isLoading = false;
                  });
                }
              },
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                return ServerTrustAuthResponse(
                  action: ServerTrustAuthResponseAction.PROCEED,
                );
              },
              onRenderProcessGone: (controller, detail) async {
                // Handle WebView renderer crashes gracefully
                if (mounted) {
                  setState(() {
                    errorMessage = 'WebView crashed. Reloading...';
                    isLoading = true;
                  });

                  // Wait a moment then reload
                  await Future.delayed(const Duration(seconds: 3));
                  await controller.reload();

                  setState(() {
                    errorMessage = null;
                    isLoading = false;
                  });
                }
              },
              onPermissionRequest: (controller, request) async {
                // Grant ALL permissions including camera
                return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT,
                );
              },
              onConsoleMessage: (controller, consoleMessage) {
                // Silent console messages
              },
              onJsAlert: (controller, jsAlertRequest) async {
                return JsAlertResponse(handledByClient: true);
              },
              onJsConfirm: (controller, jsConfirmRequest) async {
                return JsConfirmResponse(
                  handledByClient: true,
                  action: JsConfirmResponseAction.CONFIRM,
                );
              },
            ),
          if (isLoading)
            Container(
              color: Colors.white,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  void _showWebViewPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('WebView Permissions'),
          content: const Text(
            'This WebView may request camera and microphone access. Please allow these permissions when prompted.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _injectNavigationPreventionScript() async {
    try {
      await webViewController?.evaluateJavascript(
        source: '''
        // Enhanced camera support with stability improvements
        if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
          const originalGetUserMedia = navigator.mediaDevices.getUserMedia.bind(navigator.mediaDevices);
          
          navigator.mediaDevices.getUserMedia = function(constraints) {
            console.log('Camera access requested with constraints:', constraints);
            
            // Add timeout to prevent hanging
            const timeoutPromise = new Promise((_, reject) => {
              setTimeout(() => reject(new Error('Camera access timeout after 15 seconds')), 15000);
            });
            
            const cameraPromise = originalGetUserMedia(constraints);
            
            return Promise.race([cameraPromise, timeoutPromise])
              .then(function(stream) {
                console.log('Camera access successful');
                return stream;
              })
              .catch(function(error) {
                console.error('Camera access failed:', error);
                // Show helpful error message
                alert('Camera access failed: ' + error.message + '\\n\\nPlease ensure camera permissions are granted and try again.');
                throw error;
              });
          };
        }
        
        // Prevent navigation back during camera operations
        let isCameraActive = false;
        
        const originalBack = history.back;
        history.back = function() {
          if (isCameraActive) {
            console.log('Back navigation blocked during camera operation');
            return;
          }
          originalBack.call(history);
        };
        
        const originalGo = history.go;
        history.go = function(delta) {
          if (isCameraActive && delta < 0) {
            console.log('Back navigation blocked during camera operation');
            return;
          }
          originalGo.call(history, delta);
        };
        
        // Monitor camera state
        if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
          const originalGetUserMedia = navigator.mediaDevices.getUserMedia.bind(navigator.mediaDevices);
          
          navigator.mediaDevices.getUserMedia = function(constraints) {
            isCameraActive = true;
            console.log('Camera operation started');
            
            return originalGetUserMedia(constraints)
              .then(function(stream) {
                isCameraActive = false;
                console.log('Camera operation completed successfully');
                return stream;
              })
              .catch(function(error) {
                isCameraActive = false;
                console.log('Camera operation failed');
                throw error;
              });
          };
        }
        
        console.log('Enhanced camera support script loaded');
      ''',
      );
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _launchNativeCamera() async {
    try {
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        Get.snackbar(
          'Camera Permission',
          'Camera permission is required to take photos',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Launch native camera
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        Get.snackbar(
          'Photo Captured',
          'Photo saved successfully: ${image.name}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        // You can add logic here to upload the image to the HR portal
        // or pass it back to the WebView if needed
      }
    } catch (e) {
      Get.snackbar(
        'Camera Error',
        'Failed to open camera: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
