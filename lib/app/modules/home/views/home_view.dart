import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'tabs/home_tab.dart';
import 'tabs/attendance_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/notification_tab.dart';
import 'tabs/settings_tab.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            return const SettingsTab();
          default:
            return const HomeTab();
        }
      }),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeTab,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).brightness == Brightness.light 
            ? Colors.grey[600] 
            : Colors.grey[400],
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      )),
    );
  }
} 