import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class AttendanceTab extends GetView<HomeController> {
  const AttendanceTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Obx(() {
        if (controller.isAttendanceLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        if (controller.hasAttendanceError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'error_loading_attendance'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.attendanceErrorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[600]
                        : Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshAttendanceData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text('retry'.tr),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAttendanceData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const SizedBox(height: 50),
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  // Attendance Rate Section
                  _buildAttendanceRateSection(context),
                  const SizedBox(height: 24),
                  // Attendance Counts Section
                  _buildAttendanceCountsSection(context),
                  const SizedBox(height: 24),
                  // Recent Activities Section
                  _buildRecentActivitiesSection(context),
                  const SizedBox(height: 24),
                  // Legends Section
                  _buildLegendsSection(context),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final attendanceText =
        controller.attendanceStaticContents['AttendanceText'] ?? 'Attendance';
    return Text(
      attendanceText,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onBackground,
      ),
    );
  }

  Widget _buildAttendanceRateSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'attendance_rate'.tr,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        if (controller.attendanceRate.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildRateCard(
                    context,
                    'present'.tr,
                    controller.attendanceRate.first['PresentPercentage'] ??
                        '0.00',
                    '%',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRateCard(
                    context,
                    'absent'.tr,
                    controller.attendanceRate.first['AbsentPercentage'] ??
                        '0.00',
                    '%',
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRateCard(
    BuildContext context,
    String title,
    String value,
    String unit,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$value$unit',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCountsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'attendance_summary'.tr,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        if (controller.attendanceCounts.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: controller.attendanceCounts.length,
            itemBuilder: (context, index) {
              final item = controller.attendanceCounts[index];
              return _buildCountCard(context, item);
            },
          ),
      ],
    );
  }

  Widget _buildCountCard(BuildContext context, Map<String, dynamic> item) {
    final countType = item['CountType'] ?? '';
    final noOfDays = item['NoOfDays'] ?? 0;
    Color cardColor;
    IconData? icon;
    bool isLessThan = false;
    switch (countType.toLowerCase()) {
      case 'absent':
        cardColor = Colors.red;
        icon = Icons.cancel;
        break;
      case 'early':
        cardColor = Colors.green;
        icon = Icons.trending_up;
        break;
      case 'late':
        cardColor = Colors.orange;
        icon = Icons.trending_down;
        break;
      case 'present':
        cardColor = Colors.blue;
        icon = Icons.check_circle;
        break;
      case 'less':
        cardColor = Colors.orange;
        isLessThan = true;
        break;
      default:
        cardColor = Theme.of(context).colorScheme.primary;
        icon = Icons.info;
    }
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey.withOpacity(0.1)
                : Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isLessThan
                ? Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '<',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : Icon(icon, color: cardColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            _translateAttendanceType(countType),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$noOfDays ${'days'.tr}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey[600]
                  : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesSection(BuildContext context) {
    final recentText =
        controller.attendanceStaticContents['RecentText'] ??
        'recent_attendance'.tr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recentText,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        if (controller.recentActivities.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.recentActivities.length,
            itemBuilder: (context, index) {
              final activity = controller.recentActivities[index];
              return _buildActivityCard(context, activity);
            },
          ),
      ],
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    Map<String, dynamic> activity,
  ) {
    final attDate = activity['AttDate'] ?? '';
    final dayType = activity['DayType'] ?? '';
    final checkIn = activity['CheckIN'] ?? '';
    final checkOut = activity['CheckOut'] ?? '';
    final dayTypeColor = activity['DayTypeColor'] ?? '#000000';

    Color color;
    try {
      color = Color(int.parse(dayTypeColor.replaceAll('#', '0xFF')));
    } catch (e) {
      color = Theme.of(context).colorScheme.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey.withOpacity(0.1)
                : Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      attDate,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _translateAttendanceType(dayType),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (checkIn.isNotEmpty || checkOut.isNotEmpty) ...[
                  if (checkIn.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.login, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          '${'check_in'.tr}: $checkIn',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                ? Colors.grey[600]
                                : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  if (checkOut.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.logout, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          '${'check_out'.tr}: $checkOut',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                ? Colors.grey[600]
                                : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ] else ...[
                  Text(
                    'no_checkin_data'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[500]
                          : Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'legend'.tr,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        if (controller.legends.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: controller.legends.map((legend) {
                return _buildLegendItem(context, legend);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, Map<String, dynamic> legend) {
    final dayType = legend['DayType'] ?? '';
    final count = legend['Count'] ?? 0;
    final dayTypeColor = legend['DayTypeColor'] ?? '#000000';

    Color color;
    try {
      color = Color(int.parse(dayTypeColor.replaceAll('#', '0xFF')));
    } catch (e) {
      color = Theme.of(context).colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _translateAttendanceType(dayType),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Translate attendance types from API (case-insensitive)
  String _translateAttendanceType(String type) {
    if (type.isEmpty) return type;

    final lowerType = type.toLowerCase().trim();

    // Map common attendance types to translation keys
    switch (lowerType) {
      case 'absent':
        return 'absent'.tr;
      case 'present':
        return 'present'.tr;
      case 'early':
        return 'early'.tr;
      case 'late':
        return 'late'.tr;
      case 'week end':
      case 'weekend':
      case 'week_end':
        return 'week_end'.tr;
      default:
        // If no translation found, return original
        return type;
    }
  }
}
