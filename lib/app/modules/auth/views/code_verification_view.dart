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
                      const SizedBox(height: 8),
                      Text(
                        'We\'ve sent a 6-digit code to ${controller.emailOrPhone.value}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: codeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'Verification Code',
                          hintText: 'Enter 6-digit code',
                          counterText: '',
                          prefixIcon: const Icon(Icons.lock, color: green),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: green, width: 2),
                          ),
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
                                  if (codeController.text.trim().isEmpty) {
                                    Get.snackbar(
                                      'Error', 
                                      'Please enter the verification code', 
                                      backgroundColor: Colors.redAccent, 
                                      colorText: Colors.white
                                    );
                                    return;
                                  }
                                  
                                  if (codeController.text.trim().length != 6) {
                                    Get.snackbar(
                                      'Error', 
                                      'Please enter a 6-digit verification code', 
                                      backgroundColor: Colors.redAccent, 
                                      colorText: Colors.white
                                    );
                                    return;
                                  }
                                  
                                  final success = await controller.validateVerificationCode(codeController.text.trim());
                                  if (success) {
                                    controller.verificationCode.value = codeController.text.trim();
                                    Get.toNamed(AppRoutes.password);
                                  } else {
                                    Get.snackbar(
                                      'Error', 
                                      controller.errorMessage.value.isNotEmpty 
                                        ? controller.errorMessage.value 
                                        : 'Invalid verification code', 
                                      backgroundColor: Colors.redAccent, 
                                      colorText: Colors.white
                                    );
                                  }
                                },
                                child: const Text('Verify'),
                              ),
                            )),
                    ],
                  ),
                                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Didn\'t receive the code? ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final success = await controller.sendVerificationCode(controller.emailOrPhone.value);
                              if (success) {
                                Get.snackbar(
                                  'Success', 
                                  'Verification code resent successfully', 
                                  backgroundColor: green, 
                                  colorText: Colors.white
                                );
                              } else {
                                Get.snackbar(
                                  'Error', 
                                  controller.errorMessage.value.isNotEmpty 
                                    ? controller.errorMessage.value 
                                    : 'Failed to resend code', 
                                  backgroundColor: Colors.redAccent, 
                                  colorText: Colors.white
                                );
                              }
                            },
                            child: Text(
                              'Resend',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
