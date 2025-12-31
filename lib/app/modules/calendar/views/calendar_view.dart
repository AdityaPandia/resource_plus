import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import '../controllers/calendar_controller.dart';
import '../../../controllers/language_controller.dart';

class CalendarView extends GetView<CalendarController> {
  const CalendarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'error'.tr,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.initializeCalendar,
                    child: Text('retry'.tr),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header with connection status
              _buildHeader(context),

              // Calendar widget
              Expanded(child: _buildCalendar(context)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'calendar'.tr,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  controller.isAuthenticated.value
                      ? 'connected_to_google_calendar'.tr
                      : 'not_connected_to_google_calendar'.tr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: controller.isAuthenticated.value
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          if (!controller.isAuthenticated.value)
            ElevatedButton.icon(
              onPressed: controller.isConnecting.value
                  ? null
                  : controller.connectToGoogleCalendar,
              icon: controller.isConnecting.value
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Icon(Icons.link),
              label: Text(
                controller.isConnecting.value ? 'connecting'.tr : 'connect'.tr,
              ),
            ),
          if (controller.isAuthenticated.value)
            IconButton(
              onPressed: controller.disconnect,
              icon: const Icon(Icons.link_off),
              tooltip: 'disconnect'.tr,
            ),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final currentLocale =
        languageController.currentLanguage.value == LanguageController.english
        ? 'en_US'
        : 'ar_SA';

    return Column(
      children: [
        // Calendar widget
        TableCalendar<calendar.Event>(
          locale: currentLocale,
          firstDay: controller.firstDate.value,
          lastDay: controller.lastDate.value,
          focusedDay: controller.focusedDate.value,
          selectedDayPredicate: (day) {
            return isSameDay(controller.selectedDate.value, day);
          },
          calendarFormat: CalendarFormat.month,
          eventLoader: controller.getEventsForDate,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
            holidayTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          onDaySelected: (selectedDay, focusedDay) {
            controller.updateSelectedDate(selectedDay);
            controller.updateFocusedDate(focusedDay);
          },
          onPageChanged: (focusedDay) {
            controller.updateFocusedDate(focusedDay);
          },
        ),

        const Divider(),

        // Events list for selected date
        Expanded(child: _buildEventsList(context)),
      ],
    );
  }

  Widget _buildEventsList(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final currentLocaleString =
        languageController.currentLanguage.value == LanguageController.english
        ? 'en_US'
        : 'ar_SA';

    final selectedDate = controller.selectedDate.value;
    if (selectedDate == null) {
      return Center(
        child: Text(
          'select_date_to_view_events'.tr,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    final events = controller.getEventsForDate(selectedDate);

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '${'no_events_for'.tr} ${DateFormat.yMMMd(currentLocaleString).format(selectedDate)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (controller.isAuthenticated.value) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddEventDialog(context, selectedDate),
                icon: const Icon(Icons.add),
                label: Text('add_event'.tr),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(context, event);
      },
    );
  }

  Widget _buildEventCard(BuildContext context, calendar.Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.event,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          event.summary ?? 'untitled_event'.tr,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.description != null) ...[
              const SizedBox(height: 4),
              Text(
                event.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              controller.formatEventTime(event),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (event.location != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location!,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: controller.isAuthenticated.value
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditEventDialog(context, event);
                  } else if (value == 'delete') {
                    _showDeleteEventDialog(context, event);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit),
                        const SizedBox(width: 8),
                        Text('edit'.tr),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete),
                        const SizedBox(width: 8),
                        Text('delete'.tr),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, DateTime selectedDate) {
    final languageController = Get.find<LanguageController>();
    final currentLocaleString =
        languageController.currentLanguage.value == LanguageController.english
        ? 'en_US'
        : 'ar_SA';

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    DateTime startTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      9,
      0,
    );
    DateTime endTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      10,
      0,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('add_event'.tr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'event_title'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'description_optional'.tr,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'location_optional'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${'start'.tr}: ${DateFormat('HH:mm', currentLocaleString).format(startTime)}',
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${'end'.tr}: ${DateFormat('HH:mm', currentLocaleString).format(endTime)}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                final success = await controller.createEvent(
                  summary: titleController.text,
                  start: startTime,
                  end: endTime,
                  description: descriptionController.text.isNotEmpty
                      ? descriptionController.text
                      : null,
                  location: locationController.text.isNotEmpty
                      ? locationController.text
                      : null,
                );
                if (success) {
                  Navigator.of(context).pop();
                }
              }
            },
            child: Text('add'.tr),
          ),
        ],
      ),
    );
  }

  void _showEditEventDialog(BuildContext context, calendar.Event event) {
    // Implementation for editing events
    // Similar to add dialog but with pre-filled values
  }

  void _showDeleteEventDialog(BuildContext context, calendar.Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_event'.tr),
        content: Text('${'are_you_sure_delete'.tr} "${event.summary}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              if (event.id != null) {
                final success = await controller.deleteEvent(event.id!);
                if (success) {
                  Navigator.of(context).pop();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }
}
