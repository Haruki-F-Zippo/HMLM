// lib/models/teach_place.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TeachPlace {
  final String ownerUserId;
  final String placeName;
  final String description;
  final double lat;
  final double lng;
  final int densityScore;
  final int distanceScore;
  final String imageUrl;
  final String imagePath;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  TeachPlace({
    required this.ownerUserId,
    required this.placeName,
    required this.description,
    required this.lat,
    required this.lng,
    required this.densityScore,
    required this.distanceScore,
    required this.imageUrl,
    required this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerUserId': ownerUserId,
      'placeName': placeName,
      'description': description,
      'lat': lat,
      'lng': lng,
      'densityScore': densityScore,
      'distanceScore': distanceScore,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory TeachPlace.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeachPlace(
      ownerUserId: data['ownerUserId'] as String,
      placeName: data['placeName'] as String,
      description: data['description'] as String,
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      densityScore: data['densityScore'] as int,
      distanceScore: data['distanceScore'] as int,
      imageUrl: data['imageUrl'] as String,
      imagePath: data['imagePath'] as String,
      createdAt: data['createdAt'] as Timestamp,
      updatedAt: data['updatedAt'] as Timestamp,
    );
  }
}
