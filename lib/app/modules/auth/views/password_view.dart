import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class PasswordView extends StatelessWidget {
  const PasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find();
    final TextEditingController passwordController = TextEditingController();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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
                color: theme.colorScheme.surface,
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
                        'Enter Password',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(
                            Icons.lock,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => controller.isLoading.value
                            ? CircularProgressIndicator(
                                color: theme.colorScheme.primary,
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (passwordController.text.isEmpty) {
                                      Get.snackbar(
                                        'Error',
                                        'Please enter your password',
                                        backgroundColor:
                                            theme.colorScheme.error,
                                        colorText: theme.colorScheme.onError,
                                      );
                                      return;
                                    }

                                    final result = await controller
                                        .validateUserLogin(
                                          passwordController.text,
                                        );

                                    if (result['success']) {
                                      controller.password.value =
                                          passwordController.text;

                                      // Check if password reset is needed
                                      if (result['isNeedToResetPwd']) {
                                        Get.toNamed(AppRoutes.newPassword);
                                      } else {
                                        // await GetStorage().write('isLoggedIn', true);
                                        // Get.offAllNamed(AppRoutes.home);
                                        //TODO ADD BIO
                                        Get.toNamed(AppRoutes.biometricLink);

                                      }
                                    } else {
                                      Get.snackbar(
                                        'Error',
                                        result['message'] ?? 'Invalid password',
                                        backgroundColor:
                                            theme.colorScheme.error,
                                        colorText: theme.colorScheme.onError,
                                      );
                                    }
                                  },
                                  child: const Text('Continue'),
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
