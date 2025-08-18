import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../calendar/controllers/calendar_controller.dart';
import '../../../controllers/language_controller.dart';
import '../../../services/notification_service.dart';

class HomeController extends GetxController {
  final Dio _dio = Dio();
  final NotificationService _notificationService = NotificationService();

  // Bottom navigation index
  final RxInt currentIndex = 0.obs;

  // Home data
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Employee details
  final RxString empNumber = ''.obs;
  final RxString employeeName = ''.obs;
  final RxString positionName = ''.obs;

  // Dashboard data
  final RxList dashboardData = <Map<String, dynamic>>[].obs;

  // Static contents
  final RxMap<String, String> staticContents = <String, String>{}.obs;

  // Attendance data
  final RxBool isAttendanceLoading = false.obs;
  final RxBool hasAttendanceError = false.obs;
  final RxString attendanceErrorMessage = ''.obs;

  // Attendance Rate
  final RxList attendanceRate = <Map<String, dynamic>>[].obs;

  // Attendance Counts
  final RxList attendanceCounts = <Map<String, dynamic>>[].obs;

  // Recent Activities
  final RxList recentActivities = <Map<String, dynamic>>[].obs;

  // Legends
  final RxList legends = <Map<String, dynamic>>[].obs;

  // Attendance Static Contents
  final RxMap<String, String> attendanceStaticContents = <String, String>{}.obs;

  // Profile data
  final RxBool isProfileLoading = false.obs;
  final RxBool hasProfileError = false.obs;
  final RxString profileErrorMessage = ''.obs;

  // Contact Information
  final RxString profileEmpNumber = ''.obs;
  final RxString profileEmployeeName = ''.obs;
  final RxString profileEmpEmail = ''.obs;
  final RxString profileEmpMobile = ''.obs;

  // Work Information
  final RxList workInformation = <Map<String, dynamic>>[].obs;

  // Skills
  final RxList skills = <Map<String, dynamic>>[].obs;

  // Certifications
  final RxList certifications = <Map<String, dynamic>>[].obs;

  // Profile Static Contents
  final RxMap<String, String> profileStaticContents = <String, String>{}.obs;

  // Notification data
  final RxBool isNotificationLoading = false.obs;
  final RxBool hasNotificationError = false.obs;
  final RxString notificationErrorMessage = ''.obs;

  // Notifications list
  final RxList notifications = <Map<String, dynamic>>[].obs;

  // Notification Static Contents
  final RxMap<String, String> notificationStaticContents =
      <String, String>{}.obs;

  // Common Contents (for base URL)
  final RxMap<String, String> commonContents = <String, String>{}.obs;

  // Settings data
  final RxBool isSettingsLoading = false.obs;
  final RxBool hasSettingsError = false.obs;
  final RxString settingsErrorMessage = ''.obs;

  // Settings Static Contents
  final RxMap<String, String> settingsStaticContents = <String, String>{}.obs;

  // Profile Picture
  final RxString profilePictureUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
    initializeProfilePicture();
  }

  void changeTab(int index) {
    currentIndex.value = index;
    // Fetch attendance data when attendance tab is selected
    if (index == 1) {
      fetchAttendanceData();
    }
    // Fetch profile data when profile tab is selected
    if (index == 2) {
      fetchProfileData();
    }
    // Fetch notification data when notification tab is selected
    if (index == 3) {
      fetchNotificationData();
      // Reset notification count when user visits notification tab
      _notificationService.resetNotificationCount(notifications.length);
    }
    // Initialize calendar when calendar tab is selected
    if (index == 4) {
      // Initialize calendar controller if not already done
      if (!Get.isRegistered<CalendarController>()) {
        Get.put(CalendarController());
      }
    }
    // Fetch settings data when settings tab is selected
    if (index == 5) {
      fetchSettingsData();
    }
  }

  Future<void> fetchHomeData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // TODO: Get these values from auth controller or shared preferences
      String instanceName = await GetStorage().read(
        'instanceName',
      ); //'Universal';
      String userEmail = await GetStorage().read(
        'email',
      ); // 'email@netsoftpro.net';

      final languageController = Get.find<LanguageController>();

      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Client/GetHomeData',
        queryParameters: {
          'instanceName': instanceName,
          'Usremail': userEmail,
          'Lang': languageController.currentLangCode,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('API Response: $data'); // Debug print

        // Parse employee details
        if (data['EmployeeDetails'] != null) {
          try {
            final empDetails = data['EmployeeDetails'];
            print('EmployeeDetails type: ${empDetails.runtimeType}');
            print('EmployeeDetails value: $empDetails');

            if (empDetails is Map<String, dynamic>) {
              empNumber.value = empDetails['Emp_Number']?.toString() ?? '';
              employeeName.value = empDetails['EmployeeName']?.toString() ?? '';
              positionName.value = empDetails['PositionName']?.toString() ?? '';
            } else if (empDetails is List && empDetails.isNotEmpty) {
              // Handle case where EmployeeDetails might be a list
              final firstItem = empDetails[0];
              if (firstItem is Map<String, dynamic>) {
                empNumber.value = firstItem['Emp_Number']?.toString() ?? '';
                employeeName.value =
                    firstItem['EmployeeName']?.toString() ?? '';
                positionName.value =
                    firstItem['PositionName']?.toString() ?? '';
              }
            } else {
              print('Unexpected EmployeeDetails structure: $empDetails');
            }
          } catch (e) {
            print('Error parsing employee details: $e');
            empNumber.value = '';
            employeeName.value = '';
            positionName.value = '';
          }
        }

        // Parse dashboard data
        if (data['DashboardData'] != null) {
          try {
            final dashboardList = data['DashboardData'] as List;
            final parsedDashboard = <Map<String, dynamic>>[];

            for (final item in dashboardList) {
              if (item is Map<String, dynamic>) {
                parsedDashboard.add(item);
              }
            }

            dashboardData.value = parsedDashboard;
          } catch (e) {
            print('Error parsing dashboard data: $e');
            dashboardData.value = [];
          }
        }

        // Parse static contents
        if (data['StaticContents'] != null) {
          try {
            final contents = data['StaticContents'] as List;
            final tempContents = <String, String>{};

            for (final content in contents) {
              if (content is Map<String, dynamic>) {
                final contentType = content['ContentType']?.toString();
                final contentText = content['ContentText']?.toString() ?? '';

                if (contentType != null) {
                  tempContents[contentType] = contentText;
                }
              }
            }

            staticContents.value = tempContents;
          } catch (e) {
            print('Error parsing static contents: $e');
            staticContents.value = {};
          }
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load home data: ${e.toString()}';
      print('Error fetching home data: $e');
      print('Error stack trace: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void refreshData() {
    fetchHomeData();
  }

  Future<void> fetchAttendanceData() async {
    try {
      isAttendanceLoading.value = true;
      hasAttendanceError.value = false;
      attendanceErrorMessage.value = '';

      String instanceName = await GetStorage().read('instanceName');
      String userEmail = await GetStorage().read('email');

      final languageController = Get.find<LanguageController>();

      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Client/GetAttData',
        queryParameters: {
          'instanceName': instanceName,
          'Usremail': userEmail,
          'Lang': languageController.currentLangCode,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('Attendance API Response: $data');

        // Parse Attendance Rate
        if (data['Attendance Rate'] != null) {
          try {
            final rateList = data['Attendance Rate'] as List;
            final parsedRate = <Map<String, dynamic>>[];

            for (final item in rateList) {
              if (item is Map<String, dynamic>) {
                parsedRate.add(item);
              }
            }

            attendanceRate.value = parsedRate;
          } catch (e) {
            print('Error parsing attendance rate: $e');
            attendanceRate.value = [];
          }
        }

        // Parse Attendance Counts
        if (data['Attendance Counts'] != null) {
          try {
            final countsList = data['Attendance Counts'] as List;
            final parsedCounts = <Map<String, dynamic>>[];

            for (final item in countsList) {
              if (item is Map<String, dynamic>) {
                parsedCounts.add(item);
              }
            }

            attendanceCounts.value = parsedCounts;
          } catch (e) {
            print('Error parsing attendance counts: $e');
            attendanceCounts.value = [];
          }
        }

        // Parse Recent Activities
        if (data['Recent Activites'] != null) {
          try {
            final activitiesList = data['Recent Activites'] as List;
            final parsedActivities = <Map<String, dynamic>>[];

            for (final item in activitiesList) {
              if (item is Map<String, dynamic>) {
                parsedActivities.add(item);
              }
            }

            // Sort activities by date using AttDate field
            parsedActivities.sort((a, b) {
              final dateA = a['AttDate'] ?? '';
              final dateB = b['AttDate'] ?? '';
              return dateB.compareTo(
                dateA,
              ); // Sort in descending order (newest first)
            });

            recentActivities.value = parsedActivities;
          } catch (e) {
            print('Error parsing recent activities: $e');
            recentActivities.value = [];
          }
        }

        // Parse Legends
        if (data['legends'] != null) {
          try {
            final legendsList = data['legends'] as List;
            final parsedLegends = <Map<String, dynamic>>[];

            for (final item in legendsList) {
              if (item is Map<String, dynamic>) {
                parsedLegends.add(item);
              }
            }

            legends.value = parsedLegends;
          } catch (e) {
            print('Error parsing legends: $e');
            legends.value = [];
          }
        }

        // Parse Attendance Static Contents
        if (data['StaticContents'] != null) {
          try {
            final contents = data['StaticContents'] as List;
            final tempContents = <String, String>{};

            for (final content in contents) {
              if (content is Map<String, dynamic>) {
                final contentType = content['ContentType']?.toString();
                final contentText = content['ContentText']?.toString() ?? '';

                if (contentType != null) {
                  tempContents[contentType] = contentText;
                }
              }
            }

            attendanceStaticContents.value = tempContents;
          } catch (e) {
            print('Error parsing attendance static contents: $e');
            attendanceStaticContents.value = {};
          }
        }
      }
    } catch (e) {
      hasAttendanceError.value = true;
      attendanceErrorMessage.value =
          'Failed to load attendance data: ${e.toString()}';
      print('Error fetching attendance data: $e');
    } finally {
      isAttendanceLoading.value = false;
    }
  }

  void refreshAttendanceData() {
    fetchAttendanceData();
  }

  Future<void> fetchProfileData() async {
    try {
      isProfileLoading.value = true;
      hasProfileError.value = false;
      profileErrorMessage.value = '';

      String instanceName = await GetStorage().read('instanceName');
      String userEmail = await GetStorage().read('email');

      final languageController = Get.find<LanguageController>();

      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Client/GetProfileData',
        queryParameters: {
          'instanceName': instanceName,
          'Usremail': userEmail,
          'Lang': languageController.currentLangCode,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('Profile API Response: $data');

        // Parse Contact Information
        if (data['Contact information'] != null) {
          try {
            final contactInfo =
                data['Contact information'] as Map<String, dynamic>;
            profileEmpNumber.value =
                contactInfo['Emp_Number']?.toString() ?? '';
            profileEmployeeName.value =
                contactInfo['EmployeeName']?.toString() ?? '';
            profileEmpEmail.value = contactInfo['Emp_Email']?.toString() ?? '';
            profileEmpMobile.value =
                contactInfo['Emp_Mobile']?.toString() ?? '';
          } catch (e) {
            print('Error parsing contact information: $e');
            profileEmpNumber.value = '';
            profileEmployeeName.value = '';
            profileEmpEmail.value = '';
            profileEmpMobile.value = '';
          }
        }

        // Parse Work Information
        if (data['Work Information'] != null) {
          try {
            final workList = data['Work Information'] as List;
            final parsedWork = <Map<String, dynamic>>[];

            for (final item in workList) {
              if (item is Map<String, dynamic>) {
                parsedWork.add(item);
              }
            }

            workInformation.value = parsedWork;
          } catch (e) {
            print('Error parsing work information: $e');
            workInformation.value = [];
          }
        }

        // Parse Skills
        if (data['Skills'] != null) {
          try {
            final skillsList = data['Skills'] as List;
            final parsedSkills = <Map<String, dynamic>>[];

            for (final item in skillsList) {
              if (item is Map<String, dynamic>) {
                parsedSkills.add(item);
              }
            }

            skills.value = parsedSkills;
          } catch (e) {
            print('Error parsing skills: $e');
            skills.value = [];
          }
        }

        // Parse Certifications
        if (data['Certifications'] != null) {
          try {
            final certList = data['Certifications'] as List;
            final parsedCerts = <Map<String, dynamic>>[];

            for (final item in certList) {
              if (item is Map<String, dynamic>) {
                parsedCerts.add(item);
              }
            }

            certifications.value = parsedCerts;
          } catch (e) {
            print('Error parsing certifications: $e');
            certifications.value = [];
          }
        }

        // Parse Profile Static Contents
        if (data['StaticContents'] != null) {
          try {
            final contents = data['StaticContents'] as List;
            final tempContents = <String, String>{};

            for (final content in contents) {
              if (content is Map<String, dynamic>) {
                final contentType = content['ContentType']?.toString();
                final contentText = content['ContentText']?.toString() ?? '';

                if (contentType != null) {
                  tempContents[contentType] = contentText;
                }
              }
            }

            profileStaticContents.value = tempContents;
          } catch (e) {
            print('Error parsing profile static contents: $e');
            profileStaticContents.value = {};
          }
        }
      }
    } catch (e) {
      hasProfileError.value = true;
      profileErrorMessage.value =
          'Failed to load profile data: ${e.toString()}';
      print('Error fetching profile data: $e');
    } finally {
      isProfileLoading.value = false;
    }
  }

  void refreshProfileData() {
    fetchProfileData();
  }

  Future<void> fetchNotificationData() async {
    try {
      isNotificationLoading.value = true;
      hasNotificationError.value = false;
      notificationErrorMessage.value = '';

      String instanceName = await GetStorage().read('instanceName');
      String userEmail = await GetStorage().read('email');

      final languageController = Get.find<LanguageController>();

      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Client/GetNotifcnData',
        queryParameters: {
          'instanceName': instanceName,
          'usrEmail': userEmail,
          'lang': languageController.currentLangCode,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('Notification API Response: $data');

        // Parse Notifications
        if (data['Notifications'] != null) {
          try {
            final notificationsList = data['Notifications'] as List;
            final parsedNotifications = <Map<String, dynamic>>[];

            for (final item in notificationsList) {
              if (item is Map<String, dynamic>) {
                parsedNotifications.add(item);
              }
            }

            notifications.value = parsedNotifications;

            // Check for new notifications and show local push notification
            await _notificationService.checkForNewNotifications(
              parsedNotifications.length,
            );
          } catch (e) {
            print('Error parsing notifications: $e');
            notifications.value = [];
          }
        }

        // Parse Static Contents
        if (data['StaticContents'] != null) {
          try {
            final contents = data['StaticContents'] as List;
            final tempContents = <String, String>{};

            for (final content in contents) {
              if (content is Map<String, dynamic>) {
                final contentType = content['ContentType']?.toString();
                final contentText = content['ContentText']?.toString() ?? '';

                if (contentType != null) {
                  tempContents[contentType] = contentText;
                }
              }
            }

            notificationStaticContents.value = tempContents;
          } catch (e) {
            print('Error parsing notification static contents: $e');
            notificationStaticContents.value = {};
          }
        }

        // Parse Common Contents
        if (data['CommonContents'] != null) {
          try {
            final commonList = data['CommonContents'] as List;
            final tempCommon = <String, String>{};

            for (final content in commonList) {
              if (content is Map<String, dynamic>) {
                final baseUrl = content['BaseUrl']?.toString() ?? '';
                tempCommon['BaseUrl'] = baseUrl;
              }
            }

            commonContents.value = tempCommon;
          } catch (e) {
            print('Error parsing common contents: $e');
            commonContents.value = {};
          }
        }
      }
    } catch (e) {
      hasNotificationError.value = true;
      notificationErrorMessage.value =
          'Failed to load notification data: ${e.toString()}';
      print('Error fetching notification data: $e');
    } finally {
      isNotificationLoading.value = false;
    }
  }

  Future<void> updateNotificationReadStatus(
    int notificationId,
    int readStatus,
  ) async {
    try {
      String instanceName = await GetStorage().read('instanceName');
      String userEmail = await GetStorage().read('email');

      final languageController = Get.find<LanguageController>();

      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Client/UpdateReadStatus',
        queryParameters: {
          'instanceName': instanceName,
          'Usremail': userEmail,
          'Lang': languageController.currentLangCode,
          'notifcnID': notificationId,
          'readStatus': readStatus,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('Update Read Status Response: $data');

        // Refresh notification data after update
        await fetchNotificationData();

        return;
      }
    } catch (e) {
      print('Error updating notification read status: $e');
    }
  }

  void refreshNotificationData() {
    fetchNotificationData();
  }

  // Method to show individual notification for specific events
  Future<void> showIndividualNotification(String title, String body) async {
    await _notificationService.showCustomNotification(
      title: title,
      body: body,
      payload: 'custom_notification',
    );
  }

  // Fetch support URL from API
  Future<String?> getSupportURL() async {
    try {
      final response = await _dio.get(
        'https://auto.resourceplus.app/mobile/api/Master/GetSupportURL',
      );

      if (response.statusCode == 200 &&
          response.data is List &&
          response.data.isNotEmpty) {
        final data = response.data[0];
        return data['SupportURL'] as String?;
      }
    } catch (e) {
      print('Error fetching support URL: $e');
    }
    return null;
  }

  Future<void> fetchSettingsData() async {
    try {
      isSettingsLoading.value = true;
      hasSettingsError.value = false;
      settingsErrorMessage.value = '';

      String instanceName = await GetStorage().read('instanceName');
      String userEmail = await GetStorage().read('email');

      final languageController = Get.find<LanguageController>();

      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Client/GetSettingsData',
        queryParameters: {
          'instanceName': instanceName,
          'usrEmail': userEmail,
          'lang': languageController.currentLangCode,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('Settings API Response: $data');

        // Parse Settings Static Contents
        if (data['StaticContents'] != null) {
          try {
            final contents = data['StaticContents'] as List;
            final tempContents = <String, String>{};

            for (final content in contents) {
              if (content is Map<String, dynamic>) {
                final contentType = content['ContentType']?.toString();
                final contentText = content['ContentText']?.toString() ?? '';

                if (contentType != null) {
                  tempContents[contentType] = contentText;
                }
              }
            }

            settingsStaticContents.value = tempContents;
          } catch (e) {
            print('Error parsing settings static contents: $e');
            settingsStaticContents.value = {};
          }
        }
      }
    } catch (e) {
      hasSettingsError.value = true;
      settingsErrorMessage.value =
          'Failed to load settings data: ${e.toString()}';
      print('Error fetching settings data: $e');
    } finally {
      isSettingsLoading.value = false;
    }
  }

  void refreshSettingsData() {
    fetchSettingsData();
  }

  // Get Profile Picture URL
  String getProfilePictureUrl() {
    final instanceName = GetStorage().read('instanceName') ?? '';
    final userEmail = GetStorage().read('email') ?? '';
    final languageController = Get.find<LanguageController>();

    if (instanceName.isNotEmpty && userEmail.isNotEmpty) {
      return 'https://auto.resourceplus.app/Mobile/api/Client/GetProfPicture?instanceName=$instanceName&usrEmail=$userEmail&lang=${languageController.currentLangCode}';
    }
    return '';
  }

  // Initialize profile picture URL
  void initializeProfilePicture() {
    profilePictureUrl.value = getProfilePictureUrl();
  }
}
