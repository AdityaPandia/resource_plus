import 'dart:convert';
import 'dart:io';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class CalendarService {
  static const List<String> _scopes = [
    calendar.CalendarApi.calendarReadonlyScope,
    calendar.CalendarApi.calendarEventsScope,
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
    clientId:
        '494571613065-s24ibflsmpniku44sfa9tkbi2gdk0hj2.apps.googleusercontent.com', // Updated with actual client ID
  );

  http.Client? _client;
  String? _accessToken;
  final GetStorage _storage = GetStorage();

  // Check if user is authenticated
  bool get isAuthenticated => _accessToken != null && _client != null;

  // Initialize the service
  Future<void> initialize() async {
    final storedToken = _storage.read('google_access_token');
    if (storedToken != null) {
      _accessToken = storedToken;
      _client = http.Client();
    }
  }

  // Authenticate with Google using OAuth 2.0
  Future<bool> authenticate() async {
    try {
      // Sign in with Google
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        print('User cancelled sign in');
        return false;
      }

      // Get authentication headers
      final GoogleSignInAuthentication auth = await account.authentication;

      if (auth.accessToken == null) {
        print('No access token received');
        return false;
      }

      // Store the access token
      _accessToken = auth.accessToken;
      await _storage.write('google_access_token', auth.accessToken);
      _client = http.Client();

      return true;
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }

  // Refresh the access token
  Future<void> _refreshToken() async {
    try {
      // Try to sign in silently to refresh the token
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      if (account != null) {
        final GoogleSignInAuthentication auth = await account.authentication;
        if (auth.accessToken != null) {
          _accessToken = auth.accessToken;
          await _storage.write('google_access_token', auth.accessToken);
          _client = http.Client();
        }
      }
    } catch (e) {
      print('Token refresh error: $e');
      await logout();
    }
  }

  // Get user's calendars
  Future<List<calendar.CalendarListEntry>> getCalendars() async {
    try {
      if (!isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final response = await _client!.get(
        Uri.parse(
          'https://www.googleapis.com/calendar/v3/users/me/calendarList',
        ),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        return items
            .map((item) => calendar.CalendarListEntry.fromJson(item))
            .toList();
      } else {
        print('Error getting calendars: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting calendars: $e');
      return [];
    }
  }

  // Get events from a specific calendar
  Future<List<calendar.Event>> getEvents({
    required String calendarId,
    DateTime? startDate,
    DateTime? endDate,
    int maxResults = 50,
  }) async {
    try {
      if (!isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final queryParams = <String, String>{
        'maxResults': maxResults.toString(),
        'singleEvents': 'true',
        'orderBy': 'startTime',
      };

      if (startDate != null) {
        queryParams['timeMin'] = startDate.toUtc().toIso8601String();
      }
      if (endDate != null) {
        queryParams['timeMax'] = endDate.toUtc().toIso8601String();
      }

      final uri = Uri.parse(
        'https://www.googleapis.com/calendar/v3/calendars/$calendarId/events',
      ).replace(queryParameters: queryParams);

      final response = await _client!.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        return items.map((item) => calendar.Event.fromJson(item)).toList();
      } else {
        print('Error getting events: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting events: $e');
      return [];
    }
  }

  // Create a new event
  Future<calendar.Event?> createEvent({
    required String calendarId,
    required String summary,
    required DateTime start,
    required DateTime end,
    String? description,
    String? location,
  }) async {
    try {
      if (!isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final eventData = {
        'summary': summary,
        'description': description,
        'location': location,
        'start': {
          'dateTime': start.toUtc().toIso8601String(),
          'timeZone': 'UTC',
        },
        'end': {'dateTime': end.toUtc().toIso8601String(), 'timeZone': 'UTC'},
      };

      final response = await _client!.post(
        Uri.parse(
          'https://www.googleapis.com/calendar/v3/calendars/$calendarId/events',
        ),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(eventData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return calendar.Event.fromJson(data);
      } else {
        print('Error creating event: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error creating event: $e');
      return null;
    }
  }

  // Update an existing event
  Future<calendar.Event?> updateEvent({
    required String calendarId,
    required String eventId,
    String? summary,
    DateTime? start,
    DateTime? end,
    String? description,
    String? location,
  }) async {
    try {
      if (!isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final eventData = <String, dynamic>{};
      if (summary != null) eventData['summary'] = summary;
      if (description != null) eventData['description'] = description;
      if (location != null) eventData['location'] = location;
      if (start != null) {
        eventData['start'] = {
          'dateTime': start.toUtc().toIso8601String(),
          'timeZone': 'UTC',
        };
      }
      if (end != null) {
        eventData['end'] = {
          'dateTime': end.toUtc().toIso8601String(),
          'timeZone': 'UTC',
        };
      }

      final response = await _client!.put(
        Uri.parse(
          'https://www.googleapis.com/calendar/v3/calendars/$calendarId/events/$eventId',
        ),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(eventData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return calendar.Event.fromJson(data);
      } else {
        print('Error updating event: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error updating event: $e');
      return null;
    }
  }

  // Delete an event
  Future<bool> deleteEvent({
    required String calendarId,
    required String eventId,
  }) async {
    try {
      if (!isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final response = await _client!.delete(
        Uri.parse(
          'https://www.googleapis.com/calendar/v3/calendars/$calendarId/events/$eventId',
        ),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting event: $e');
      return false;
    }
  }

  // Logout and clear stored tokens
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _storage.remove('google_access_token');
      _client?.close();
      _client = null;
      _accessToken = null;
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Get today's events
  Future<List<calendar.Event>> getTodayEvents(String calendarId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await getEvents(
      calendarId: calendarId,
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  // Get events for a specific date range
  Future<List<calendar.Event>> getEventsForDateRange({
    required String calendarId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await getEvents(
      calendarId: calendarId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
