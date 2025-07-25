import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:resource_plus/app/routes/app_pages.dart';
import 'package:resource_plus/app/routes/app_routes.dart';
import '../../controllers/home_controller.dart';
import '../../../../controllers/theme_controller.dart';
import '../../../../controllers/language_controller.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final themeController = Get.find<ThemeController>();
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
                Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    controller.settingsErrorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                        ? Colors.grey.withOpacity(0.1)
                        : Colors.black.withOpacity(0.3),
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
                        'Settings',
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
                            'Preferences',
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
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey[400],
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
                            subtitle: 'Switch between light and dark themes',
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
                            subtitle: 'Manage notification preferences',
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                            onTap: () {
                              // TODO: Implement notification settings
                              print('Notification settings tapped');
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Security Section
                      _buildSettingsSection(
                        context: context,
                        title:
                            controller.settingsStaticContents['SecurityText'] ??
                            'Security',
                        items: [
                          _buildSettingsItem(
                            context: context,
                            icon: Icons.lock,
                            title:
                                controller
                                    .settingsStaticContents['ChangePasswordText'] ??
                                'Change Password',
                            subtitle: 'Update your account password',
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                            onTap: () {
                              // TODO: Implement change password
                              print('Change password tapped');
                            },
                          ),
                          _buildSettingsItem(
                            context: context,
                            icon: Icons.privacy_tip,
                            title:
                                controller
                                    .settingsStaticContents['PrivacySettingsText'] ??
                                'Privacy Settings',
                            subtitle: 'Manage your privacy preferences',
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                            onTap: () {
                              // TODO: Implement privacy settings
                              print('Privacy settings tapped');
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
                            'Support',
                        items: [
                          _buildSettingsItem(
                            context: context,
                            icon: Icons.help_outline,
                            title:
                                controller
                                    .settingsStaticContents['HelpAndSupportText'] ??
                                'Help & Support',
                            subtitle: 'Get help and contact support',
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                            onTap: () {
                              // TODO: Implement help and support
                              print('Help & Support tapped');
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Sign Out Section
                      _buildSettingsSection(
                        context: context,
                        title: 'Account',
                        items: [
                          _buildSettingsItem(
                            context: context,
                            icon: Icons.logout,
                            title:
                                controller
                                    .settingsStaticContents['SignOutText'] ??
                                'Sign out',
                            subtitle: 'Sign out of your account',
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                            onTap: () async {
                              // Show confirmation dialog
                              final shouldSignOut = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Sign Out'),
                                  content: const Text(
                                    'Are you sure you want to sign out?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Sign Out'),
                                    ),
                                  ],
                                ),
                              );

                              if (shouldSignOut == true) {
                                await GetStorage().write('isLoggedIn', false);
                                Get.offAllNamed(AppRoutes.login);
                                print('Logout button tapped');
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
                    ? Colors.grey.withOpacity(0.1)
                    : Colors.black.withOpacity(0.3),
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
                      ? Colors.red.withOpacity(0.1)
                      : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? Colors.red : const Color(0xFF2196F3),
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
                            : const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
}
