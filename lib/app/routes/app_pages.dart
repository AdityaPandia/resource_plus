import 'package:get/get.dart';
import '../modules/auth/views/instance_scan_view.dart';
import '../modules/auth/views/email_verification_view.dart';
import '../modules/auth/views/code_verification_view.dart';
import '../modules/auth/views/password_view.dart';
import '../modules/auth/views/new_password_view.dart';
import '../modules/auth/views/biometric_link_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/views/dynamic_url_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/bindings/home_binding.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.instanceScan;
  
  static const initialLogin = AppRoutes.instanceScan;
  static const initialHome = AppRoutes.home;

  
  static final routes = [
    GetPage(name: AppRoutes.instanceScan, page: () => const InstanceScanView()),
    GetPage(name: AppRoutes.emailVerification, page: () => const EmailVerificationView()),
    GetPage(name: AppRoutes.codeVerification, page: () => const CodeVerificationView()),
    GetPage(name: AppRoutes.password, page: () => const PasswordView()),
    GetPage(name: AppRoutes.newPassword, page: () => const NewPasswordView()),
    GetPage(name: AppRoutes.biometricLink, page: () => const BiometricLinkView()),
    GetPage(name: AppRoutes.login, page: () => const LoginView()),
    GetPage(name: AppRoutes.forgotPassword, page: () => const ForgotPasswordView()),
    GetPage(name: AppRoutes.dynamicUrl, page: () => const DynamicUrlView()),
    GetPage(
      name: AppRoutes.home, 
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
  ];
} 