import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/home_controller.dart';
import '../../../../routes/app_routes.dart';

class HomeTab extends GetView<HomeController> {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[600]
                        : Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchHomeData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50),
                  // Header with employee info
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // Welcome section
                  _buildWelcomeSection(context),
                  const SizedBox(height: 24),

                  // Dashboard cards
                  _buildDashboardSection(context),
                  const SizedBox(height: 24),

                  // HR Portal section
                  _buildHrPortalSection(),
                  const SizedBox(height: 24),

                  // Today's Schedule section
                  // _buildScheduleSection(),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: controller.profilePictureUrl.value.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          controller.profilePictureUrl.value,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            );
                          },
                        ),
                      )
                    : const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.employeeName.value.isNotEmpty
                          ? controller.employeeName.value
                          : 'Employee Name',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.positionName.value.isNotEmpty
                          ? controller.positionName.value
                          : 'Position',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${controller.empNumber.value.isNotEmpty ? controller.empNumber.value : 'N/A'}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final welcomeText =
        controller.staticContents['WelcomeText'] ?? 'welcome_back'.tr;

    return Text(
      welcomeText,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onBackground,
      ),
    );
  }

  Widget _buildDashboardSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'dashboard'.tr,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: controller.dashboardData.length,
          itemBuilder: (context, index) {
            final item = controller.dashboardData[index];
            return _buildDashboardCard(context, item);
          },
        ),
      ],
    );
  }

  Widget _buildDashboardCard(BuildContext context, Map<String, dynamic> item) {
    final icon = item['QInfoIcon'] ?? 'fa fa-info';
    final title = item['QInfoTitle'] ?? '';
    final count = item['QInfoCount'] ?? 0;
    final description = item['QInfoDescription'] ?? '';
    final subTitle = item['QInfoSubTitle'] ?? '';

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconFromFontAwesome(icon),
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subTitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[600]
                    : Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[500]
                    : Colors.grey[500],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHrPortalSection() {
    final headText =
        controller.staticContents['HrLinkHeadText'] ?? 'hr_portal'.tr;
    final subheadText =
        controller.staticContents['HrLinkSubheadText'] ??
        'access_hr_services'.tr;

    return GestureDetector(
      onTap: () async {
        try {
          final webLink = GetStorage().read('webLink');
          print('webLink: $webLink');

          if (webLink == null || webLink.toString().isEmpty) {
            Get.snackbar(
              'error'.tr,
              'hr_portal_link_error'.tr,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
            );
            return;
          }

          final String urlString = webLink.toString();
          print('URL String: $urlString');

          // Navigate to in-app WebView
          Get.toNamed(
            AppRoutes.webview,
            parameters: {'url': urlString, 'title': 'HR Portal'},
          );

          // // Open in external browser instead of in-app WebView (COMMENTED)
          // final Uri url = Uri.parse(urlString);
          // if (await canLaunchUrl(url)) {
          //   await launchUrl(
          //     url,
          //     mode: LaunchMode.externalApplication, // Force external browser
          //   );
          //
          //   // Show success message
          //   Get.snackbar(
          //     'success'.tr,
          //     'hr_portal_opened_browser'.tr,
          //     backgroundColor: Colors.green,
          //     colorText: Colors.white,
          //     duration: const Duration(seconds: 2),
          //   );
          // } else {
          //   throw Exception('Could not launch $urlString');
          // }
        } catch (e) {
          print('Error opening HR Portal: $e');
          Get.snackbar(
            'error'.tr,
            '${'hr_portal_error'.tr}: ${e.toString()}',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[400]!, Colors.orange[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.business, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subheadText,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    final scheduleText =
        controller.staticContents['ScheduleheadText'] ?? "Today's Schedule";
    final seeAllText = controller.staticContents['SeeAllText'] ?? 'See All';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              scheduleText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to schedule page
              },
              child: Text(
                seeAllText,
                style: const TextStyle(
                  color: Color(0xFF2196F3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.schedule,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'No scheduled activities for today',
                      style: TextStyle(fontSize: 16, color: Color(0xFF2C3E50)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIconFromFontAwesome(String fontAwesomeIcon) {
    switch (fontAwesomeIcon) {
      case 'fa fa-list-alt':
        return Icons.list_alt;
      case 'fa fa-calendar-check-o':
        return Icons.calendar_today;
      case 'fa fa-book':
        return Icons.book;
      case 'fa fa-briefcase':
        return Icons.work;
      case 'fa fa-bank':
        return Icons.account_balance;
      case 'fa fa-money':
        return Icons.attach_money;
      default:
        return Icons.info;
    }
  }
}
