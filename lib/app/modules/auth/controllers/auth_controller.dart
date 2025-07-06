import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

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
    await GetStorage().write('instanceName', instance);
    try {
      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Master/checkInstance',
        queryParameters: {
          'instanceName': instance,
          'Lang': 1,
        },
        options: Options(responseType: ResponseType.json),
      );
      if (response.statusCode == 200 && response.data is List && response.data.isNotEmpty) {
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
    try {
      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Client/CheckEmail',
        queryParameters: {
          'instanceName': instanceName.value,
          'usrEmail': email,
          'Lang': 1,
        },
        options: Options(responseType: ResponseType.json),
      );
      if (response.statusCode == 200 && response.data is List && response.data.isNotEmpty) {
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
    try {
      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Client/VerifyOtp',
        queryParameters: {
          'instanceName': instanceName.value,
          'usrEmail': emailOrPhone.value,
          'loginOTP': otp,
          'Lang': 1,
        },
        options: Options(responseType: ResponseType.json),
      );
      if (response.statusCode == 200 && response.data is List && response.data.isNotEmpty) {
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
    try {
      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Client/ValidateUser',
        queryParameters: {
          'instanceName': instanceName.value,
          'usrEmail': emailOrPhone.value,
          'UsrPassword': password,
          'Lang': 1,
        },
        options: Options(responseType: ResponseType.json),
      );
      if (response.statusCode == 200 && response.data is List && response.data.isNotEmpty) {
        final data = response.data[0];
        final isValid = data['IsValid'].toString().toLowerCase() == 'true';
        if (isValid) {
          await GetStorage().write('webLink', data['ClientUrl'] ?? '');
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
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

  // API: Change Password
  Future<Map<String, dynamic>> changeUserPassword(String newPassword) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Client/ChangePwd',
        queryParameters: {
          'instanceName': instanceName.value,
          'usrEmail': emailOrPhone.value,
          'UsrPassword': newPassword,
          'Lang': 1,
        },
        options: Options(responseType: ResponseType.json),
      );
      if (response.statusCode == 200 && response.data is List && response.data.isNotEmpty) {
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
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
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

  Future<String> getDynamicUrl() async {
    await Future.delayed(const Duration(seconds: 1));
    return 'https://example.com';
  }
} 