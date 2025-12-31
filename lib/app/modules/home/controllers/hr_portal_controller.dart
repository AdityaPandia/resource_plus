import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, File;
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../../services/api_service.dart';
import '../../../controllers/language_controller.dart';

class HrPortalController extends GetxController {
  // Camera
  CameraController? cameraController;
  final isCameraInitialized = false.obs;
  final isCameraPermissionGranted = false.obs;

  // Time
  final currentTime = ''.obs;
  Timer? _timeTimer;

  // Location
  final currentCoordinates = 'Loading...'.obs;
  final isLocationPermissionGranted = false.obs;
  Position? _currentPosition;
  Timer? _locationTimer;

  // Attendance
  final isProcessingAttendance = false.obs;
  final isProcessingIn = false.obs;
  final isProcessingOut = false.obs;
  final lastPunches = <PunchRecord>[].obs;
  final currentShift =
      'Shift error'.obs; // Default shift, will be fetched from API
  final isLoadingPunches = false.obs;
  final hasPunchesError = false.obs;

  final Dio _dio = ApiService().dio;
  final GetStorage _storage = GetStorage();

  // Prevent multiple simultaneous image captures
  bool _isCapturingImage = false;

  // Get or create device ID
  String _getDeviceId() {
    String? deviceId = _storage.read('deviceId');
    if (deviceId == null || deviceId.isEmpty) {
      // Generate a device ID based on platform and timestamp
      deviceId =
          '${Platform.operatingSystem}_${DateTime.now().millisecondsSinceEpoch}';
      _storage.write('deviceId', deviceId);
    }
    return deviceId;
  }

  // Get device name
  String _getDeviceName() {
    return Platform.operatingSystem;
  }

  // Capture image from camera and convert to base64
  Future<String?> _captureImageAsBase64() async {
    // Prevent multiple simultaneous captures
    if (_isCapturingImage) {
      debugPrint('Image capture already in progress');
      return null;
    }

    try {
      _isCapturingImage = true;

      if (cameraController == null || !cameraController!.value.isInitialized) {
        debugPrint('Camera not initialized for image capture');
        return null;
      }

      // Wait longer to ensure camera buffers are ready
      // This gives time for any previous operations to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Check again after delay
      if (!cameraController!.value.isInitialized) {
        debugPrint('Camera not initialized after delay');
        return null;
      }

      // Take picture with error handling
      XFile image;
      try {
        image = await cameraController!.takePicture();
      } catch (e) {
        debugPrint('Error taking picture: $e');

        // If buffer error, wait much longer and retry once
        if (e.toString().contains('buffer') ||
            e.toString().contains('ImageReader') ||
            e.toString().contains('maxImages') ||
            e.toString().contains('Unable to acquire')) {
          debugPrint('Buffer error detected, waiting longer before retry...');
          // Wait significantly longer to allow buffers to be freed
          await Future.delayed(const Duration(milliseconds: 2000));

          // Check if camera is still initialized
          if (!cameraController!.value.isInitialized) {
            debugPrint('Camera not initialized before retry');
            return null;
          }

          try {
            image = await cameraController!.takePicture();
          } catch (retryError) {
            debugPrint('Retry also failed: $retryError');
            return null;
          }
        } else {
          return null;
        }
      }

      // Read image bytes
      final imageBytes = await image.readAsBytes();

      // Base64 encode
      final base64Image = base64Encode(imageBytes);

      // Delete temporary image file immediately to free resources
      try {
        final file = File(image.path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error deleting temporary image: $e');
      }

      return base64Image;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    } finally {
      _isCapturingImage = false;
    }
  }

  // Build device info string: "deviceId|deviceName|UTC-PunchTime|LocalPunchTime|TimeZone"
  String _buildDeviceInfo() {
    final now = DateTime.now();
    final utcTime = now.toUtc();
    final localTime = now;

    // Format: "dd/MM/yyyy HH:mm:ss"
    final utcTimeStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(utcTime);
    final localTimeStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(localTime);

    // Get timezone offset
    final timeZoneOffset = now.timeZoneOffset;
    final hours = timeZoneOffset.inHours;
    final minutes = timeZoneOffset.inMinutes.remainder(60);
    final timeZoneStr =
        '${hours >= 0 ? '+' : ''}${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    return '${_getDeviceId()}|${_getDeviceName()}|$utcTimeStr|$localTimeStr|$timeZoneStr';
  }

  // Build location info string: "Latitude|Longitude| Address : Lat/Lng,"
  String _buildLocationInfo() {
    if (_currentPosition == null) {
      return '0.000000|0.000000| Address : 0/0,';
    }

    final lat = _currentPosition!.latitude.toStringAsFixed(6);
    final lng = _currentPosition!.longitude.toStringAsFixed(6);

    return '$lat|$lng| Address : $lat/$lng,';
  }

  @override
  void onInit() {
    super.onInit();
    _initializeCamera();
    _startTimeUpdates();
    _initializeLocation();
    fetchLastFivePunches();
    fetchShiftDetails();
  }

  @override
  void onClose() {
    _timeTimer?.cancel();
    _locationTimer?.cancel();
    cameraController?.dispose();
    super.onClose();
  }

  // Initialize Camera
  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      isCameraPermissionGranted.value = cameraStatus.isGranted;

      if (!isCameraPermissionGranted.value) {
        Get.snackbar(
          'Camera Permission',
          'Camera permission is required for HR Portal',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        Get.snackbar(
          'Camera Error',
          'No cameras available on this device',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Use front camera if available, otherwise use first camera
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // Initialize camera controller with low resolution
      // Using low to reduce buffer usage and prevent crashes
      // Low resolution is sufficient for attendance photos
      cameraController = CameraController(
        camera,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup:
            ImageFormatGroup.jpeg, // Use JPEG to reduce buffer size
      );

      await cameraController!.initialize();

      // Double-check initialization before setting flag
      if (cameraController != null && cameraController!.value.isInitialized) {
        isCameraInitialized.value = true;
      } else {
        debugPrint(
          'Camera initialization completed but not properly initialized',
        );
        isCameraInitialized.value = false;
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      isCameraInitialized.value = false;

      // Dispose controller on error to prevent further issues
      try {
        await cameraController?.dispose();
        cameraController = null;
      } catch (disposeError) {
        debugPrint('Error disposing camera controller: $disposeError');
      }

      Get.snackbar(
        'Camera Error',
        'Failed to initialize camera: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Start time updates
  void _startTimeUpdates() {
    _updateTime();
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    currentTime.value = DateFormat('HH:mm:ss').format(now);
  }

  // Initialize Location
  Future<void> _initializeLocation() async {
    try {
      // Request location permission
      final locationStatus = await Permission.location.request();
      isLocationPermissionGranted.value = locationStatus.isGranted;

      if (!isLocationPermissionGranted.value) {
        currentCoordinates.value = 'Permission denied';
        return;
      }

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        currentCoordinates.value = 'Location services disabled';
        return;
      }

      // Get current position
      await _updateLocation();

      // Update location every 30 seconds
      _locationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        _updateLocation();
      });
    } catch (e) {
      debugPrint('Error initializing location: $e');
      currentCoordinates.value = 'Error getting location';
    }
  }

  Future<void> _updateLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      currentCoordinates.value =
          '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}';
    } catch (e) {
      debugPrint('Error updating location: $e');
      currentCoordinates.value = 'Unable to get location';
    }
  }

  // Fetch last 5 punches from API
  Future<void> fetchLastFivePunches() async {
    try {
      isLoadingPunches.value = true;
      hasPunchesError.value = false;

      final instanceName = GetStorage().read('instanceName');
      final userEmail = GetStorage().read('email');

      if (instanceName == null || instanceName.toString().isEmpty) {
        debugPrint('Instance name not found');
        hasPunchesError.value = true;
        isLoadingPunches.value = false;
        return;
      }

      if (userEmail == null || userEmail.toString().isEmpty) {
        debugPrint('User email not found');
        hasPunchesError.value = true;
        isLoadingPunches.value = false;
        return;
      }

      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Client/GetLastFivePunches',
        queryParameters: {
          'instanceName': instanceName,
          'usrEmail': userEmail,
          'L': 1,
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> punchesData = response.data;
        final List<PunchRecord> punches = [];

        for (var punchData in punchesData) {
          try {
            final punchTimeDevice =
                punchData['punchtime_device']?.toString() ?? '';
            final punchType = punchData['punch_type']?.toString() ?? '';

            if (punchTimeDevice.isNotEmpty) {
              // Parse the date/time from format: "01/12/2025 01:44:46 PM"
              DateTime? parsedDate;
              String dateStr = '';
              String timeStr = '';

              try {
                // Try parsing with the API format: "dd/MM/yyyy hh:mm:ss a"
                parsedDate = DateFormat(
                  'dd/MM/yyyy hh:mm:ss a',
                ).parse(punchTimeDevice);

                // Format date as "dd MMM yyyy"
                dateStr = DateFormat('dd MMM yyyy').format(parsedDate);

                // Format time as "HH:mm:ss"
                timeStr = DateFormat('HH:mm:ss').format(parsedDate);
              } catch (e) {
                debugPrint('Error parsing date: $e');
                // Fallback: use current date/time if parsing fails
                final now = DateTime.now();
                dateStr = DateFormat('dd MMM yyyy').format(now);
                timeStr = DateFormat('HH:mm:ss').format(now);
              }

              // Map punch_type to type (IN -> In, OUT -> Out)
              String type = punchType.toUpperCase() == 'IN' ? 'In' : 'Out';

              // Determine status based on isrejected
              final isRejected =
                  punchData['isrejected']?.toString().toUpperCase() ?? 'NO';
              final status = isRejected == 'YES' ? 'Rejected' : 'Success';

              punches.add(
                PunchRecord(
                  type: type,
                  time: timeStr,
                  date: dateStr,
                  status: status,
                ),
              );
            }
          } catch (e) {
            debugPrint('Error parsing punch record: $e');
            continue;
          }
        }

        lastPunches.value = punches;
      } else {
        hasPunchesError.value = true;
        debugPrint('Unexpected response format from API');
      }
    } catch (e) {
      debugPrint('Error fetching last 5 punches: $e');
      hasPunchesError.value = true;
      Get.snackbar(
        'Error',
        'Failed to load punches: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    } finally {
      isLoadingPunches.value = false;
    }
  }

  // Fetch shift details from API
  Future<void> fetchShiftDetails() async {
    try {
      final instanceName = GetStorage().read('instanceName');
      final userEmail = GetStorage().read('email');

      if (instanceName == null || instanceName.toString().isEmpty) {
        debugPrint('Instance name not found for shift details');
        currentShift.value = 'Shift error';
        return;
      }

      if (userEmail == null || userEmail.toString().isEmpty) {
        debugPrint('User email not found for shift details');
        currentShift.value = 'Shift error';
        return;
      }

      final languageController = Get.find<LanguageController>();

      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Client/GetShiftDetails',
        queryParameters: {
          'instanceName': instanceName,
          'usrEmail': userEmail,
          'Lang': languageController.currentLangCode,
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> shiftData = response.data;

        if (shiftData.isNotEmpty) {
          final shiftInfo = shiftData[0];
          final shiftName = shiftInfo['ShiftName']?.toString();

          if (shiftName != null && shiftName.isNotEmpty) {
            currentShift.value = shiftName;
          } else {
            debugPrint('ShiftName not found in API response');
            currentShift.value = 'Shift error';
          }
        } else {
          debugPrint('Shift details response is empty');
          currentShift.value = 'Shift error';
        }
      } else {
        debugPrint('Unexpected response format from shift details API');
        currentShift.value = 'Shift error';
      }
    } catch (e) {
      debugPrint('Error fetching shift details: $e');
      currentShift.value = 'Shift error';
    }
  }

  // Mark attendance - In
  Future<void> markAttendanceIn() async {
    await _markAttendance(checkType: 0);
  }

  // Mark attendance - Out
  Future<void> markAttendanceOut() async {
    await _markAttendance(checkType: 1);
  }

  // Mark attendance API call
  Future<void> _markAttendance({required int checkType}) async {
    // Use separate loading flags for In and Out
    final isProcessingFlag = checkType == 0 ? isProcessingIn : isProcessingOut;

    if (isProcessingFlag.value || isProcessingAttendance.value) return;

    try {
      isProcessingAttendance.value = true;
      isProcessingFlag.value = true;

      // Get user email
      final userEmail = GetStorage().read('email');
      if (userEmail == null || userEmail.toString().isEmpty) {
        Get.snackbar(
          'Error',
          'User email not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.errorContainer,
          colorText: Get.theme.colorScheme.onErrorContainer,
        );
        isProcessingAttendance.value = false;
        isProcessingFlag.value = false;
        return;
      }

      // Ensure location is updated
      if (_currentPosition == null) {
        await _updateLocation();
      }

      // Capture image from camera
      final punchImage = await _captureImageAsBase64();
      if (punchImage == null) {
        Get.snackbar(
          'Error',
          'Failed to capture image',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.errorContainer,
          colorText: Get.theme.colorScheme.onErrorContainer,
        );
        isProcessingAttendance.value = false;
        isProcessingFlag.value = false;
        return;
      }

      // Build request body
      final requestBody = {
        'username': userEmail.toString(),
        'checktype': checkType,
        'deviceinfo': _buildDeviceInfo(),
        'locationinfo': _buildLocationInfo(),
        'punchimage': punchImage,
      };

      debugPrint(
        'Mark Attendance Request: ${jsonEncode({'username': requestBody['username'], 'checktype': requestBody['checktype'], 'deviceinfo': requestBody['deviceinfo'], 'locationinfo': requestBody['locationinfo'], 'punchimage': '${punchImage.substring(0, 50)}... (truncated)'})}',
      );

      // Make API call
      final response = await _dio.post(
        'https://auto.resourceplus.app/Mobile/api/Client/MarkAttendance',
        data: requestBody,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      debugPrint('Mark Attendance Response Status: ${response.statusCode}');
      debugPrint('Mark Attendance Response: ${response.data}');

      if (response.statusCode == 200) {
        // Check if response indicates success
        // Response format may vary, adjust based on actual API response
        final responseData = response.data;
        bool isSuccess = false;
        String? message;

        if (responseData is Map) {
          // Check common success indicators
          if (responseData.containsKey('success') &&
              responseData['success'] == true) {
            isSuccess = true;
            message = responseData['message']?.toString();
          } else if (responseData.containsKey('IsValid') &&
              (responseData['IsValid'] == true ||
                  responseData['IsValid']?.toString().toLowerCase() ==
                      'true')) {
            isSuccess = true;
            message =
                responseData['Message']?.toString() ??
                responseData['message']?.toString();
          } else if (responseData.containsKey('status') &&
              responseData['status']?.toString().toLowerCase() == 'success') {
            isSuccess = true;
            message = responseData['message']?.toString();
          }
        } else if (responseData is List && responseData.isNotEmpty) {
          final firstItem = responseData[0];
          if (firstItem is Map) {
            if (firstItem.containsKey('IsValid') &&
                (firstItem['IsValid'] == true ||
                    firstItem['IsValid']?.toString().toLowerCase() == 'true')) {
              isSuccess = true;
              message =
                  firstItem['Message']?.toString() ??
                  firstItem['message']?.toString();
            }
          }
        }

        // If no clear success indicator found, assume success for 200 status
        if (!isSuccess && response.statusCode == 200) {
          isSuccess = true;
          message = 'Attendance marked successfully';
        }

        if (isSuccess) {
          Get.snackbar(
            'Success',
            message ??
                (checkType == 0
                    ? 'Attendance marked as In'
                    : 'Attendance marked as Out'),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );

          // Refresh punches list
          await fetchLastFivePunches();
        } else {
          Get.snackbar(
            'Error',
            message ?? 'Failed to mark attendance',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.errorContainer,
            colorText: Get.theme.colorScheme.onErrorContainer,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to mark attendance. Status: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.errorContainer,
          colorText: Get.theme.colorScheme.onErrorContainer,
        );
      }
    } catch (e) {
      debugPrint('Error marking attendance: $e');
      String errorMessage = 'Failed to mark attendance';

      if (e is DioException) {
        if (e.response != null) {
          errorMessage =
              e.response?.data?['message']?.toString() ??
              e.response?.data?['Message']?.toString() ??
              'Server error: ${e.response?.statusCode}';
        } else {
          errorMessage = 'Network error: ${e.message}';
        }
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isProcessingAttendance.value = false;
      isProcessingFlag.value = false;
    }
  }
}

// Punch Record Model
class PunchRecord {
  final String type;
  final String time;
  final String date;
  final String status;

  PunchRecord({
    required this.type,
    required this.time,
    required this.date,
    required this.status,
  });
}
