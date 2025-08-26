// lib/services/perbaikan_progress_service.dart - Progress Tracking Service

// Progress Photo Item class
class ProgressPhotoItem {
  final String photoPath;
  final double progress;
  final String description;
  final DateTime timestamp;
  final String? notes;

  ProgressPhotoItem({
    required this.photoPath,
    required this.progress,
    required this.description,
    required this.timestamp,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'photoPath': photoPath,
      'progress': progress,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  factory ProgressPhotoItem.fromJson(Map<String, dynamic> json) {
    return ProgressPhotoItem(
      photoPath: json['photoPath'] ?? '',
      progress: json['progress']?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
    );
  }
}

class PerbaikanProgressService {
  
  // Save progress update with photo
  static Future<void> saveProgressUpdate({
    required String perbaikanId,
    required double progress,
    required String description,
    required List<String> photos,
    String? notes,
  }) async {
    final progressItem = ProgressPhotoItem(
      photoPath: photos.isNotEmpty ? photos.first : '',
      progress: progress,
      description: description,
      timestamp: DateTime.now(),
      notes: notes,
    );
    
    // In a real app, this would save to database
    // For now, we'll use the existing local storage
    final existingProgress = await getProgressHistory(perbaikanId);
    existingProgress.add(progressItem);
    
    // Save to local storage (implementation would depend on your storage solution)
    await _saveToStorage(perbaikanId, existingProgress);
  }
  
  // Get progress history for a perbaikan
  static Future<List<ProgressPhotoItem>> getProgressHistory(String perbaikanId) async {
    // Implementation would retrieve from your database
    return [];
  }
  
  // Private helper to save to storage
  static Future<void> _saveToStorage(String perbaikanId, List<ProgressPhotoItem> progress) async {
    // Implementation depends on your storage solution
  }
  
  // Get latest progress percentage
  static Future<double> getLatestProgress(String perbaikanId) async {
    final history = await getProgressHistory(perbaikanId);
    if (history.isEmpty) return 0.0;
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return history.first.progress;
  }
  
  // Generate progress milestones
  static List<double> generateMilestones() {
    return [0, 10, 25, 50, 75, 90, 100];
  }
  
  // Get progress status text
  static String getProgressStatusText(double progress) {
    if (progress == 0) return 'Belum dimulai';
    if (progress <= 25) return 'Tahap awal';
    if (progress <= 50) return 'Setengah jalan';
    if (progress <= 75) return 'Hampir selesai';
    if (progress < 100) return 'Finalisasi';
    return 'Selesai';
  }
}