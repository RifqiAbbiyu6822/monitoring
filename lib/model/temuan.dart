class Temuan {
  final String id;
  final String category;
  final String subcategory;
  final String section;
  final String kmPoint;
  final String lane;
  final String description;
  final String priority;
  final String status;
  final double latitude;
  final double longitude;
  final List<String> photos;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final String? notes;

  Temuan({
    required this.id,
    required this.category,
    required this.subcategory,
    required this.section,
    required this.kmPoint,
    required this.lane,
    required this.description,
    required this.priority,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.photos,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'subcategory': subcategory,
      'section': section,
      'kmPoint': kmPoint,
      'lane': lane,
      'description': description,
      'priority': priority,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'photos': photos,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
      'notes': notes,
    };
  }

  factory Temuan.fromJson(Map<String, dynamic> json) {
    return Temuan(
      id: json['id'],
      category: json['category'],
      subcategory: json['subcategory'],
      section: json['section'],
      kmPoint: json['kmPoint'],
      lane: json['lane'],
      description: json['description'],
      priority: json['priority'],
      status: json['status'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      photos: List<String>.from(json['photos']),
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'],
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      updatedBy: json['updatedBy'],
      notes: json['notes'],
    );
  }
}