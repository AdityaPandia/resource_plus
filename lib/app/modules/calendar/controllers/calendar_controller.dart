import 'package:get/get.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import '../../../services/calendar_service.dart';

class CalendarController extends GetxController {
  final CalendarService _calendarService = CalendarService();

  // Observable variables
  final RxBool isAuthenticated = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isConnecting = false.obs;
  final RxString errorMessage = ''.obs;

  // Calendar data
  final RxList<calendar.CalendarListEntry> calendars =
      <calendar.CalendarListEntry>[].obs;
  final RxList<calendar.Event> events = <calendar.Event>[].obs;
  final RxList<calendar.Event> todayEvents = <calendar.Event>[].obs;

  // Selected calendar
  final RxString selectedCalendarId = 'primary'.obs;

  // Calendar view state
  final Rx<DateTime> focusedDate = DateTime.now().obs;
  final Rx<DateTime?> selectedDate = DateTime.now().obs;
  final Rx<DateTime> firstDate =
      DateTime.now().subtract(const Duration(days: 365)).obs;
  final Rx<DateTime> lastDate =
      DateTime.now().add(const Duration(days: 365)).obs;

  @override
  void onInit() {
    super.onInit();
    initializeCalendar();
  }

  // Initialize calendar service
  Future<void> initializeCalendar() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _calendarService.initialize();
      isAuthenticated.value = _calendarService.isAuthenticated;

      if (isAuthenticated.value) {
        await loadCalendars();
        await loadTodayEvents();
      }
    } catch (e) {
      errorMessage.value = 'Failed to initialize calendar: ${e.toString()}';
      print('Calendar initialization error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Connect to Google Calendar
  Future<bool> connectToGoogleCalendar() async {
    try {
      isConnecting.value = true;
      errorMessage.value = '';

      final success = await _calendarService.authenticate();
      isAuthenticated.value = success;

      if (success) {
        await loadCalendars();
        await loadTodayEvents();
        Get.snackbar(
          'Success',
          'Successfully connected to Google Calendar',
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      } else {
        errorMessage.value = 'Failed to authenticate with Google Calendar';
        Get.snackbar(
          'Error',
          'Failed to connect to Google Calendar',
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }

      return success;
    } catch (e) {
      errorMessage.value = 'Connection error: ${e.toString()}';
      print('Google Calendar connection error: $e');
      return false;
    } finally {
      isConnecting.value = false;
    }
  }

  // Load user's calendars
  Future<void> loadCalendars() async {
    try {
      if (!isAuthenticated.value) return;

      final calendarList = await _calendarService.getCalendars();
      calendars.value = calendarList;

      // Set primary calendar as default if available
      if (calendarList.isNotEmpty) {
        final primaryCalendar = calendarList.firstWhere(
          (cal) => cal.primary == true,
          orElse: () => calendarList.first,
        );
        selectedCalendarId.value = primaryCalendar.id ?? 'primary';
      }
    } catch (e) {
      print('Error loading calendars: $e');
      errorMessage.value = 'Failed to load calendars';
    }
  }

  // Load events for a specific date range
  Future<void> loadEvents({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (!isAuthenticated.value) return;

      final eventList = await _calendarService.getEvents(
        calendarId: selectedCalendarId.value,
        startDate: startDate,
        endDate: endDate,
      );
      events.value = eventList;
    } catch (e) {
      print('Error loading events: $e');
      errorMessage.value = 'Failed to load events';
    }
  }

  // Load today's events
  Future<void> loadTodayEvents() async {
    try {
      if (!isAuthenticated.value) return;

      final todayEventList =
          await _calendarService.getTodayEvents(selectedCalendarId.value);
      todayEvents.value = todayEventList;
    } catch (e) {
      print('Error loading today\'s events: $e');
      errorMessage.value = 'Failed to load today\'s events';
    }
  }

  // Load events for selected date
  Future<void> loadEventsForDate(DateTime date) async {
    try {
      if (!isAuthenticated.value) return;

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final eventList = await _calendarService.getEvents(
        calendarId: selectedCalendarId.value,
        startDate: startOfDay,
        endDate: endOfDay,
      );
      events.value = eventList;
    } catch (e) {
      print('Error loading events for date: $e');
      errorMessage.value = 'Failed to load events for selected date';
    }
  }

  // Change selected calendar
  Future<void> changeCalendar(String calendarId) async {
    selectedCalendarId.value = calendarId;
    await loadTodayEvents();
    await loadEventsForDate(selectedDate.value ?? DateTime.now());
  }

  // Create a new event
  Future<bool> createEvent({
    required String summary,
    required DateTime start,
    required DateTime end,
    String? description,
    String? location,
  }) async {
    try {
      if (!isAuthenticated.value) return false;

      final event = await _calendarService.createEvent(
        calendarId: selectedCalendarId.value,
        summary: summary,
        start: start,
        end: end,
        description: description,
        location: location,
      );

      if (event != null) {
        await loadTodayEvents();
        await loadEventsForDate(selectedDate.value ?? DateTime.now());
        Get.snackbar(
          'Success',
          'Event created successfully',
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to create event',
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return false;
      }
    } catch (e) {
      print('Error creating event: $e');
      errorMessage.value = 'Failed to create event';
      return false;
    }
  }

  // Update an existing event
  Future<bool> updateEvent({
    required String eventId,
    String? summary,
    DateTime? start,
    DateTime? end,
    String? description,
    String? location,
  }) async {
    try {
      if (!isAuthenticated.value) return false;

      final event = await _calendarService.updateEvent(
        calendarId: selectedCalendarId.value,
        eventId: eventId,
        summary: summary,
        start: start,
        end: end,
        description: description,
        location: location,
      );

      if (event != null) {
        await loadTodayEvents();
        await loadEventsForDate(selectedDate.value ?? DateTime.now());
        Get.snackbar(
          'Success',
          'Event updated successfully',
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to update event',
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return false;
      }
    } catch (e) {
      print('Error updating event: $e');
      errorMessage.value = 'Failed to update event';
      return false;
    }
  }

  // Delete an event
  Future<bool> deleteEvent(String eventId) async {
    try {
      if (!isAuthenticated.value) return false;

      final success = await _calendarService.deleteEvent(
        calendarId: selectedCalendarId.value,
        eventId: eventId,
      );

      if (success) {
        await loadTodayEvents();
        await loadEventsForDate(selectedDate.value ?? DateTime.now());
        Get.snackbar(
          'Success',
          'Event deleted successfully',
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete event',
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return false;
      }
    } catch (e) {
      print('Error deleting event: $e');
      errorMessage.value = 'Failed to delete event';
      return false;
    }
  }

  // Disconnect from Google Calendar
  Future<void> disconnect() async {
    try {
      await _calendarService.logout();
      isAuthenticated.value = false;
      calendars.clear();
      events.clear();
      todayEvents.clear();
      selectedCalendarId.value = 'primary';

      Get.snackbar(
        'Success',
        'Disconnected from Google Calendar',
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      print('Error disconnecting: $e');
      errorMessage.value = 'Failed to disconnect';
    }
  }

  // Update focused date
  void updateFocusedDate(DateTime date) {
    focusedDate.value = date;
  }

  // Update selected date
  void updateSelectedDate(DateTime? date) {
    selectedDate.value = date;
    if (date != null) {
      loadEventsForDate(date);
    }
  }

  // Get events for a specific date
  List<calendar.Event> getEventsForDate(DateTime date) {
    return events.where((event) {
      final eventStart = event.start?.dateTime ?? event.start?.date;
      if (eventStart == null) return false;

      final eventDate = eventStart is DateTime
          ? DateTime(eventStart.year, eventStart.month, eventStart.day)
          : DateTime.parse(eventStart.toString());

      final targetDate = DateTime(date.year, date.month, date.day);
      return eventDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  // Check if a date has events
  bool hasEventsOnDate(DateTime date) {
    return getEventsForDate(date).isNotEmpty;
  }

  // Format event time
  String formatEventTime(calendar.Event event) {
    final start = event.start?.dateTime ?? event.start?.date;
    final end = event.end?.dateTime ?? event.end?.date;

    if (start == null) return '';

    if (start is DateTime) {
      final startTime =
          '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
      if (end != null && end is DateTime) {
        final endTime =
            '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
        return '$startTime - $endTime';
      }
      return startTime;
    }

    return 'All day';
  }
}
