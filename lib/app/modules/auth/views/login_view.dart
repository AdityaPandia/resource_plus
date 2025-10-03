import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _biometricAvailable = false;
  bool _isCheckingBiometric = true;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh biometric availability when returning to this screen
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final controller = Get.find<AuthController>();
    try {
      final isAvailable = await controller.isBiometricAvailable();
      final biometricSetup = controller.isBiometricSetupComplete();

      if (mounted) {
        setState(() {
          _biometricAvailable = isAvailable && biometricSetup;
          _isCheckingBiometric = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _biometricAvailable = false;
          _isCheckingBiometric = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final theme = Theme.of(context);
    const blue = Color(0xFF3B6EA5);
    const green = Color(0xFF6BC04B);
    const orange = Color(0xFFF7941D);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
                color: Theme.of(context).colorScheme.surface,
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
                        'Login',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: usernameController,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Username or Email',
                          prefixIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock, color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Get.toNamed(AppRoutes.forgotPassword);
                              Get.toNamed(AppRoutes.newPassword);
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                          // Show biometric button only if available and set up
                          if (!_isCheckingBiometric && _biometricAvailable)
                            IconButton(
                              icon: Icon(
                                Icons.fingerprint,
                                size: 32,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: () async {
                                final result = await controller
                                    .biometricLogin();

                                if (result['success']) {
                                  if (result['isNeedToResetPwd']) {
                                    // Route to new password screen
                                    Get.offAllNamed(AppRoutes.newPassword);
                                  } else {
                                    // Route to home screen
                                    Get.offAllNamed(AppRoutes.home);
                                  }
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    result['message'],
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                            )
                          else
                            const SizedBox.shrink(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => controller.isLoading.value
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (usernameController.text.isEmpty ||
                                        passwordController.text.isEmpty) {
                                      Get.snackbar(
                                        'Error',
                                        'Please enter both username/email and password',
                                        backgroundColor: Colors.redAccent,
                                        colorText: Colors.white,
                                      );
                                      return;
                                    }

                                    final result = await controller
                                        .loginWithStoredInstance(
                                          usernameController.text,
                                          passwordController.text,
                                        );

                                    if (result['success']) {
                                      if (result['isNeedToResetPwd']) {
                                        // Route to new password screen
                                        Get.offAllNamed(AppRoutes.newPassword);
                                      } else {
                                        // Route to home screen
                                        await GetStorage().write(
                                          'isLoggedIn',
                                          true,
                                        );
                                        Get.offAllNamed(AppRoutes.home);
                                      }
                                    } else {
                                      Get.snackbar(
                                        'Error',
                                        result['message'],
                                        backgroundColor: Colors.redAccent,
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                                  child: const Text('Login'),
                                ),
                              ),
                      ),
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
