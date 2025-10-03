import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:resource_plus/app/routes/app_pages.dart';
import 'package:resource_plus/app/routes/app_routes.dart';
import '../../controllers/home_controller.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Obx(() {
        if (controller.isProfileLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        if (controller.hasProfileError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.profileErrorMessage.value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[600]
                        : Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshProfileData,
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
          onRefresh: () async => controller.refreshProfileData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                _buildHeader(context, controller),
                const SizedBox(height: 24),
                _buildContactInformation(context, controller),
                const SizedBox(height: 16),
                _buildWorkInformation(context, controller),
                const SizedBox(height: 16),
                _buildSkills(context, controller),
                const SizedBox(height: 16),
                _buildCertifications(context, controller),
                const SizedBox(height: 16),
                // _buildLogoutButton(context),
                // const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context, HomeController controller) {
    return Container(
      width: double.infinity,
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
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black.withOpacity(0.1)
                : Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: controller.profilePictureUrl.value.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      controller.profilePictureUrl.value,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
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
                : const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            controller.profileEmployeeName.value.isNotEmpty
                ? controller.profileEmployeeName.value
                : 'Employee Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            controller.profileEmpNumber.value.isNotEmpty
                ? 'ID: ${controller.profileEmpNumber.value}'
                : 'Employee ID',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInformation(
    BuildContext context,
    HomeController controller,
  ) {
    final contactText =
        controller.profileStaticContents['ContactText'] ??
        'Contact Information';
    final emailText = controller.profileStaticContents['Emailext'] ?? 'Email';
    final phoneText = controller.profileStaticContents['PhoneText'] ?? 'Phone';

    return _buildSection(
      context: context,
      title: contactText,
      icon: Icons.contact_phone,
      children: [
        _buildInfoRow(
          context: context,
          icon: Icons.email,
          label: emailText,
          value: controller.profileEmpEmail.value.isNotEmpty
              ? controller.profileEmpEmail.value
              : 'Not provided',
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context: context,
          icon: Icons.phone,
          label: phoneText,
          value: controller.profileEmpMobile.value.isNotEmpty
              ? controller.profileEmpMobile.value
              : 'Not provided',
        ),
      ],
    );
  }

  Widget _buildWorkInformation(
    BuildContext context,
    HomeController controller,
  ) {
    final workText =
        controller.profileStaticContents['WorkText'] ?? 'Work Information';
    final companyText =
        controller.profileStaticContents['Companytext'] ?? 'Company';
    final departmentText =
        controller.profileStaticContents['DepartmentText'] ?? 'Department';
    final joinText =
        controller.profileStaticContents['JoinText'] ?? 'Join Date';

    return _buildSection(
      context: context,
      title: workText,
      icon: Icons.work,
      children: [
        if (controller.workInformation.isNotEmpty)
          ...controller.workInformation
              .map(
                (work) => Column(
                  children: [
                    _buildInfoRow(
                      context: context,
                      icon: Icons.business,
                      label: companyText,
                      value: work['Company']?.toString() ?? 'Not provided',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context: context,
                      icon: Icons.account_tree,
                      label: departmentText,
                      value: work['Organization']?.toString() ?? 'Not provided',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context: context,
                      icon: Icons.calendar_today,
                      label: joinText,
                      value: work['DateOfJoin']?.toString() ?? 'Not provided',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context: context,
                      icon: Icons.badge,
                      label: 'Position',
                      value: work['PositionName']?.toString() ?? 'Not provided',
                    ),
                  ],
                ),
              )
              .toList()
        else
          _buildInfoRow(
            context: context,
            icon: Icons.info,
            label: 'Information',
            value: 'No work information available',
          ),
      ],
    );
  }

  Widget _buildSkills(BuildContext context, HomeController controller) {
    final skillText = controller.profileStaticContents['SkillText'] ?? 'Skills';

    return _buildSection(
      context: context,
      title: skillText,
      icon: Icons.psychology,
      children: [
        if (controller.skills.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.skills
                .map(
                  (skill) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      skill['Skill']?.toString() ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                )
                .toList(),
          )
        else
          _buildInfoRow(
            context: context,
            icon: Icons.info,
            label: 'Skills',
            value: 'No skills listed',
          ),
      ],
    );
  }

  Widget _buildCertifications(BuildContext context, HomeController controller) {
    final certText =
        controller.profileStaticContents['CertificationsText'] ??
        'Certifications';

    return _buildSection(
      context: context,
      title: certText,
      icon: Icons.verified,
      children: [
        if (controller.certifications.isNotEmpty)
          ...controller.certifications
              .map(
                (cert) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: const Color(0xFF4CAF50),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cert['Certification']?.toString() ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList()
        else
          _buildInfoRow(
            context: context,
            icon: Icons.info,
            label: 'Certifications',
            value: 'No certifications listed',
          ),
      ],
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black.withOpacity(0.05)
                : Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[600]
              : Colors.grey[400],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[600]
                      : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildLogoutButton(BuildContext context) {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).colorScheme.surface,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Theme.of(context).brightness == Brightness.light
  //               ? Colors.black.withOpacity(0.05)
  //               : Colors.black.withOpacity(0.2),
  //           blurRadius: 10,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(8),
  //               decoration: BoxDecoration(
  //                 color: Colors.red.withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: const Icon(
  //                 Icons.logout,
  //                 color: Colors.red,
  //                 size: 20,
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             const Text(
  //               'Account',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //                 color: Color(0xFF2C3E50),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         SizedBox(
  //           width: double.infinity,
  //           child: ElevatedButton.icon(
  //             onPressed: () async {
  //               // TODO: Add logout functionality here
  //               await GetStorage().write('isLoggedIn', false);
  //               Get.offAllNamed(AppRoutes.login);
  //               print('Logout button tapped');
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.red,
  //               foregroundColor: Colors.white,
  //               padding: const EdgeInsets.symmetric(vertical: 16),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               elevation: 0,
  //             ),
  //             icon: const Icon(Icons.logout, size: 20),
  //             label: const Text(
  //               'Logout',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
