import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../../../controllers/language_controller.dart';

class AuthController extends GetxController {
  // State variables
  var instanceName = ''.obs;
  var emailOrPhone = ''.obs;
  var verificationCode = ''.obs;
  var password = ''.obs;
  var newPassword = ''.obs;
  var confirmPassword = ''.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final Dio _dio = Dio();

  // API: Validate Instance
  Future<bool> validateInstance(String instance) async {
    isLoading.value = true;
    errorMessage.value = '';
    // Convert to lowercase for case-insensitive handling
    // final normalizedInstance = instance.toLowerCase().trim();
    await GetStorage().write('instanceName', instance);

    final languageController = Get.find<LanguageController>();

    try {
      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Master/checkInstance',
        queryParameters: {
          'instanceName': instance,
          'Lang': languageController.currentLangCode,
        },
        options: Options(responseType: ResponseType.json),
      );
      if (response.statusCode == 200 &&
          response.data is List &&
          response.data.isNotEmpty) {
        final data = response.data[0];
        final isValid = data['IsValid'].toString().toLowerCase() == 'true';
        if (isValid) {
          isLoading.value = false;
          return true;
        } else {
          errorMessage.value = data['RsltMessage'] ?? 'Invalid instance';
        }
      } else {
        errorMessage.value = 'Unexpected response from server.';
      }
    } catch (e) {
      errorMessage.value = 'Network error. Please try again.';
      print(e);
    }
    isLoading.value = false;
    return false;
  }

  Future<bool> validateEmailOrPhone(String value) async {
    await Future.delayed(const Duration(seconds: 1));
    return value.contains('@') || value.length == 10;
  }

  // API: Check Email
  Future<bool> sendVerificationCode(String email) async {
    await GetStorage().write('email', email);
    isLoading.value = true;
    errorMessage.value = '';

    final languageController = Get.find<LanguageController>();
    // Get the current instance name from storage to ensure it's up to date
    final currentInstanceName =
        await GetStorage().read('instanceName') ?? instanceName.value;

    try {
      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Client/CheckEmail',
        queryParameters: {
          'instanceName': currentInstanceName,
          'usrEmail': email,
          'Lang': languageController.currentLangCode,
        },
        options: Options(responseType: ResponseType.json),
      );
      if (response.statusCode == 200 &&
          response.data is List &&
          response.data.isNotEmpty) {
        final data = response.data[0];
        final isValid = data['IsValid'].toString().toLowerCase() == 'true';
        if (isValid) {
          isLoading.value = false;
          return true;
        } else {
          errorMessage.value = data['RsltMessage'] ?? 'Invalid email address';
        }
      } else {
        errorMessage.value = 'Unexpected response from server.';
      }
    } catch (e) {
      errorMessage.value = 'Network error. Please try again.';
    }
    isLoading.value = false;
    return false;
  }

  // API: Verify OTP
  Future<bool> validateVerificationCode(String otp) async {
    isLoading.value = true;
    errorMessage.value = '';

    final languageController = Get.find<LanguageController>();

    try {
      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Client/VerifyOtp',
        queryParameters: {
          'instanceName': instanceName.value,
          'usrEmail': emailOrPhone.value,
          'loginOTP': otp,
          'Lang': languageController.currentLangCode,
        },
        options: Options(responseType: ResponseType.json),
      );
      if (response.statusCode == 200 &&
          response.data is List &&
          response.data.isNotEmpty) {
        final data = response.data[0];
        final isValid = data['IsValid'].toString().toLowerCase() == 'true';
        if (isValid) {
          isLoading.value = false;
          return true;
        } else {
          errorMessage.value = data['RsltMessage'] ?? 'Invalid OTP';
        }
      } else {
        errorMessage.value = 'Unexpected response from server.';
      }
    } catch (e) {
      errorMessage.value = 'Network error. Please try again.';
    }
    isLoading.value = false;
    return false;
  }

  // API: Validate User Login
  Future<Map<String, dynamic>> validateUserLogin(String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    final languageController = Get.find<LanguageController>();

    try {
      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Client/ValidateUser',
        queryParameters: {
          'instanceName': instanceName.value,
          'usrEmail': emailOrPhone.value,
          'UsrPassword': password,
          'Lang': languageController.currentLangCode,
        },
        options: Options(responseType: ResponseType.json),
      );
      if (response.statusCode == 200 &&
          response.data is List &&
          response.data.isNotEmpty) {
        final data = response.data[0];
        final isValid = data['IsValid'].toString().toLowerCase() == 'true';
        if (isValid) {
          // Store user data for biometric login
          await GetStorage().write('webLink', data['ClientUrl'] ?? '');
          await GetStorage().write(
            'empDisplayName',
            data['EmpDisplayName'] ?? '',
          );
          await GetStorage().write('username', data['Username'] ?? '');
          await GetStorage().write('email', data['Email'] ?? '');
          await GetStorage().write(
            'password',
            password,
          ); // Store password for biometric login
      
          await GetStorage().write('instanceName', instanceName.value);
      // Enable biometric login

          isLoading.value = false;
          return {
            'success': true,
            'isNeedToResetPwd': data['IsNeedToResetPwd'] ?? false,
            'empDisplayName': data['EmpDisplayName'] ?? '',
            'username': data['Username'] ?? '',
            'email': data['Email'] ?? '',
            'clientUrl': data['ClientUrl'] ?? '',
            'message': data['RsltMessage'] ?? 'Authentication successful',
          };
        } else {
          errorMessage.value = data['RsltMessage'] ?? 'Invalid credentials';
          isLoading.value = false;
          return {
            'success': false,
            'message': data['RsltMessage'] ?? 'Invalid credentials',
          };
        }
      } else {
        errorMessage.value = 'Unexpected response from server.';
        isLoading.value = false;
        return {
          'success': false,
          'message': 'Unexpected response from server.',
        };
      }
    } catch (e) {
      errorMessage.value = 'Network error. Please try again.';
      isLoading.value = false;
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  // API: Change Password
  Future<Map<String, dynamic>> changeUserPassword(String newPassword) async {
    isLoading.value = true;
    errorMessage.value = '';

    final languageController = Get.find<LanguageController>();

    try {
      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Client/ChangePwd',
        queryParameters: {
          'instanceName': instanceName.value,
          'usrEmail': emailOrPhone.value,
          'UsrPassword': newPassword,
          'Lang': languageController.currentLangCode,
        },
        options: Options(responseType: ResponseType.json),
      );
      if (response.statusCode == 200 &&
          response.data is List &&
          response.data.isNotEmpty) {
        final data = response.data[0];
        final isValid = data['IsValid'] == true;
        if (isValid) {
          isLoading.value = false;
          return {
            'success': true,
            'message': data['RsltMessage'] ?? 'Password changed successfully',
          };
        } else {
          errorMessage.value = data['RsltMessage'] ?? 'Password change failed';
          isLoading.value = false;
          return {
            'success': false,
            'message': data['RsltMessage'] ?? 'Password change failed',
          };
        }
      } else {
        errorMessage.value = 'Unexpected response from server.';
        isLoading.value = false;
        return {
          'success': false,
          'message': 'Unexpected response from server.',
        };
      }
    } catch (e) {
      errorMessage.value = 'Network error. Please try again.';
      isLoading.value = false;
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  Future<bool> validatePassword(String password) async {
    final result = await validateUserLogin(password);
    if (result['success']) {
      this.password.value = password;
      return true;
    }
    return false;
  }

  Future<bool> changePassword(String newPassword) async {
    final result = await changeUserPassword(newPassword);
    if (result['success']) {
      this.newPassword.value = newPassword;
      return true;
    }
    return false;
  }

  Future<bool> linkBiometric() async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // Check if biometric setup is complete
  bool isBiometricSetupComplete() {
    return GetStorage().read('biometricSetupComplete') ?? false;
  }

  // Check if biometric login is enabled
  bool isBiometricEnabled() {
    return GetStorage().read('biometricEnabled') ?? false;
  }

  // Biometric Authentication
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Getter to access LocalAuthentication for debugging
  LocalAuthentication get localAuth => _localAuth;

  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      print('Debug: canCheckBiometrics: $isAvailable');
      print('Debug: isDeviceSupported: $isDeviceSupported');
      print('Debug: availableBiometrics: $availableBiometrics');

      return isAvailable && isDeviceSupported && availableBiometrics.isNotEmpty;
    } catch (e) {
      print('Debug: Biometric availability error: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      print('Debug: Starting biometric authentication...');

      final isAvailable = await isBiometricAvailable();
      print('Debug: Biometric available: $isAvailable');
      if (!isAvailable) {
        print('Debug: Biometric not available, aborting');
        return false;
      }

      final availableBiometrics = await getAvailableBiometrics();
      print('Debug: Available biometrics: $availableBiometrics');
      if (availableBiometrics.isEmpty) {
        print('Debug: No biometrics enrolled, aborting');
        return false;
      }

      print('Debug: Calling _localAuth.authenticate...');

      // Try different authentication options
      AuthenticationOptions authOptions;
      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        print('Debug: Using fingerprint authentication');
        authOptions = const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          sensitiveTransaction: false,
        );
      } else {
        print('Debug: Using general biometric authentication');
        authOptions = const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          sensitiveTransaction: false,
        );
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to set up biometric login',
        options: authOptions,
      );

      print('Debug: Authentication result: $authenticated');
      return authenticated;
    } catch (e) {
      print('Debug: Biometric authentication error: $e');
      print('Debug: Error type: ${e.runtimeType}');
      print('Debug: Error details: ${e.toString()}');

      // Handle specific platform exceptions
      if (e.toString().contains('no_fragment_activity')) {
        print(
            'Debug: FragmentActivity error - MainActivity needs to extend FlutterFragmentActivity');
      } else if (e.toString().contains('NotAvailable')) {
        print('Debug: Biometric hardware not available');
      } else if (e.toString().contains('NotEnrolled')) {
        print('Debug: No biometrics enrolled on device');
      } else if (e.toString().contains('UserCancel')) {
        print('Debug: User cancelled biometric authentication');
      }

      return false;
    }
  }

  Future<Map<String, dynamic>> biometricLogin() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Check if biometric authentication is available
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        isLoading.value = false;
        return {
          'success': false,
          'message':
              'Biometric authentication is not available on this device.',
        };
      }

      // Authenticate with biometrics
      final authenticated = await authenticateWithBiometrics();
      if (!authenticated) {
        isLoading.value = false;
        return {
          'success': false,
          'message': 'Biometric authentication failed.',
        };
      }

      // Get stored credentials for biometric login
      final storedEmail = GetStorage().read('email');
      final storedPassword = GetStorage().read('password');

      if (storedEmail == null || storedPassword == null) {
        isLoading.value = false;
        return {
          'success': false,
          'message':
              'No stored credentials found. Please login with username and password first.',
        };
      }

      // Perform login with stored credentials
      final loginResult = await loginWithStoredInstance(
        storedEmail,
        storedPassword,
      );

      return loginResult;
    } catch (e) {
      isLoading.value = false;
      return {
        'success': false,
        'message': 'Biometric login failed. Please try again.',
      };
    }
  }

  Future<String> getDynamicUrl() async {
    await Future.delayed(const Duration(seconds: 1));
    return 'https://example.com';
  }

  // Logout method
  Future<void> logout() async {
    // Clear all stored data except instance name
    await GetStorage().write('isLoggedIn', false);
    await GetStorage().write('email', '');
    await GetStorage().write('password', '');
    await GetStorage().write('username', '');
    await GetStorage().write('empDisplayName', '');
    await GetStorage().write('webLink', '');
    await GetStorage().write('biometricEnabled', false);

    // Reset controller values
    emailOrPhone.value = '';
    password.value = '';
    newPassword.value = '';
    confirmPassword.value = '';
    verificationCode.value = '';
    errorMessage.value = '';
  }

  // API: Login with stored instance
  Future<Map<String, dynamic>> loginWithStoredInstance(
    String email,
    String password,
  ) async {
    isLoading.value = true;
    errorMessage.value = '';

    // Get instance name from storage
    final storedInstanceName = GetStorage().read('instanceName');
    if (storedInstanceName == null || storedInstanceName.toString().isEmpty) {
      isLoading.value = false;
      return {
        'success': false,
        'message': 'Instance not found. Please scan instance first.',
      };
    }

    final languageController = Get.find<LanguageController>();

    try {
      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Client/ValidateUser',
        queryParameters: {
          'instanceName': storedInstanceName,
          'usrEmail': email,
          'UsrPassword': password,
          'Lang': languageController.currentLangCode,
        },
        options: Options(responseType: ResponseType.json),
      );

      if (response.statusCode == 200 &&
          response.data is List &&
          response.data.isNotEmpty) {
        final data = response.data[0];
        final isValid = data['IsValid'].toString().toLowerCase() == 'true';

        if (isValid) {
          // Store user data
          await GetStorage().write('webLink', data['ClientUrl'] ?? '');
          await GetStorage().write(
            'empDisplayName',
            data['EmpDisplayName'] ?? '',
          );
          await GetStorage().write('username', data['Username'] ?? '');
          await GetStorage().write('email', data['Email'] ?? '');
          await GetStorage().write(
            'password',
            password,
          ); // Store password for biometric login

          isLoading.value = false;
          return {
            'success': true,
            'isNeedToResetPwd': data['IsNeedToResetPwd'] ?? false,
            'empDisplayName': data['EmpDisplayName'] ?? '',
            'username': data['Username'] ?? '',
            'email': data['Email'] ?? '',
            'clientUrl': data['ClientUrl'] ?? '',
            'message': data['RsltMessage'] ?? 'Authentication successful',
          };
        } else {
          errorMessage.value = data['RsltMessage'] ?? 'Invalid credentials';
          isLoading.value = false;
          return {
            'success': false,
            'message': data['RsltMessage'] ?? 'Invalid credentials',
          };
        }
      } else {
        errorMessage.value = 'Unexpected response from server.';
        isLoading.value = false;
        return {
          'success': false,
          'message': 'Unexpected response from server.',
        };
      }
    } catch (e) {
      errorMessage.value = 'Network error. Please try again.';
      isLoading.value = false;
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }
}
