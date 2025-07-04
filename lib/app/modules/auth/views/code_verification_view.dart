import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class CodeVerificationView extends StatelessWidget {
  const CodeVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find();
    final TextEditingController codeController = TextEditingController();
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
                        'Enter Verification Code',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: blue,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: codeController,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Verification Code',
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
                                   Get.toNamed(AppRoutes.password);
                                  // controller.isLoading.value = true;
                                  // final valid = await controller.validateVerificationCode(codeController.text);
                                  // controller.isLoading.value = false;
                                  // if (valid) {
                                  //   controller.verificationCode.value = codeController.text;
                                  //   Get.toNamed(AppRoutes.password);
                                  // } else {
                                  //   Get.snackbar('Error', 'Invalid verification code', backgroundColor: Colors.redAccent, colorText: Colors.white);
                                  // }
                                },
                                child: const Text('Verify'),
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
