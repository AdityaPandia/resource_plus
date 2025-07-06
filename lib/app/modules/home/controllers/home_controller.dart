import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  final Dio _dio = Dio();
  
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
  
  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }
  
  void changeTab(int index) {
    currentIndex.value = index;
    // Fetch attendance data when attendance tab is selected
    if (index == 1) {
      fetchAttendanceData();
    }
  }
  
  Future<void> fetchHomeData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      // TODO: Get these values from auth controller or shared preferences
      String instanceName = await GetStorage().read('instanceName');//'Universal';
      String userEmail = await GetStorage().read('email'); // 'email@netsoftpro.net';
      const int lang = 1;
      
      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Client/GetHomeData',
        queryParameters: {
          'instanceName': instanceName,
          'Usremail': userEmail,
          'Lang': lang,
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
                employeeName.value = firstItem['EmployeeName']?.toString() ?? '';
                positionName.value = firstItem['PositionName']?.toString() ?? '';
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
      const int lang = 1;
      
      final response = await _dio.get(
        'https://auto.resourceplus.app/Mobile/api/Client/GetAttData',
        queryParameters: {
          'instanceName': instanceName,
          'Usremail': userEmail,
          'Lang': lang,
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
      attendanceErrorMessage.value = 'Failed to load attendance data: ${e.toString()}';
      print('Error fetching attendance data: $e');
    } finally {
      isAttendanceLoading.value = false;
    }
  }
  
  void refreshAttendanceData() {
    fetchAttendanceData();
  }
} 