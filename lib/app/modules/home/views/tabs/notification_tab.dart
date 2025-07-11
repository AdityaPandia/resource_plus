import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class NotificationTab extends StatelessWidget {
  const NotificationTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        if (controller.isNotificationLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            ),
          );
        }
        
        if (controller.hasNotificationError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Notifications',
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
                    controller.notificationErrorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.refreshNotificationData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
            SizedBox(height: 30,),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications,
                    color: const Color(0xFF2196F3),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      controller.notificationStaticContents['HeaderText'] ?? 'Notifications',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  if (controller.notifications.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => controller.updateNotificationReadStatus(0, 1),
                      icon: const Icon(Icons.done_all, size: 18),
                      label: Text(
                        controller.notificationStaticContents['MarkAllText'] ?? 'Mark all as read',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Notifications List
            Expanded(
              child: controller.notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Notifications',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You\'re all caught up!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: controller.fetchNotificationData,
                      color: const Color(0xFF2196F3),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.notifications.length,
                        itemBuilder: (context, index) {
                          final notification = controller.notifications[index];
                          final isRead = notification['ReadStatus'] == 'True';
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  // Mark as read when tapped
                                  if (!isRead) {
                                    controller.updateNotificationReadStatus(
                                      int.tryParse(notification['NotifcnID'].toString()) ?? 0,
                                      1,
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Notification Icon
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: isRead 
                                              ? Colors.grey[200] 
                                              : const Color(0xFF2196F3).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.notifications,
                                          color: isRead 
                                              ? Colors.grey[600] 
                                              : const Color(0xFF2196F3),
                                          size: 24,
                                        ),
                                      ),
                                      
                                      const SizedBox(width: 16),
                                      
                                      // Notification Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    notification['NotifcnTitle'] ?? '',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: isRead 
                                                          ? FontWeight.normal 
                                                          : FontWeight.bold,
                                                      color: isRead 
                                                          ? Colors.grey[700] 
                                                          : const Color(0xFF333333),
                                                    ),
                                                  ),
                                                ),
                                                if (!isRead)
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFF2196F3),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              notification['NotifcnBody'] ?? '',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                                height: 1.4,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              notification['NotifcnDate'] ?? '',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Action Button
                                      if (!isRead)
                                        IconButton(
                                          onPressed: () {
                                            controller.updateNotificationReadStatus(
                                              int.tryParse(notification['NotifcnID'].toString()) ?? 0,
                                              1,
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.check_circle_outline,
                                            color: Color(0xFF2196F3),
                                            size: 20,
                                          ),
                                          tooltip: 'Mark as read',
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }
} 