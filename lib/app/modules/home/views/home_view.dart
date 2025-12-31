import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'tabs/home_tab.dart';
import 'tabs/attendance_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/notification_tab.dart';
import 'tabs/settings_tab.dart';
import '../../calendar/views/calendar_view.dart';
import 'package:resource_plus/app/routes/app_routes.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Obx(() {
        // Show FAB only on home tab
        if (controller.currentIndex.value == 0) {
          return FloatingActionButton.extended(
            onPressed: () {
              Get.toNamed(AppRoutes.hrPortal);
            },
            icon: const Icon(Icons.access_time, color: Colors.white),
            label: Text(
              'attendance_punch'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.orange[600],
            elevation: 4,
          );
        }
        return const SizedBox.shrink();
      }),
      body: Obx(() {
        switch (controller.currentIndex.value) {
          case 0:
            return const HomeTab();
          case 1:
            return const AttendanceTab();
          case 2:
            return const ProfileTab();
          case 3:
            return const NotificationTab();
          case 4:
            return const CalendarView();
          case 5:
            return const SettingsTab();
          default:
            return const HomeTab();
        }
      }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[600]
              : Colors.grey[400],
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 8,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'home'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.access_time),
              label: 'attendance'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: 'profile'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.notifications),
              label: 'notifications'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today),
              label: 'calendar'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: 'settings'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
