import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String title;
  final String locationName;
  final String date;
  final String category;
  final String time;
  final String address;
  final String description;
  final String? imageUrl;
  bool isSaved;
  bool hasReminder;
  final List<double> location;

  Event(
    this.title,
    this.locationName,
    this.date, {
    required this.category,
    required this.time,
    required this.address,
    required this.description,
    this.imageUrl,
    this.isSaved = false,
    this.hasReminder = false,
    required this.location,
  });

  // Factory constructor to create an Event from a Firestore document
  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Event(
      data['title'] ?? '',
      data['location'] ?? '',
      data['date'] ?? '',
      category: data['category'] ?? 'Other',
      description: data['description'] ?? '',
      time: data['time'] ?? '',
      address: data['address'] ?? '',
      imageUrl: data['imageUrl'],
      isSaved: data['isSaved'] ?? false,
      hasReminder: data['hasReminder'] ?? false,
      location: (data['location_coords'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [0.0, 0.0],
    );
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      json['title'] as String,
      json['location'] as String,
      json['date'] as String,
      category: json['category'] as String,
      time: json['time'] as String,
      address: json['address'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      location: (json['location_coords'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [0.0, 0.0],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'location': locationName,
      'date': date,
      'category': category,
      'time': time,
      'address': address,
      'description': description,
      'imageUrl': imageUrl,
      'location_coords': location,
    };
  }

  String describe() {
    return "$title at $locationName on $date";
  }
}

class EventCategories {
  static const String music = 'Music';
  static const String tech = 'Tech';
  static const String food = 'Food';
  static const String art = 'Art';
  static const String sports = 'Sports';
  static const String other = 'Other';

  static List<String> all = [
    music,
    tech,
    food,
    art,
    sports,
    other,
  ];
}
