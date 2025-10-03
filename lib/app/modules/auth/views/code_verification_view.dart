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
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'ve sent a 6-digit code to ${controller.emailOrPhone.value}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                          prefixIcon: Icon(Icons.lock, color: theme.colorScheme.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Obx(() => controller.isLoading.value
                          ? CircularProgressIndicator(color: theme.colorScheme.primary)
                          : SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () async {
                                  if (codeController.text.trim().isEmpty) {
                                    Get.snackbar(
                                      'Error', 
                                      'Please enter the verification code', 
                                      backgroundColor: theme.colorScheme.error, 
                                      colorText: theme.colorScheme.onError
                                    );
                                    return;
                                  }
                                  
                                  if (codeController.text.trim().length != 6) {
                                    Get.snackbar(
                                      'Error', 
                                      'Please enter a 6-digit verification code', 
                                      backgroundColor: theme.colorScheme.error, 
                                      colorText: theme.colorScheme.onError
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
                                      backgroundColor: theme.colorScheme.error, 
                                      colorText: theme.colorScheme.onError
                                    );
                                  }
                                },
                                child: const Text('Verify'),
                              ),
                            )),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Didn\'t receive the code? ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final success = await controller.sendVerificationCode(controller.emailOrPhone.value);
                              if (success) {
                                Get.snackbar(
                                  'Success', 
                                  'Verification code resent successfully', 
                                  backgroundColor: theme.colorScheme.primary, 
                                  colorText: theme.colorScheme.onPrimary
                                );
                              } else {
                                Get.snackbar(
                                  'Error', 
                                  controller.errorMessage.value.isNotEmpty 
                                    ? controller.errorMessage.value 
                                    : 'Failed to resend code', 
                                  backgroundColor: theme.colorScheme.error, 
                                  colorText: theme.colorScheme.onError
                                );
                              }
                            },
                            child: Text(
                              'Resend',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
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
            ],
          ),
        ),
      ),
    );
  }
}
