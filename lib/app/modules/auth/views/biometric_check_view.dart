import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class BiometricCheckView extends StatefulWidget {
  const BiometricCheckView({super.key});

  @override
  State<BiometricCheckView> createState() => _BiometricCheckViewState();
}

class _BiometricCheckViewState extends State<BiometricCheckView> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // final AuthController controller = Get.find();
    final controller = Get.put(AuthController());
    final theme = Theme.of(context);
    const blue = Color(0xFF3B6EA5);
    const green = Color(0xFF6BC04B);
    const orange = Color(0xFFF7941D);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Image.asset(
                  'assets/app_logo.png',
                  height: 80,
                  width: 280,
                ),
              ),
              Card(
                elevation: 8,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Biometric Authentication',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: blue,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Icon(Icons.fingerprint, size: 80, color: green),
                      const SizedBox(height: 24),
                      const Text(
                        'Please verify your identity using biometric authentication.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 32),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.fingerprint,
                                  color: green,
                                ),
                                label: const Text('Verify Biometric'),
                                onPressed: () async {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    print(
                                      'Debug: Starting biometric verification...',
                                    );

                                    // Check if biometric is available
                                    final isAvailable = await controller
                                        .isBiometricAvailable();
                                    print(
                                      'Debug: Biometric available: $isAvailable',
                                    );

                                    if (!isAvailable) {
                                      setState(() {
                                        _isLoading = false;
                                      });

                                      Get.snackbar(
                                        'Biometric Not Available',
                                        'Biometric authentication is not available on this device.',
                                        backgroundColor: Colors.redAccent,
                                        colorText: Colors.white,
                                        duration: const Duration(seconds: 5),
                                      );
                                      return;
                                    }

                                    // Check if biometric is set up
                                    final biometricSetup = controller
                                        .isBiometricSetupComplete();
                                    if (!biometricSetup) {
                                      setState(() {
                                        _isLoading = false;
                                      });

                                      Get.snackbar(
                                        'Biometric Not Setup',
                                        'Biometric authentication is not set up. Please set it up first.',
                                        backgroundColor: Colors.redAccent,
                                        colorText: Colors.white,
                                        duration: const Duration(seconds: 5),
                                      );
                                      return;
                                    }

                                    print(
                                      'Debug: Proceeding with biometric authentication...',
                                    );

                                    // Perform biometric authentication
                                    final authenticated = await controller
                                        .authenticateWithBiometrics();

                                    if (authenticated) {
                                      print(
                                        'Debug: Authentication successful, navigating to home...',
                                      );

                                      // Show success message
                                      Get.snackbar(
                                        'Success',
                                        'Biometric authentication successful!',
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                      );

                                      // Reset loading state
                                      setState(() {
                                        _isLoading = false;
                                      });

                                      // Navigate to home after a brief delay
                                      Future.delayed(
                                        const Duration(milliseconds: 1000),
                                        () {
                                          Get.offAllNamed(AppRoutes.home);
                                        },
                                      );
                                    } else {
                                      setState(() {
                                        _isLoading = false;
                                      });

                                      print('Debug: Authentication failed');
                                      Get.snackbar(
                                        'Authentication Failed',
                                        'Biometric authentication failed. Please try again.',
                                        backgroundColor: Colors.redAccent,
                                        colorText: Colors.white,
                                        duration: const Duration(seconds: 5),
                                      );
                                    }
                                  } catch (e) {
                                    setState(() {
                                      _isLoading = false;
                                    });

                                    print(
                                      'Debug: Exception during biometric verification: $e',
                                    );

                                    String errorMessage =
                                        'Failed to verify biometric authentication.';
                                    if (e.toString().contains(
                                      'no_fragment_activity',
                                    )) {
                                      errorMessage =
                                          'App configuration issue. Please restart the app and try again.';
                                    } else if (e.toString().contains(
                                      'NotAvailable',
                                    )) {
                                      errorMessage =
                                          'Biometric hardware not available on this device.';
                                    } else if (e.toString().contains(
                                      'NotEnrolled',
                                    )) {
                                      errorMessage =
                                          'No biometrics enrolled. Please set up fingerprint in device settings.';
                                    } else if (e.toString().contains(
                                      'UserCancel',
                                    )) {
                                      errorMessage =
                                          'Authentication was cancelled. Please try again.';
                                    }

                                    Get.snackbar(
                                      'Verification Error',
                                      errorMessage,
                                      backgroundColor: Colors.redAccent,
                                      colorText: Colors.white,
                                      duration: const Duration(seconds: 5),
                                    );
                                  }
                                },
                              ),
                            ),
                      const SizedBox(height: 16),
                      // TextButton(
                      //   onPressed: () {
                      //     // Option to go back or use alternative authentication
                      //     Get.back();
                      //   },
                      //   child: Text(
                      //     'Use different authentication',
                      //     style: TextStyle(color: blue, fontSize: 16),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
