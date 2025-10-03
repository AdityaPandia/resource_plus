import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:resource_plus/app/routes/app_pages.dart';
import '../../../../routes/app_routes.dart';
import '../../controllers/home_controller.dart';
import '../../../../controllers/theme_controller.dart';
import '../../../../controllers/language_controller.dart';
import '../../../auth/controllers/auth_controller.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final themeController = Get.find<ThemeController>();
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Obx(() {
        if (controller.isSettingsLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        if (controller.hasSettingsError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.red[300]
                      : Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.red[700]
                        : Colors.red[400],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    controller.settingsErrorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[600]
                          : Colors.grey[400],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.refreshSettingsData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Header
            SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    controller.settingsStaticContents['SettingsText'] ??
                        'settings'.tr,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // Settings List
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.fetchSettingsData,
                color: Theme.of(context).colorScheme.primary,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Preferences Section
                      _buildSettingsSection(
                        context: context,
                        title:
                            controller
                                .settingsStaticContents['PreferencesText'] ??
                            'preferences'.tr,
                        items: [
                          Obx(
                            () => _buildSettingsItem(
                              context: context,
                              icon: Icons.language,
                              title:
                                  controller
                                      .settingsStaticContents['LanguageText'] ??
                                  'language'.tr,
                              subtitle: 'choose_language'.tr,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    languageController
                                        .currentLanguageDisplayName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.grey[600]
                                          : Colors.grey[300],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.grey[400]
                                        : Colors.grey[300],
                                  ),
                                ],
                              ),
                              onTap: () {
                                _showLanguageDialog(
                                  context,
                                  languageController,
                                );
                              },
                            ),
                          ),
                          _buildSettingsItem(
                            context: context,
                            icon: Icons.dark_mode,
                            title:
                                controller
                                    .settingsStaticContents['DarkModeText'] ??
                                'Dark Mode',
                            subtitle: 'switch_theme'.tr,
                            trailing: Obx(
                              () => Switch(
                                value: themeController.isDarkMode.value,
                                onChanged: (value) {
                                  themeController.toggleTheme();
                                },
                                activeColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                              ),
                            ),
                            onTap: null,
                          ),
                          _buildSettingsItem(
                            context: context,
                            icon: Icons.notifications,
                            title:
                                controller
                                    .settingsStaticContents['NotificationsText'] ??
                                'Notifications',
                            subtitle: 'manage_notifications'.tr,
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey[400]
                                  : Colors.grey[300],
                            ),
                            onTap: () {
                              _showNotificationSettings(context);
                            },
                          ),
                          _buildSettingsItem(
                            context: context,
                            icon: Icons.notification_add,
                            title: 'Test Local Notification',
                            subtitle: 'Test the local notification system',
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey[400]
                                  : Colors.grey[300],
                            ),
                            onTap: () {
                              controller.showIndividualNotification(
                                'Test Notification',
                                'This is a test local notification!',
                              );
                            },
                          ),
                          // _buildSettingsItem(
                          //   context: context,
                          //   icon: Icons.fingerprint,
                          //   title: 'Test Biometric Check',
                          //   subtitle: 'Test the biometric verification page',
                          //   trailing: Icon(
                          //     Icons.arrow_forward_ios,
                          //     size: 16,
                          //     color: Colors.grey[400],
                          //   ),
                          //   onTap: () {
                          //     Get.toNamed(AppRoutes.biometricCheck);
                          //   },
                          // ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Security Section
                      _buildSettingsSection(
                        context: context,
                        title:
                            controller.settingsStaticContents['SecurityText'] ??
                            'security'.tr,
                        items: [
                          _buildSettingsItem(
                            context: context,
                            icon: Icons.lock,
                            title:
                                controller
                                    .settingsStaticContents['ChangePasswordText'] ??
                                'Change Password',
                            subtitle: 'update_password'.tr,
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey[400]
                                  : Colors.grey[300],
                            ),
                            onTap: () {
                              _showChangePasswordDialog(context);
                            },
                          ),
                          _buildSettingsItem(
                            context: context,
                            icon: Icons.privacy_tip,
                            title:
                                controller
                                    .settingsStaticContents['PrivacySettingsText'] ??
                                'Privacy Settings',
                            subtitle: 'manage_privacy'.tr,
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey[400]
                                  : Colors.grey[300],
                            ),
                            onTap: () {
                              _showPrivacySettings(context);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Support Section
                      _buildSettingsSection(
                        context: context,
                        title:
                            controller.settingsStaticContents['SupportText'] ??
                            'support'.tr,
                        items: [
                          _buildSettingsItem(
                            context: context,
                            icon: Icons.help_outline,
                            title:
                                controller
                                    .settingsStaticContents['HelpAndSupportText'] ??
                                'Help & Support',
                            subtitle: 'get_help'.tr,
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey[400]
                                  : Colors.grey[300],
                            ),
                            onTap: () async {
                              await _openSupportURL();
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Sign Out Section
                      _buildSettingsSection(
                        context: context,
                        title: 'account'.tr,
                        items: [
                          _buildSettingsItem(
                            context: context,
                            icon: Icons.logout,
                            title:
                                controller
                                    .settingsStaticContents['SignOutText'] ??
                                'Sign out',
                            subtitle: 'sign_out_account'.tr,
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey[400]
                                  : Colors.grey[300],
                            ),
                            onTap: () async {
                              // Show confirmation dialog
                              final shouldSignOut = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('sign_out'.tr),
                                  content: Text(
                                    'Are you sure you want to sign out?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text('cancel'.tr),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text('sign_out'.tr),
                                    ),
                                  ],
                                ),
                              );

                              if (shouldSignOut == true) {
                                await GetStorage().remove('instanceName');
                                await GetStorage().remove('isLoggedIn');
                                await Get.put(AuthController()).logout();
                                Get.offAllNamed(AppPages.initialLogin);
                              }
                            },
                            isDestructive: true,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSettingsSection({
    required BuildContext context,
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? Colors.red.withValues(alpha: 0.1)
                      : Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isDestructive
                      ? (Theme.of(context).brightness == Brightness.light
                            ? Colors.red
                            : Colors.red[400])
                      : Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDestructive
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey[600]
                            : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    LanguageController languageController,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('language'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                leading: Radio<String>(
                  value: LanguageController.english,
                  groupValue: languageController.currentLanguage.value,
                  onChanged: (value) {
                    if (value != null) {
                      languageController.changeLanguage(value);
                      Navigator.of(context).pop();
                      // Trigger a refresh of all data to get translated content
                      Get.find<HomeController>().refreshAllData();
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('العربية'),
                leading: Radio<String>(
                  value: LanguageController.arabic,
                  groupValue: languageController.currentLanguage.value,
                  onChanged: (value) {
                    if (value != null) {
                      languageController.changeLanguage(value);
                      Navigator.of(context).pop();
                      // Trigger a refresh of all data to get translated content
                      Get.find<HomeController>().refreshAllData();
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('cancel'.tr),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationSettings(BuildContext context) {
    final controller = Get.find<HomeController>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Obx(
              () => AlertDialog(
                title: Text('Notification Settings'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Live Notifications Toggle
                      ListTile(
                        title: Text('Live Notifications'),
                        subtitle: Text(
                          'Automatically check for new notifications',
                        ),
                        trailing: Switch(
                          value: controller.isPollingEnabled.value,
                          onChanged: (value) {
                            if (value) {
                              controller.enableNotificationPolling();
                            } else {
                              controller.disableNotificationPolling();
                            }
                          },
                        ),
                      ),

                      // Polling Interval
                      if (controller.isPollingEnabled.value) ...[
                        ListTile(
                          title: Text('Check Interval'),
                          subtitle: Text(
                            'How often to check for new notifications',
                          ),
                          trailing: DropdownButton<int>(
                            value: controller.pollingIntervalMinutes.value,
                            items: [1, 2, 5, 10, 15, 30].map((minutes) {
                              return DropdownMenuItem<int>(
                                value: minutes,
                                child: Text(
                                  '$minutes min${minutes == 1 ? '' : 's'}',
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                controller.updatePollingInterval(value);
                              }
                            },
                          ),
                        ),

                        // Polling Status
                        ListTile(
                          title: Text('Status'),
                          subtitle: Text(
                            controller.isPollingActive.value
                                ? 'Active - Checking every ${controller.pollingIntervalMinutes.value} minutes'
                                : 'Inactive',
                          ),
                          trailing: Icon(
                            controller.isPollingActive.value
                                ? Icons.check_circle
                                : Icons.pause_circle,
                            color: controller.isPollingActive.value
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),

                        // Force Check Button
                        ListTile(
                          title: Text('Check Now'),
                          subtitle: Text(
                            'Manually check for new notifications',
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: () {
                              controller.forceNotificationCheck();
                              Get.snackbar(
                                'Checking',
                                'Checking for new notifications...',
                                backgroundColor: Colors.blue,
                                colorText: Colors.white,
                              );
                            },
                          ),
                        ),
                      ],

                      const Divider(),

                      // Push Notifications
                      ListTile(
                        title: Text('Push Notifications'),
                        subtitle: Text(
                          'Show local notifications for new messages',
                        ),
                        trailing: Switch(
                          value: true, // TODO: Get from settings
                          onChanged: (value) {
                            // TODO: Save notification preference
                          },
                        ),
                      ),

                      // Email Notifications
                      ListTile(
                        title: Text('Email Notifications'),
                        subtitle: Text('Receive notifications via email'),
                        trailing: Switch(
                          value: true, // TODO: Get from settings
                          onChanged: (value) {
                            // TODO: Save email preference
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final authController = Get.put(AuthController());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Obx(
              () => AlertDialog(
                title: Text('change_password'.tr),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: currentPasswordController,
                      obscureText: true,
                      enabled: !authController.isLoading.value,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      enabled: !authController.isLoading.value,
                      decoration: InputDecoration(
                        labelText: 'new_password'.tr,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      enabled: !authController.isLoading.value,
                      decoration: InputDecoration(
                        labelText: 'confirm_password'.tr,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: authController.isLoading.value
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text('cancel'.tr),
                  ),
                  authController.isLoading.value
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            final newPassword = newPasswordController.text
                                .trim();
                            final currentContext = context;

                            if (newPassword.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Please enter a new password',
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            try {
                              final result = await authController
                                  .changeUserPassword(newPassword);

                              if (currentContext.mounted) {
                                Navigator.of(currentContext).pop();
                              }

                              if (result['success']) {
                                Get.snackbar(
                                  'Success',
                                  result['message'] ??
                                      'Password changed successfully',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              } else {
                                Get.snackbar(
                                  'Error',
                                  result['message'] ??
                                      'Error changing password',
                                  backgroundColor: Colors.redAccent,
                                  colorText: Colors.white,
                                );
                              }
                            } catch (e) {
                              if (currentContext.mounted) {
                                Navigator.of(currentContext).pop();
                              }
                              Get.snackbar(
                                'Error',
                                'Error changing password',
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                            }
                          },
                          child: Text('save'.tr),
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('privacy_settings'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Data Collection'),
                subtitle: Text('Allow app to collect usage data'),
                trailing: Switch(
                  value: false, // TODO: Get from settings
                  onChanged: (value) {
                    // TODO: Save privacy preference
                  },
                ),
              ),
              ListTile(
                title: Text('Analytics'),
                subtitle: Text('Share anonymous usage statistics'),
                trailing: Switch(
                  value: true, // TODO: Get from settings
                  onChanged: (value) {
                    // TODO: Save analytics preference
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Get.snackbar(
                  'Success',
                  'Privacy settings updated',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              child: Text('save'.tr),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openSupportURL() async {
    try {
      final controller = Get.find<HomeController>();

      // Show loading indicator
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Get.context != null
                  ? Theme.of(Get.context!).colorScheme.surface
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading support page...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Fetch support URL from API
      final supportURL = await controller.getSupportURL();

      // Close loading dialog
      Get.back();

      if (supportURL != null && supportURL.isNotEmpty) {
        // Navigate to WebView with support URL
        Get.toNamed(
          AppRoutes.webview,
          parameters: {'url': supportURL, 'title': 'Help & Support'},
        );
      } else {
        // Fallback to default support URL if API fails
        Get.toNamed(
          AppRoutes.webview,
          parameters: {
            'url': 'https://resourceplus.app/contact-us/',
            'title': 'Help & Support',
          },
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show error and fallback to default URL
      Get.snackbar(
        'Info',
        'Opening default support page',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );

      Get.toNamed(
        AppRoutes.webview,
        parameters: {
          'url': 'https://resourceplus.app/contact-us/',
          'title': 'Help & Support',
        },
      );
    }
  }
}
