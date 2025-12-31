import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../../../services/notification_service.dart';
import '../../../../routes/app_routes.dart';

class NotificationTab extends StatelessWidget {
  const NotificationTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final notificationService = NotificationService();

    // Reset notification count when user visits notification tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationService.resetNotificationCount(
        controller.notifications.length,
      );
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Obx(() {
        if (controller.isNotificationLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        if (controller.hasNotificationError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
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
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                    Icons.notifications,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      controller.notificationStaticContents['HeaderText'] ??
                          'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  // Force Check Button
                  IconButton(
                    onPressed: () {
                      controller.forceNotificationCheck();
                      Get.snackbar(
                        'Checking',
                        'Checking for new notifications...',
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                      );
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tooltip: 'Check for new notifications',
                  ),

                  if (controller.notifications.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        _markAllAsRead(controller);
                      },
                      icon: const Icon(Icons.done_all, size: 18),
                      label: Text(
                        controller.notificationStaticContents['MarkAllText'] ??
                            'Mark all as read',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
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
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You\'re all caught up!',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey[500]
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: controller.fetchNotificationData,
                      color: Theme.of(context).colorScheme.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.notifications.length,
                        itemBuilder: (context, index) {
                          final notification = controller.notifications[index];
                          // Check multiple possible formats for read status
                          final readStatusValue =
                              notification['ReadStatus'] ??
                              notification['IsRead'] ??
                              notification['isRead'];
                          final isRead =
                              readStatusValue == 'True' ||
                              readStatusValue == 'true' ||
                              readStatusValue == 1 ||
                              readStatusValue == true;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.grey.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.3),
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
                                onTap: () async {
                                  // Handle notification redirection using BaseUrl + QueryString
                                  final baseUrl =
                                      controller.commonContents['BaseUrl'];
                                  final queryString =
                                      notification['QueryString'];

                                  if (baseUrl != null &&
                                      baseUrl.isNotEmpty &&
                                      queryString != null &&
                                      queryString.toString().isNotEmpty) {
                                    // Combine BaseUrl with QueryString
                                    final fullUrl =
                                        baseUrl + queryString.toString();

                                    try {
                                      // Open in in-app WebView
                                      final notificationTitle =
                                          notification['NotifcnTitle'] ?? 'Notification';
                                      Get.toNamed(
                                        AppRoutes.webview,
                                        parameters: {
                                          'url': fullUrl,
                                          'title': notificationTitle.toString(),
                                        },
                                      );

                                      // Mark as read if not already read
                                      if (!isRead) {
                                        final notificationId =
                                            int.tryParse(
                                              notification['NotifcnID']
                                                  .toString(),
                                            ) ??
                                            0;

                                        // Optimistically update local state immediately
                                        final currentIndex = controller
                                            .notifications
                                            .indexWhere(
                                              (n) =>
                                                  (int.tryParse(
                                                        n['NotifcnID']
                                                            .toString(),
                                                      ) ??
                                                      0) ==
                                                  notificationId,
                                            );
                                        if (currentIndex >= 0) {
                                          controller
                                                  .notifications[currentIndex] =
                                              Map<String, dynamic>.from(
                                                controller
                                                    .notifications[currentIndex],
                                              )..['ReadStatus'] = 'True';
                                        }

                                        // Update backend
                                        controller
                                            .updateNotificationReadStatus(
                                              notificationId,
                                              1,
                                            );
                                      }
                                    } catch (e) {
                                      Get.snackbar(
                                        'Error',
                                        'Failed to open URL: $e',
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    }
                                  } else {
                                    // Fallback: just mark as read if no URL available
                                    if (!isRead) {
                                      final notificationId =
                                          int.tryParse(
                                            notification['NotifcnID']
                                                .toString(),
                                          ) ??
                                          0;

                                      // Optimistically update local state immediately
                                      final currentIndex = controller
                                          .notifications
                                          .indexWhere(
                                            (n) =>
                                                (int.tryParse(
                                                      n['NotifcnID'].toString(),
                                                    ) ??
                                                    0) ==
                                                notificationId,
                                          );
                                      if (currentIndex >= 0) {
                                        controller.notifications[currentIndex] =
                                            Map<String, dynamic>.from(
                                              controller
                                                  .notifications[currentIndex],
                                            )..['ReadStatus'] = 'True';
                                      }

                                      // Update backend
                                      controller.updateNotificationReadStatus(
                                        notificationId,
                                        1,
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Notification Icon
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: isRead
                                              ? (Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Colors.grey[200]
                                                  : Colors.grey[800])
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.notifications,
                                          color: isRead
                                              ? (Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Colors.grey[600]
                                                  : Colors.grey[400])
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          size: 24,
                                        ),
                                      ),

                                      const SizedBox(width: 16),

                                      // Notification Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    notification['NotifcnTitle'] ??
                                                        '',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: isRead
                                                          ? FontWeight.normal
                                                          : FontWeight.bold,
                                                      color: isRead
                                                          ? (Theme.of(
                                                                      context,
                                                                    ).brightness ==
                                                                  Brightness
                                                                      .light
                                                                ? Colors
                                                                      .grey[700]
                                                              : Colors
                                                                  .grey[300])
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .onSurface,
                                                    ),
                                                  ),
                                                ),
                                                if (!isRead)
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
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
                                                color:
                                                    Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.light
                                                    ? Colors.grey[600]
                                                    : Colors.grey[400],
                                                height: 1.4,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              notification['NotifcnDate'] ?? '',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.light
                                                    ? Colors.grey[500]
                                                    : Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Action Button
                                      if (!isRead)
                                        IconButton(
                                          onPressed: () {
                                            final notificationId =
                                                int.tryParse(
                                                  notification['NotifcnID']
                                                      .toString(),
                                                ) ??
                                                0;

                                            // Optimistically update local state immediately
                                            final currentIndex = controller
                                                .notifications
                                                .indexWhere(
                                                  (n) =>
                                                      (int.tryParse(
                                                            n['NotifcnID']
                                                                .toString(),
                                                          ) ??
                                                          0) ==
                                                      notificationId,
                                                );
                                            if (currentIndex >= 0) {
                                              controller
                                                      .notifications[currentIndex] =
                                                  Map<String, dynamic>.from(
                                                      controller
                                                          .notifications[currentIndex],
                                                    )
                                                    ..['ReadStatus'] = 'True'
                                                    ..['IsRead'] = 1
                                                    ..['isRead'] = 1;
                                            }

                                            // Update backend
                                            controller
                                                .updateNotificationReadStatus(
                                                  notificationId,
                                              1,
                                            );
                                          },
                                          icon: Icon(
                                            Icons.check_circle_outline,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
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

  void _markAllAsRead(HomeController controller) async {
    try {
      // Optimistically update local state immediately
      final unreadNotificationIds = <int>[];

      // First, identify all unread notifications and update local state
      for (var i = 0; i < controller.notifications.length; i++) {
        final notification = controller.notifications[i];
        // Use same robust check as UI
        final readStatusValue =
            notification['ReadStatus'] ??
            notification['IsRead'] ??
            notification['isRead'];
        final isRead =
            readStatusValue == 'True' ||
            readStatusValue == 'true' ||
            readStatusValue == 1 ||
            readStatusValue == true;

        if (!isRead) {
          final notificationId =
              int.tryParse(notification['NotifcnID'].toString()) ?? 0;
          if (notificationId > 0) {
            unreadNotificationIds.add(notificationId);
            // Update local state immediately for instant UI feedback
            // Set both possible field names to ensure UI updates correctly
            controller.notifications[i] =
                Map<String, dynamic>.from(notification)
                  ..['ReadStatus'] = 'True'
                  ..['IsRead'] = 1
                  ..['isRead'] = 1;
        }
      }
      }

      // Show success message immediately
      Get.snackbar(
        'Success',
        'All notifications marked as read',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Update backend in background (non-blocking)
      // Make API calls for all unread notifications without refreshing after each
      for (final notificationId in unreadNotificationIds) {
        try {
          await controller.updateNotificationReadStatus(
            notificationId,
            1,
            refreshAfterUpdate: false,
          );
        } catch (e) {
          print('Error updating notification $notificationId: $e');
        }
      }

      // Wait a moment for API to process updates, then refresh to ensure consistency
      await Future.delayed(const Duration(milliseconds: 500));
      await controller.fetchNotificationData();
    } catch (e) {
      // If something fails, refresh from API to restore correct state
      await controller.fetchNotificationData();
      Get.snackbar(
        'Error',
        'Failed to mark notifications as read',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
