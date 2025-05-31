import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../Event.dart';
import 'package:intl/intl.dart';

class EventService {
  static const String _baseUrl = 'https://api.predicthq.com/v1/events/';
  static const String _apiKey = 'bRxEv09QtITEioTXEA2KqXZMSE8iRWYvP37-gIMX';

  Future<List<Event>> fetchEvents() async {
    try {
      // Default to Nadiad, Gujarat coordinates
      const LatLng defaultLocation = LatLng(22.6917, 72.8634);

      final queryParams = {
        'location_around.origin':
            '${defaultLocation.latitude},${defaultLocation.longitude}',
        'location_around.radius': '40km',
        'sort': 'rank',
        'limit': '100',
        'active.gte': DateTime.now().toIso8601String(),
        'active.lte':
            DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      };

      print('Fetching events with params: $queryParams');

      final response = await http.get(
        Uri.parse(_baseUrl).replace(queryParameters: queryParams),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json',
        },
      );

      print('API Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        print('Number of events found: ${results.length}');

        try {
          List<Event> events = results.map((json) {
            // Safely handle location data
            String location = 'Unknown Location';
            if (json['place_hierarchies'] != null &&
                json['place_hierarchies'].isNotEmpty) {
              location = json['place_hierarchies'][0] ?? 'Unknown Location';
            } else if (json['country'] != null) {
              location = json['country'];
            }

            final startDate = json['start'] != null
                ? DateTime.parse(json['start']).toLocal()
                : DateTime.now();

            return Event(
              json['title'] ?? 'Untitled Event',
              location,
              DateFormat('yyyy-MM-dd').format(startDate),
              category: json['category'] ?? 'Other',
              time: DateFormat('HH:mm').format(startDate),
              address: json['address'] ?? 'Address not specified',
              description: json['description'] ?? 'No description available',
              imageUrl: json['entities']?[0]?['images']?[0]?['url'],
              location: json['location'] is List
                  ? (json['location'] as List)
                      .map((e) => (e as num).toDouble())
                      .toList()
                  : [0.0, 0.0],
            );
          }).toList();

          if (events.isNotEmpty) {
            return events;
          }
        } catch (e) {
          print('Error parsing events: $e');
        }
      }

      // Return sample events if API call fails or no events found
      return _getSampleEvents();
    } catch (e, stackTrace) {
      print('Error fetching events: $e');
      print('Stack trace: $stackTrace');
      // Return sample events on error
      return _getSampleEvents();
    }
  }

  // Helper method to get sample events
  List<Event> _getSampleEvents() {
    final now = DateTime.now();
    return [
      Event(
        'Nadiad Sardar Patel Statue Event',
        'Sardar Patel Statue',
        DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 3))),
        category: 'Culture',
        time: '10:00',
        address: 'Sardar Patel Statue, Nadiad, Gujarat',
        description:
            'A cultural event at the iconic Sardar Patel Statue in Nadiad.',
        imageUrl:
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
        location: [72.8722, 22.6916], // Sardar Patel Statue, Nadiad
      ),
      Event(
        'Anand Amul Dairy Tour',
        'Amul Dairy',
        DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 7))),
        category: 'Food',
        time: '11:00',
        address: 'Amul Dairy, Anand, Gujarat',
        description:
            'A guided tour and tasting event at the famous Amul Dairy.',
        imageUrl:
            'https://images.unsplash.com/photo-1519125323398-675f0ddb6308',
        location: [72.9510, 22.5560], // Amul Dairy, Anand
      ),
      Event(
        'Changa Charotar University Fest',
        'Charotar University of Science and Technology',
        DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 10))),
        category: 'Education',
        time: '09:00',
        address: 'CHARUSAT Campus, Changa, Gujarat',
        description: 'Annual university fest with workshops, music, and food.',
        imageUrl:
            'https://images.unsplash.com/photo-1464983953574-0892a716854b',
        location: [72.8200, 22.6000], // CHARUSAT, Changa
      ),
      Event(
        'Vadtal Swaminarayan Temple Fair',
        'Swaminarayan Temple',
        DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 14))),
        category: 'Religion',
        time: '08:00',
        address: 'Swaminarayan Mandir, Vadtal, Gujarat',
        description:
            'A religious fair at the historic Swaminarayan Temple in Vadtal.',
        imageUrl:
            'https://images.unsplash.com/photo-1502082553048-f009c37129b9',
        location: [72.7468, 22.6006], // Swaminarayan Mandir, Vadtal
      ),
      Event(
        'Sardar Patel University Seminar',
        'Sardar Patel University',
        DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 5))),
        category: 'Education',
        time: '13:00',
        address: 'Sardar Patel University, Vallabh Vidyanagar, Gujarat',
        description: 'A seminar on innovation and research at SPU.',
        imageUrl:
            'https://images.unsplash.com/photo-1465101046530-73398c7f28ca',
        location: [
          72.9294,
          22.5458
        ], // Sardar Patel University, Vallabh Vidyanagar
      ),
      Event(
        'Shree Santram Mandir Music Night',
        'Santram Mandir',
        DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 8))),
        category: 'Music',
        time: '19:00',
        address: 'Santram Mandir, Nadiad, Gujarat',
        description: 'A devotional music night at Santram Mandir.',
        imageUrl:
            'https://images.unsplash.com/photo-1465101178521-c1a9136a3b41',
        location: [72.8647, 22.6919], // Santram Mandir, Nadiad
      ),
    ];
  }

  Future<List<Event>> searchEvents(String query) async {
    try {
      const LatLng defaultLocation = LatLng(22.6917, 72.8634);

      final queryParams = {
        'location_around.origin':
            '${defaultLocation.latitude},${defaultLocation.longitude}',
        'location_around.radius': '40km',
        'sort': 'rank',
        'limit': '100',
        'q': query,
        'active.gte': DateTime.now().toIso8601String(),
        'active.lte':
            DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      };

      print('Searching events with params: $queryParams');

      final response = await http.get(
        Uri.parse(_baseUrl).replace(queryParameters: queryParams),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json',
        },
      );

      print('Search API Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        print('Number of search results: ${results.length}');

        List<Event> events = results.map((json) {
          String location;
          if (json['location'] != null && json['location'] is List) {
            List<dynamic> locationList = json['location'];
            location = locationList.isNotEmpty
                ? locationList[0].toString()
                : (json['country'] ?? 'Unknown Location');
          } else {
            location = json['country'] ?? 'Unknown Location';
          }

          final startDate = json['start'] != null
              ? DateTime.parse(json['start']).toLocal()
              : DateTime.now();

          return Event(
            json['title'] ?? 'Untitled Event',
            location,
            DateFormat('yyyy-MM-dd').format(startDate),
            category: json['category'] ?? 'Other',
            time: DateFormat('HH:mm').format(startDate),
            address: json['address'] ?? 'Address not specified',
            description: json['description'] ?? 'No description available',
            imageUrl: json['entities']?[0]?['images']?[0]?['url'],
            location: json['location'] is List
                ? (json['location'] as List)
                    .map((e) => (e as num).toDouble())
                    .toList()
                : [0.0, 0.0],
          );
        }).toList();

        // If no events found from API, filter sample events
        if (events.isEmpty) {
          return _getSampleEvents()
              .where((event) =>
                  event.title.toLowerCase().contains(query.toLowerCase()) ||
                  event.description
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  event.category.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }

        return events;
      } else {
        print('Search API Error: ${response.statusCode} - ${response.body}');
        // Return filtered sample events on API error
        return _getSampleEvents()
            .where((event) =>
                event.title.toLowerCase().contains(query.toLowerCase()) ||
                event.description.toLowerCase().contains(query.toLowerCase()) ||
                event.category.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    } catch (e, stackTrace) {
      print('Error searching events: $e');
      print('Stack trace: $stackTrace');
      // Return filtered sample events on error
      return _getSampleEvents()
          .where((event) =>
              event.title.toLowerCase().contains(query.toLowerCase()) ||
              event.description.toLowerCase().contains(query.toLowerCase()) ||
              event.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<List<Event>> filterEvents({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String? timeRange,
  }) async {
    try {
      const LatLng defaultLocation = LatLng(22.6917, 72.8634);

      final queryParams = {
        'location_around.origin':
            '${defaultLocation.latitude},${defaultLocation.longitude}',
        'location_around.radius': '40km',
        'sort': 'rank',
        'limit': '100',
        'active.gte': (startDate ?? DateTime.now()).toIso8601String(),
        'active.lte': (endDate ?? DateTime.now().add(const Duration(days: 30)))
            .toIso8601String(),
      };

      if (category != null) {
        queryParams['category'] = category.toLowerCase();
      }

      print('Filtering events with params: $queryParams');

      final response = await http.get(
        Uri.parse(_baseUrl).replace(queryParameters: queryParams),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json',
        },
      );

      print('Filter API Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        print('Number of filtered results: ${results.length}');

        List<Event> events = results.map((json) {
          String location;
          if (json['location'] != null && json['location'] is List) {
            List<dynamic> locationList = json['location'];
            location = locationList.isNotEmpty
                ? locationList[0].toString()
                : (json['country'] ?? 'Unknown Location');
          } else {
            location = json['country'] ?? 'Unknown Location';
          }

          final eventStartDate = json['start'] != null
              ? DateTime.parse(json['start']).toLocal()
              : DateTime.now();

          return Event(
            json['title'] ?? 'Untitled Event',
            location,
            DateFormat('yyyy-MM-dd').format(eventStartDate),
            category: json['category'] ?? 'Other',
            time: DateFormat('HH:mm').format(eventStartDate),
            address: json['address'] ?? 'Address not specified',
            description: json['description'] ?? 'No description available',
            imageUrl: json['entities']?[0]?['images']?[0]?['url'],
            location: json['location'] is List
                ? (json['location'] as List)
                    .map((e) => (e as num).toDouble())
                    .toList()
                : [0.0, 0.0],
          );
        }).toList();

        // If no events found from API, filter sample events
        if (events.isEmpty) {
          return _filterSampleEvents(
              category: category,
              startDate: startDate,
              endDate: endDate,
              timeRange: timeRange);
        }

        return events;
      } else {
        print('Filter API Error: ${response.statusCode} - ${response.body}');
        // Return filtered sample events on API error
        return _filterSampleEvents(
            category: category,
            startDate: startDate,
            endDate: endDate,
            timeRange: timeRange);
      }
    } catch (e, stackTrace) {
      print('Error filtering events: $e');
      print('Stack trace: $stackTrace');
      // Return filtered sample events on error
      return _filterSampleEvents(
          category: category,
          startDate: startDate,
          endDate: endDate,
          timeRange: timeRange);
    }
  }

  List<Event> _filterSampleEvents({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String? timeRange,
  }) {
    List<Event> events = _getSampleEvents();

    if (category != null) {
      events = events
          .where(
              (event) => event.category.toLowerCase() == category.toLowerCase())
          .toList();
    }

    if (startDate != null) {
      events = events.where((event) {
        final eventDate = DateFormat('yyyy-MM-dd').parse(event.date);
        return eventDate.isAfter(startDate.subtract(const Duration(days: 1)));
      }).toList();
    }

    if (endDate != null) {
      events = events.where((event) {
        final eventDate = DateFormat('yyyy-MM-dd').parse(event.date);
        return eventDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    }

    if (timeRange != null && timeRange != 'All Day') {
      events = events.where((event) {
        final time = int.parse(event.time.split(':')[0]);
        switch (timeRange) {
          case 'Morning (6AM-12PM)':
            return time >= 6 && time < 12;
          case 'Afternoon (12PM-5PM)':
            return time >= 12 && time < 17;
          case 'Evening (5PM-12AM)':
            return time >= 17 || time < 6;
          default:
            return true;
        }
      }).toList();
    }

    return events;
  }
}
