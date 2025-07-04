import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

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
                        'Login',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: blue,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: usernameController,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Username or Email',
                          prefixIcon: const Icon(Icons.person, color: green),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock, color: green),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Get.toNamed(AppRoutes.forgotPassword);
                            },
                            child: const Text('Forgot Password?'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.fingerprint, size: 32, color: green),
                            onPressed: () async {
                              controller.isLoading.value = true;
                              final linked = await controller.linkBiometric();
                              controller.isLoading.value = false;
                              if (linked) {
                                final url = await controller.getDynamicUrl();
                                Get.toNamed(AppRoutes.dynamicUrl, arguments: url);
                              } else {
                                Get.snackbar('Error', 'Biometric login failed', backgroundColor: Colors.redAccent, colorText: Colors.white);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                                  controller.isLoading.value = true;
                                  final valid = await controller.validatePassword(passwordController.text);
                                  controller.isLoading.value = false;
                                  if (valid) {
                                    final url = await controller.getDynamicUrl();
                                    Get.toNamed(AppRoutes.dynamicUrl, arguments: url);
                                  } else {
                                    Get.snackbar('Error', 'Invalid credentials', backgroundColor: Colors.redAccent, colorText: Colors.white);
                                  }
                                },
                                child: const Text('Login'),
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