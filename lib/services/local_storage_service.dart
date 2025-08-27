// lib/services/local_storage_service.dart - Enhanced with better error handling and loading states
import 'package:flutter/material.dart';
import '../model/temuan.dart';
import '../model/perbaikan.dart';
import 'database_service.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  final DatabaseService _databaseService = DatabaseService();
  
  // Cache for better performance
  List<Temuan>? _temuanCache;
  List<Perbaikan>? _perbaikanCache;
  DateTime? _lastCacheUpdate;
  
  // Cache validity duration
  static const Duration _cacheValidityDuration = Duration(minutes: 5);

  // Helper method to check cache validity
  bool _isCacheValid() {
    return _lastCacheUpdate != null &&
           DateTime.now().difference(_lastCacheUpdate!) < _cacheValidityDuration;
  }

  // Clear cache when data changes
  void _clearCache() {
    _temuanCache = null;
    _perbaikanCache = null;
    _lastCacheUpdate = null;
  }

  // ==================== TEMUAN OPERATIONS ====================

  Future<List<Temuan>> getAllTemuan({bool forceRefresh = false}) async {
    try {
      // Return cached data if valid and not forcing refresh
      if (!forceRefresh && _isCacheValid() && _temuanCache != null) {
        return _temuanCache!;
      }

      final temuan = await _databaseService.getAllTemuan();
      
      // Update cache
      _temuanCache = temuan;
      _lastCacheUpdate = DateTime.now();
      
      return temuan;
    } catch (e) {
      print('Error getting all temuan: $e');
      // Return cached data if available, otherwise empty list
      return _temuanCache ?? [];
    }
  }

  Future<Temuan?> getTemuanById(String id) async {
    try {
      // First check cache
      if (_temuanCache != null) {
        final cachedTemuan = _temuanCache!.where((t) => t.id == id).firstOrNull;
        if (cachedTemuan != null) {
          return cachedTemuan;
        }
      }
      
      return await _databaseService.getTemuanById(id);
    } catch (e) {
      print('Error getting temuan by id $id: $e');
      return null;
    }
  }

  Future<Temuan> addTemuan(Map<String, dynamic> temuanData) async {
    try {
      final temuan = await _databaseService.addTemuan(temuanData);
      _clearCache(); // Clear cache after adding
      return temuan;
    } catch (e) {
      print('Error adding temuan: $e');
      _clearCache(); // Clear cache on error to ensure consistency
      throw Exception('Gagal menambah temuan: ${e.toString()}');
    }
  }

  Future<Temuan> updateTemuan(String id, Map<String, dynamic> updateData) async {
    try {
      final temuan = await _databaseService.updateTemuan(id, updateData);
      _clearCache(); // Clear cache after updating
      return temuan;
    } catch (e) {
      print('Error updating temuan $id: $e');
      _clearCache(); // Clear cache on error to ensure consistency
      throw Exception('Gagal memperbarui temuan: ${e.toString()}');
    }
  }

  Future<void> deleteTemuan(String id) async {
    try {
      await _databaseService.deleteTemuan(id);
      _clearCache(); // Clear cache after deleting
    } catch (e) {
      print('Error deleting temuan $id: $e');
      throw Exception('Gagal menghapus temuan: ${e.toString()}');
    }
  }

  Future<List<Temuan>> searchTemuan({
    String? query,
    String? category,
    String? status,
    String? priority,
    String? section,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _databaseService.searchTemuan(
        query: query,
        category: category,
        status: status,
        priority: priority,
        section: section,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      print('Error searching temuan: $e');
      return [];
    }
  }

  // ==================== PERBAIKAN OPERATIONS ====================

  Future<List<Perbaikan>> getAllPerbaikan({bool forceRefresh = false}) async {
    try {
      // Return cached data if valid and not forcing refresh
      if (!forceRefresh && _isCacheValid() && _perbaikanCache != null) {
        return _perbaikanCache!;
      }

      final perbaikan = await _databaseService.getAllPerbaikan();
      
      // Update cache
      _perbaikanCache = perbaikan;
      _lastCacheUpdate = DateTime.now();
      
      return perbaikan;
    } catch (e) {
      print('Error getting all perbaikan: $e');
      // Return cached data if available, otherwise empty list
      return _perbaikanCache ?? [];
    }
  }

  Future<Perbaikan?> getPerbaikanById(String id) async {
    try {
      // First check cache
      if (_perbaikanCache != null) {
        final cachedPerbaikan = _perbaikanCache!.where((p) => p.id == id).firstOrNull;
        if (cachedPerbaikan != null) {
          return cachedPerbaikan;
        }
      }
      
      return await _databaseService.getPerbaikanById(id);
    } catch (e) {
      print('Error getting perbaikan by id $id: $e');
      return null;
    }
  }

  Future<Perbaikan> addPerbaikan(Map<String, dynamic> perbaikanData) async {
    try {
      final perbaikan = await _databaseService.addPerbaikan(perbaikanData);
      _clearCache(); // Clear cache after adding
      return perbaikan;
    } catch (e) {
      print('Error adding perbaikan: $e');
      _clearCache(); // Clear cache on error to ensure consistency
      throw Exception('Gagal menambah perbaikan: ${e.toString()}');
    }
  }

  Future<Perbaikan> updatePerbaikan(String id, Map<String, dynamic> updateData) async {
    try {
      final perbaikan = await _databaseService.updatePerbaikan(id, updateData);
      _clearCache(); // Clear cache after updating
      return perbaikan;
    } catch (e) {
      print('Error updating perbaikan $id: $e');
      _clearCache(); // Clear cache on error to ensure consistency
      throw Exception('Gagal memperbarui perbaikan: ${e.toString()}');
    }
  }

  Future<void> deletePerbaikan(String id) async {
    try {
      await _databaseService.deletePerbaikan(id);
      _clearCache(); // Clear cache after deleting
    } catch (e) {
      print('Error deleting perbaikan $id: $e');
      throw Exception('Gagal menghapus perbaikan: ${e.toString()}');
    }
  }

  Future<List<Perbaikan>> searchPerbaikan({
    String? query,
    String? status,
    String? contractor,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _databaseService.searchPerbaikan(
        query: query,
        status: status,
        contractor: contractor,
        assignedTo: assignedTo,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      print('Error searching perbaikan: $e');
      return [];
    }
  }

  // ==================== STATISTICS ====================

  Future<Map<String, int>> getSummaryStatistics() async {
    try {
      return await _databaseService.getSummaryStatistics();
    } catch (e) {
      print('Error getting summary statistics: $e');
      return {
        'totalTemuan': 0,
        'temuanPending': 0,
        'temuanInProgress': 0,
        'temuanCompleted': 0,
        'totalPerbaikan': 0,
        'perbaikanPending': 0,
        'perbaikanOngoing': 0,
        'perbaikanCompleted': 0,
      };
    }
  }

  Future<Map<String, int>> getCategoryStatistics() async {
    try {
      return await _databaseService.getCategoryStatistics();
    } catch (e) {
      print('Error getting category statistics: $e');
      return {};
    }
  }

  Future<Map<String, int>> getPriorityStatistics() async {
    try {
      return await _databaseService.getPriorityStatistics();
    } catch (e) {
      print('Error getting priority statistics: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getDetailedStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _databaseService.getDetailedStatistics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      print('Error getting detailed statistics: $e');
      return {
        'temuan': {},
        'perbaikan': {},
      };
    }
  }

  // ==================== ACTIVITY LOGS ====================

  Future<List<Map<String, dynamic>>> getActivityLogs({
    int limit = 50,
    String? userId,
  }) async {
    try {
      return await _databaseService.getActivityLogs(
        limit: limit,
        userId: userId,
      );
    } catch (e) {
      print('Error getting activity logs: $e');
      return [];
    }
  }

  // ==================== BACKUP & RESTORE ====================

  Future<Map<String, dynamic>> exportData() async {
    try {
      return await _databaseService.exportData();
    } catch (e) {
      print('Error exporting data: $e');
      throw Exception('Gagal mengekspor data: ${e.toString()}');
    }
  }

  Future<void> importData(Map<String, dynamic> backupData) async {
    try {
      await _databaseService.importData(backupData);
      _clearCache(); // Clear cache after importing
    } catch (e) {
      print('Error importing data: $e');
      throw Exception('Gagal mengimpor data: ${e.toString()}');
    }
  }

  // ==================== SETTINGS ====================

  Future<String?> getSetting(String key) async {
    try {
      return await _databaseService.getSetting(key);
    } catch (e) {
      print('Error getting setting $key: $e');
      return null;
    }
  }

  Future<void> setSetting(String key, String value, {String? description}) async {
    try {
      await _databaseService.setSetting(key, value, description: description);
    } catch (e) {
      print('Error setting $key: $e');
      throw Exception('Gagal menyimpan pengaturan: ${e.toString()}');
    }
  }

  Future<Map<String, String>> getAllSettings() async {
    try {
      return await _databaseService.getAllSettings();
    } catch (e) {
      print('Error getting all settings: $e');
      return {};
    }
  }

  // ==================== MAINTENANCE ====================

  Future<void> cleanupOldLogs({int daysToKeep = 90}) async {
    try {
      await _databaseService.cleanupOldLogs(daysToKeep: daysToKeep);
    } catch (e) {
      print('Error cleaning up old logs: $e');
      throw Exception('Gagal membersihkan log lama: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      return await _databaseService.getDatabaseInfo();
    } catch (e) {
      print('Error getting database info: $e');
      return {
        'database_path': '',
        'database_size': 0,
        'database_size_mb': '0.0',
        'tables': {
          'temuan_count': 0,
          'perbaikan_count': 0,
        },
        'last_backup': null,
        'version': '1.0.0',
      };
    }
  }

  Future<void> vacuum() async {
    try {
      await _databaseService.vacuum();
    } catch (e) {
      print('Error vacuuming database: $e');
      throw Exception('Gagal mengoptimalkan database: ${e.toString()}');
    }
  }

  Future<void> clearAllData() async {
    try {
      await _databaseService.clearAllData();
      _clearCache(); // Clear cache after clearing data
    } catch (e) {
      print('Error clearing all data: $e');
      throw Exception('Gagal menghapus semua data: ${e.toString()}');
    }
  }

  Future<void> close() async {
    try {
      await _databaseService.close();
      _clearCache();
    } catch (e) {
      print('Error closing database: $e');
    }
  }

  // ==================== HELPER METHODS ====================

  // Get recent items with better error handling
  Future<List<Map<String, dynamic>>> getRecentActivities({int limit = 10}) async {
    try {
      final recentTemuan = await getAllTemuan();
      final recentPerbaikan = await getAllPerbaikan();
      
      final activities = <Map<String, dynamic>>[];
      
      // Add recent temuan
      for (final temuan in recentTemuan.take(limit ~/ 2)) {
        activities.add({
          'type': 'temuan',
          'id': temuan.id,
          'title': 'Temuan: ${temuan.description}',
          'subtitle': 'KM ${temuan.kmPoint} • ${temuan.section}',
          'status': temuan.status,
          'priority': temuan.priority,
          'category': temuan.category,
          'createdAt': temuan.createdAt,
          'icon': Icons.search,
        });
      }
      
      // Add recent perbaikan
      for (final perbaikan in recentPerbaikan.take(limit ~/ 2)) {
        activities.add({
          'type': 'perbaikan',
          'id': perbaikan.id,
          'title': 'Perbaikan: ${perbaikan.workDescription}',
          'subtitle': 'KM ${perbaikan.kmPoint} • ${perbaikan.assignedTo}',
          'status': perbaikan.status,
          'progress': perbaikan.progress,
          'category': perbaikan.category,
          'createdAt': perbaikan.createdAt,
          'icon': Icons.build,
        });
      }
      
      // Sort by creation time (newest first)
      activities.sort((a, b) => 
        (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime)
      );
      
      return activities.take(limit).toList();
    } catch (e) {
      print('Error getting recent activities: $e');
      return [];
    }
  }

  // Get dashboard summary with error handling
  Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final stats = await getSummaryStatistics();
      final categoryStats = await getCategoryStatistics();
      final priorityStats = await getPriorityStatistics();
      final recentActivities = await getRecentActivities(limit: 5);
      
      return {
        'summary': stats,
        'categoryBreakdown': categoryStats,
        'priorityBreakdown': priorityStats,
        'recentActivities': recentActivities,
        'lastUpdated': DateTime.now(),
      };
    } catch (e) {
      print('Error getting dashboard summary: $e');
      return {
        'summary': <String, int>{},
        'categoryBreakdown': <String, int>{},
        'priorityBreakdown': <String, int>{},
        'recentActivities': <Map<String, dynamic>>[],
        'lastUpdated': DateTime.now(),
      };
    }
  }

  // Check if there are available temuan for perbaikan
  Future<List<Temuan>> getAvailableTemuanForPerbaikan() async {
    try {
      final allTemuan = await getAllTemuan();
      final allPerbaikan = await getAllPerbaikan();
      
      // Get IDs of temuan that already have perbaikan
      final temuanWithPerbaikan = allPerbaikan.map((p) => p.temuanId).toSet();
      
      // Filter temuan that don't have perbaikan yet
      return allTemuan.where((t) => !temuanWithPerbaikan.contains(t.id)).toList();
    } catch (e) {
      print('Error getting available temuan for perbaikan: $e');
      return [];
    }
  }

  // Refresh all cached data
  Future<void> refreshAllData() async {
    try {
      _clearCache();
      await Future.wait([
        getAllTemuan(forceRefresh: true),
        getAllPerbaikan(forceRefresh: true),
      ]);
    } catch (e) {
      print('Error refreshing all data: $e');
      throw Exception('Gagal memuat ulang data: ${e.toString()}');
    }
  }

  // Get performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'hasCachedTemuan': _temuanCache != null,
      'hasCachedPerbaikan': _perbaikanCache != null,
      'cacheAge': _lastCacheUpdate != null 
          ? DateTime.now().difference(_lastCacheUpdate!).inMinutes 
          : null,
      'isCacheValid': _isCacheValid(),
      'temuanCacheSize': _temuanCache?.length ?? 0,
      'perbaikanCacheSize': _perbaikanCache?.length ?? 0,
    };
  }
}