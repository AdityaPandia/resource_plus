import 'package:get/get.dart';
import 'package:dio/dio.dart';

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

  Future<bool> sendVerificationCode(String value) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> validateVerificationCode(String code) async {
    await Future.delayed(const Duration(seconds: 1));
    return code == '123456';
  }

  Future<bool> validatePassword(String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return password.length >= 6;
  }

  Future<bool> changePassword(String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));
    return newPassword.length >= 6;
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