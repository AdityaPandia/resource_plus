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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Enter Password',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: blue,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock, color: green),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Obx(() => controller.isLoading.value
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () async {
                                  if (passwordController.text.isEmpty) {
                                    Get.snackbar(
                                      'Error', 
                                      'Please enter your password', 
                                      backgroundColor: Colors.redAccent, 
                                      colorText: Colors.white
                                    );
                                    return;
                                  }
                                  
                                  final result = await controller.validateUserLogin(passwordController.text);
                                  
                                  if (result['success']) {
                                    controller.password.value = passwordController.text;
                                    
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
                                      backgroundColor: Colors.redAccent, 
                                      colorText: Colors.white
                                    );
                                  }
                                },
                                child: const Text('Continue'),
                              ),
                            )),
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
