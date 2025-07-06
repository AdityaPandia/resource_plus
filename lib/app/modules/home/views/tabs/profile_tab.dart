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
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        if (controller.isProfileLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            ),
          );
        }
        
        if (controller.hasProfileError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
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
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshProfileData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                _buildHeader(controller),
                const SizedBox(height: 24),
                _buildContactInformation(controller),
                const SizedBox(height: 16),
                _buildWorkInformation(controller),
                const SizedBox(height: 16),
                _buildSkills(controller),
                const SizedBox(height: 16),
                _buildCertifications(controller),
                const SizedBox(height: 16),
                _buildLogoutButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }
  
  Widget _buildHeader(HomeController controller) {
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
            color: Colors.black.withOpacity(0.1),
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
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
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
  
  Widget _buildContactInformation(HomeController controller) {
    final contactText = controller.profileStaticContents['ContactText'] ?? 'Contact Information';
    final emailText = controller.profileStaticContents['Emailext'] ?? 'Email';
    final phoneText = controller.profileStaticContents['PhoneText'] ?? 'Phone';
    
    return _buildSection(
      title: contactText,
      icon: Icons.contact_phone,
      children: [
        _buildInfoRow(
          icon: Icons.email,
          label: emailText,
          value: controller.profileEmpEmail.value.isNotEmpty 
              ? controller.profileEmpEmail.value 
              : 'Not provided',
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.phone,
          label: phoneText,
          value: controller.profileEmpMobile.value.isNotEmpty 
              ? controller.profileEmpMobile.value 
              : 'Not provided',
        ),
      ],
    );
  }
  
  Widget _buildWorkInformation(HomeController controller) {
    final workText = controller.profileStaticContents['WorkText'] ?? 'Work Information';
    final companyText = controller.profileStaticContents['Companytext'] ?? 'Company';
    final departmentText = controller.profileStaticContents['DepartmentText'] ?? 'Department';
    final joinText = controller.profileStaticContents['JoinText'] ?? 'Join Date';
    
    return _buildSection(
      title: workText,
      icon: Icons.work,
      children: [
        if (controller.workInformation.isNotEmpty)
          ...controller.workInformation.map((work) => Column(
            children: [
              _buildInfoRow(
                icon: Icons.business,
                label: companyText,
                value: work['Company']?.toString() ?? 'Not provided',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.account_tree,
                label: departmentText,
                value: work['Organization']?.toString() ?? 'Not provided',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: joinText,
                value: work['DateOfJoin']?.toString() ?? 'Not provided',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.badge,
                label: 'Position',
                value: work['PositionName']?.toString() ?? 'Not provided',
              ),
            ],
          )).toList()
        else
          _buildInfoRow(
            icon: Icons.info,
            label: 'Information',
            value: 'No work information available',
          ),
      ],
    );
  }
  
  Widget _buildSkills(HomeController controller) {
    final skillText = controller.profileStaticContents['SkillText'] ?? 'Skills';
    
    return _buildSection(
      title: skillText,
      icon: Icons.psychology,
      children: [
        if (controller.skills.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.skills.map((skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF2196F3).withOpacity(0.3),
                ),
              ),
              child: Text(
                skill['Skill']?.toString() ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2196F3),
                ),
              ),
            )).toList(),
          )
        else
          _buildInfoRow(
            icon: Icons.info,
            label: 'Skills',
            value: 'No skills listed',
          ),
      ],
    );
  }
  
  Widget _buildCertifications(HomeController controller) {
    final certText = controller.profileStaticContents['CertificationsText'] ?? 'Certifications';
    
    return _buildSection(
      title: certText,
      icon: Icons.verified,
      children: [
        if (controller.certifications.isNotEmpty)
          ...controller.certifications.map((cert) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
              ],
            ),
          )).toList()
        else
          _buildInfoRow(
            icon: Icons.info,
            label: 'Certifications',
            value: 'No certifications listed',
          ),
      ],
    );
  }
  
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2196F3),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
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
          color: Colors.grey[600],
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
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                // TODO: Add logout functionality here
                await GetStorage().write('isLoggedIn', false);
                Get.offAllNamed(AppPages.initialLogin);
                print('Logout button tapped');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.logout, size: 20),
              label: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 