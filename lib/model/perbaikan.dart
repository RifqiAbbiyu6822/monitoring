class Perbaikan {
  final String id;
  final String temuanId;
  final String category;
  final String subcategory;
  final String section;
  final String kmPoint;
  final String lane;
  final String workDescription;
  final String contractor;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final double? progress;
  final List<String> beforePhotos;
  final List<String> progressPhotos;
  final List<String> afterPhotos;
  final List<String>? documentationPhotos;
  final String assignedTo;
  final DateTime createdAt;
  final String createdBy;
  final String? notes;
  final double? cost;

  Perbaikan({
    required this.id,
    required this.temuanId,
    required this.category,
    required this.subcategory,
    required this.section,
    required this.kmPoint,
    required this.lane,
    required this.workDescription,
    required this.contractor,
    required this.status,
    required this.startDate,
    this.endDate,
    this.progress,
    required this.beforePhotos,
    required this.progressPhotos,
    required this.afterPhotos,
    this.documentationPhotos,
    required this.assignedTo,
    required this.createdAt,
    required this.createdBy,
    this.notes,
    this.cost,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'temuanId': temuanId,
      'category': category,
      'subcategory': subcategory,
      'section': section,
      'kmPoint': kmPoint,
      'lane': lane,
      'workDescription': workDescription,
      'contractor': contractor,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'progress': progress,
      'beforePhotos': beforePhotos,
      'progressPhotos': progressPhotos,
      'afterPhotos': afterPhotos,
      'documentationPhotos': documentationPhotos,
      'assignedTo': assignedTo,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'notes': notes,
      'cost': cost,
    };
  }

  factory Perbaikan.fromJson(Map<String, dynamic> json) {
    return Perbaikan(
      id: json['id'],
      temuanId: json['temuanId'],
      category: json['category'],
      subcategory: json['subcategory'],
      section: json['section'],
      kmPoint: json['kmPoint'],
      lane: json['lane'],
      workDescription: json['workDescription'],
      contractor: json['contractor'],
      status: json['status'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate']) 
          : null,
      progress: json['progress']?.toDouble(),
      beforePhotos: List<String>.from(json['beforePhotos']),
      progressPhotos: List<String>.from(json['progressPhotos']),
      afterPhotos: List<String>.from(json['afterPhotos']),
      documentationPhotos: json['documentationPhotos'] != null 
          ? List<String>.from(json['documentationPhotos'])
          : null,
      assignedTo: json['assignedTo'],
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'],
      notes: json['notes'],
      cost: json['cost']?.toDouble(),
    );
  }
}