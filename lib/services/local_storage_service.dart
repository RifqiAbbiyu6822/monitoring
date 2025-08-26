// lib/services/local_storage_service.dart - Updated version
import '../model/temuan.dart';
import '../model/perbaikan.dart';
import 'database_service.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  final DatabaseService _databaseService = DatabaseService();

  // ==================== TEMUAN OPERATIONS ====================

  Future<List<Temuan>> getAllTemuan() async {
    return await _databaseService.getAllTemuan();
  }

  Future<Temuan?> getTemuanById(String id) async {
    return await _databaseService.getTemuanById(id);
  }

  Future<Temuan> addTemuan(Map<String, dynamic> temuanData) async {
    return await _databaseService.addTemuan(temuanData);
  }

  Future<Temuan> updateTemuan(String id, Map<String, dynamic> updateData) async {
    return await _databaseService.updateTemuan(id, updateData);
  }

  Future<void> deleteTemuan(String id) async {
    await _databaseService.deleteTemuan(id);
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
    return await _databaseService.searchTemuan(
      query: query,
      category: category,
      status: status,
      priority: priority,
      section: section,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // ==================== PERBAIKAN OPERATIONS ====================

  Future<List<Perbaikan>> getAllPerbaikan() async {
    return await _databaseService.getAllPerbaikan();
  }

  Future<Perbaikan?> getPerbaikanById(String id) async {
    return await _databaseService.getPerbaikanById(id);
  }

  Future<Perbaikan> addPerbaikan(Map<String, dynamic> perbaikanData) async {
    return await _databaseService.addPerbaikan(perbaikanData);
  }

  Future<Perbaikan> updatePerbaikan(String id, Map<String, dynamic> updateData) async {
    return await _databaseService.updatePerbaikan(id, updateData);
  }

  Future<void> deletePerbaikan(String id) async {
    await _databaseService.deletePerbaikan(id);
  }

  Future<List<Perbaikan>> searchPerbaikan({
    String? query,
    String? status,
    String? contractor,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _databaseService.searchPerbaikan(
      query: query,
      status: status,
      contractor: contractor,
      assignedTo: assignedTo,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // ==================== STATISTICS ====================

  Future<Map<String, int>> getSummaryStatistics() async {
    return await _databaseService.getSummaryStatistics();
  }

  Future<Map<String, int>> getCategoryStatistics() async {
    return await _databaseService.getCategoryStatistics();
  }

  Future<Map<String, int>> getPriorityStatistics() async {
    return await _databaseService.getPriorityStatistics();
  }

  Future<Map<String, dynamic>> getDetailedStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _databaseService.getDetailedStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  // ==================== ACTIVITY LOGS ====================

  Future<List<Map<String, dynamic>>> getActivityLogs({
    int limit = 50,
    String? userId,
  }) async {
    return await _databaseService.getActivityLogs(
      limit: limit,
      userId: userId,
    );
  }

  // ==================== BACKUP & RESTORE ====================

  Future<Map<String, dynamic>> exportData() async {
    return await _databaseService.exportData();
  }

  Future<void> importData(Map<String, dynamic> backupData) async {
    await _databaseService.importData(backupData);
  }

  // ==================== SETTINGS ====================

  Future<String?> getSetting(String key) async {
    return await _databaseService.getSetting(key);
  }

  Future<void> setSetting(String key, String value, {String? description}) async {
    await _databaseService.setSetting(key, value, description: description);
  }

  Future<Map<String, String>> getAllSettings() async {
    return await _databaseService.getAllSettings();
  }

  // ==================== MAINTENANCE ====================

  Future<void> cleanupOldLogs({int daysToKeep = 90}) async {
    await _databaseService.cleanupOldLogs(daysToKeep: daysToKeep);
  }

  Future<Map<String, dynamic>> getDatabaseInfo() async {
    return await _databaseService.getDatabaseInfo();
  }

  Future<void> vacuum() async {
    await _databaseService.vacuum();
  }

  Future<void> clearAllData() async {
    await _databaseService.clearAllData();
  }

  Future<void> close() async {
    await _databaseService.close();
  }
}