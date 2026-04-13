import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../controllers/hr_portal_controller.dart';

class HrPortalView extends GetView<HrPortalController> {
  const HrPortalView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final blue = const Color(0xFF2196F3);
    final green = const Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'attendance_punch'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Camera Preview Frame
            _buildCameraPreview(context, colorScheme),
            const SizedBox(height: 20),

            // Current Time Display
            _buildCurrentTime(context, colorScheme),
            const SizedBox(height: 20),

            // In/Out Buttons
            _buildAttendanceButtons(context, blue, green),
            const SizedBox(height: 24),

            // Current Shift & Coordinates
            _buildShiftAndCoordinates(context, colorScheme),
            const SizedBox(height: 24),

            // Last 5 Punches Section
            _buildLastPunchesSection(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(BuildContext context, ColorScheme colorScheme) {
    return AspectRatio(
      aspectRatio: 16 / 9, // Use standard aspect ratio for container
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Obx(() {
            if (!controller.isCameraPermissionGranted.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 48,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Camera permission required',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (!controller.isCameraInitialized.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Initializing camera...',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            final cameraController = controller.cameraController;
            if (cameraController != null) {
              try {
                // Check if controller is still valid and initialized
                // Access value only once and check both initialized and hasError states
                final cameraValue = cameraController.value;

                if (!cameraValue.isInitialized || cameraValue.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (cameraValue.hasError)
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          )
                        else
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          cameraValue.hasError
                              ? 'Camera error occurred'
                              : 'Initializing camera...',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Get aspect ratio and use it for proper scaling
                final aspectRatio = cameraValue.aspectRatio;

                // Use the camera's actual aspect ratio to prevent stretching
                // Center it within the container
                if (aspectRatio > 0 &&
                    aspectRatio.isFinite &&
                    !aspectRatio.isNaN) {
                  return Center(
                    child: AspectRatio(
                      aspectRatio: aspectRatio,
                      child: CameraPreview(cameraController),
                    ),
                  );
                } else {
                  // Fallback to 16:9 if aspect ratio is invalid
                  return Center(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CameraPreview(cameraController),
                    ),
                  );
                }
              } catch (e) {
                // Handle any errors during camera preview rendering
                debugPrint('Error rendering camera preview: $e');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Camera preview error',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }
            }

            return Center(
              child: Text(
                'Camera not available',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCurrentTime(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time, color: colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Obx(
            () => Text(
              controller.currentTime.value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceButtons(
    BuildContext context,
    Color blue,
    Color green,
  ) {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => ElevatedButton(
              onPressed: controller.isProcessingIn.value ||
                      controller.isProcessingAttendance.value
                  ? null
                  : controller.markAttendanceIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: controller.isProcessingIn.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Obx(
            () => ElevatedButton(
              onPressed: controller.isProcessingOut.value ||
                      controller.isProcessingAttendance.value
                  ? null
                  : controller.markAttendanceOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: controller.isProcessingOut.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Out',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastPunchesSection(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last 5 Punches',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Obx(() {
            if (controller.isLoadingPunches.value) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Loading punches...',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.hasPunchesError.value) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load punches',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.lastPunches.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No punches found',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: controller.lastPunches.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: colorScheme.outline.withOpacity(0.2),
              ),
              itemBuilder: (context, index) {
                final punch = controller.lastPunches[index];
                return _buildPunchItem(punch, colorScheme);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPunchItem(dynamic punch, ColorScheme colorScheme) {
    final isIn = punch.type == 'In';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isIn
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIn ? Icons.login : Icons.logout,
              color: isIn ? const Color(0xFF4CAF50) : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  punch.type,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${punch.date} • ${punch.time}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: punch.status == 'Success'
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              punch.status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: punch.status == 'Success'
                    ? const Color(0xFF4CAF50)
                    : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftAndCoordinates(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Shift
          Row(
            children: [
              Icon(Icons.schedule, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Current Shift:',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => Text(
                  controller.currentShift.value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),
          const SizedBox(height: 16),
          // Current Coordinates
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Coordinates:',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        controller.currentCoordinates.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                          fontFamily: 'monospace',
                        ),
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
}
