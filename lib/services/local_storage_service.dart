// lib/services/local_storage_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../model/temuan.dart';
import '../model/perbaikan.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _temuanFileName = 'temuan_data.json';
  static const String _perbaikanFileName = 'perbaikan_data.json';

  // Get application documents directory
  Future<Directory> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  // Get temuan file
  Future<File> get _temuanFile async {
    final path = await _localPath;
    return File('${path.path}/$_temuanFileName');
  }

  // Get perbaikan file
  Future<File> get _perbaikanFile async {
    final path = await _localPath;
    return File('${path.path}/$_perbaikanFileName');
  }

  // Generate unique ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // ==================== TEMUAN OPERATIONS ====================

  // Get all temuan
  Future<List<Temuan>> getAllTemuan() async {
    try {
      final file = await _temuanFile;
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonData = json.decode(contents);
      
      return jsonData.map((json) => Temuan.fromJson(json)).toList();
    } catch (e) {
      print('Error reading temuan: $e');
      return [];
    }
  }

  // Save temuan list
  Future<void> _saveTemuanList(List<Temuan> temuanList) async {
    try {
      final file = await _temuanFile;
      final jsonData = temuanList.map((temuan) => temuan.toJson()).toList();
      await file.writeAsString(json.encode(jsonData));
    } catch (e) {
      print('Error saving temuan: $e');
      throw Exception('Failed to save temuan');
    }
  }

  // Add new temuan
  Future<Temuan> addTemuan(Map<String, dynamic> temuanData) async {
    try {
      final temuanList = await getAllTemuan();
      
      final newTemuan = Temuan(
        id: _generateId(),
        category: temuanData['category'],
        subcategory: temuanData['subcategory'],
        section: temuanData['section'],
        kmPoint: temuanData['kmPoint'],
        lane: temuanData['lane'],
        description: temuanData['description'],
        priority: temuanData['priority'],
        status: 'pending',
        latitude: temuanData['latitude'] ?? 0.0,
        longitude: temuanData['longitude'] ?? 0.0,
        photos: List<String>.from(temuanData['photos'] ?? []),
        createdAt: DateTime.now(),
        createdBy: temuanData['createdBy'] ?? 'Unknown User',
        notes: temuanData['notes'],
      );

      temuanList.add(newTemuan);
      await _saveTemuanList(temuanList);
      
      return newTemuan;
    } catch (e) {
      print('Error adding temuan: $e');
      throw Exception('Failed to add temuan');
    }
  }

  // Update temuan
  Future<Temuan> updateTemuan(String id, Map<String, dynamic> updateData) async {
    try {
      final temuanList = await getAllTemuan();
      final index = temuanList.indexWhere((temuan) => temuan.id == id);
      
      if (index == -1) {
        throw Exception('Temuan not found');
      }

      final existingTemuan = temuanList[index];
      final updatedTemuan = Temuan(
        id: existingTemuan.id,
        category: updateData['category'] ?? existingTemuan.category,
        subcategory: updateData['subcategory'] ?? existingTemuan.subcategory,
        section: updateData['section'] ?? existingTemuan.section,
        kmPoint: updateData['kmPoint'] ?? existingTemuan.kmPoint,
        lane: updateData['lane'] ?? existingTemuan.lane,
        description: updateData['description'] ?? existingTemuan.description,
        priority: updateData['priority'] ?? existingTemuan.priority,
        status: updateData['status'] ?? existingTemuan.status,
        latitude: updateData['latitude'] ?? existingTemuan.latitude,
        longitude: updateData['longitude'] ?? existingTemuan.longitude,
        photos: updateData['photos'] != null 
            ? List<String>.from(updateData['photos']) 
            : existingTemuan.photos,
        createdAt: existingTemuan.createdAt,
        createdBy: existingTemuan.createdBy,
        updatedAt: DateTime.now(),
        updatedBy: updateData['updatedBy'],
        notes: updateData['notes'] ?? existingTemuan.notes,
      );

      temuanList[index] = updatedTemuan;
      await _saveTemuanList(temuanList);
      
      return updatedTemuan;
    } catch (e) {
      print('Error updating temuan: $e');
      throw Exception('Failed to update temuan');
    }
  }

  // Delete temuan
  Future<void> deleteTemuan(String id) async {
    try {
      final temuanList = await getAllTemuan();
      temuanList.removeWhere((temuan) => temuan.id == id);
      await _saveTemuanList(temuanList);
    } catch (e) {
      print('Error deleting temuan: $e');
      throw Exception('Failed to delete temuan');
    }
  }

  // Get temuan by ID
  Future<Temuan?> getTemuanById(String id) async {
    try {
      final temuanList = await getAllTemuan();
      return temuanList.firstWhere(
        (temuan) => temuan.id == id,
        orElse: () => throw Exception('Temuan not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // ==================== PERBAIKAN OPERATIONS ====================

  // Get all perbaikan
  Future<List<Perbaikan>> getAllPerbaikan() async {
    try {
      final file = await _perbaikanFile;
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonData = json.decode(contents);
      
      return jsonData.map((json) => Perbaikan.fromJson(json)).toList();
    } catch (e) {
      print('Error reading perbaikan: $e');
      return [];
    }
  }

  // Save perbaikan list
  Future<void> _savePerbaikanList(List<Perbaikan> perbaikanList) async {
    try {
      final file = await _perbaikanFile;
      final jsonData = perbaikanList.map((perbaikan) => perbaikan.toJson()).toList();
      await file.writeAsString(json.encode(jsonData));
    } catch (e) {
      print('Error saving perbaikan: $e');
      throw Exception('Failed to save perbaikan');
    }
  }

  // Add new perbaikan
  Future<Perbaikan> addPerbaikan(Map<String, dynamic> perbaikanData) async {
    try {
      final perbaikanList = await getAllPerbaikan();
      
      final newPerbaikan = Perbaikan(
        id: _generateId(),
        temuanId: perbaikanData['temuanId'],
        category: perbaikanData['category'],
        subcategory: perbaikanData['subcategory'],
        section: perbaikanData['section'],
        kmPoint: perbaikanData['kmPoint'],
        lane: perbaikanData['lane'],
        workDescription: perbaikanData['workDescription'],
        contractor: perbaikanData['contractor'],
        status: perbaikanData['status'] ?? 'pending',
        startDate: perbaikanData['startDate'] != null 
            ? DateTime.parse(perbaikanData['startDate']) 
            : DateTime.now(),
        endDate: perbaikanData['endDate'] != null 
            ? DateTime.parse(perbaikanData['endDate']) 
            : null,
        progress: perbaikanData['progress']?.toDouble() ?? 0.0,
        beforePhotos: List<String>.from(perbaikanData['beforePhotos'] ?? []),
        progressPhotos: List<String>.from(perbaikanData['progressPhotos'] ?? []),
        afterPhotos: List<String>.from(perbaikanData['afterPhotos'] ?? []),
        assignedTo: perbaikanData['assignedTo'],
        createdAt: DateTime.now(),
        createdBy: perbaikanData['createdBy'] ?? 'Unknown User',
        notes: perbaikanData['notes'],
        cost: perbaikanData['cost']?.toDouble(),
      );

      perbaikanList.add(newPerbaikan);
      await _savePerbaikanList(perbaikanList);
      
      return newPerbaikan;
    } catch (e) {
      print('Error adding perbaikan: $e');
      throw Exception('Failed to add perbaikan');
    }
  }

  // Update perbaikan
  Future<Perbaikan> updatePerbaikan(String id, Map<String, dynamic> updateData) async {
    try {
      final perbaikanList = await getAllPerbaikan();
      final index = perbaikanList.indexWhere((perbaikan) => perbaikan.id == id);
      
      if (index == -1) {
        throw Exception('Perbaikan not found');
      }

      final existingPerbaikan = perbaikanList[index];
      final updatedPerbaikan = Perbaikan(
        id: existingPerbaikan.id,
        temuanId: existingPerbaikan.temuanId,
        category: existingPerbaikan.category,
        subcategory: existingPerbaikan.subcategory,
        section: existingPerbaikan.section,
        kmPoint: existingPerbaikan.kmPoint,
        lane: existingPerbaikan.lane,
        workDescription: updateData['workDescription'] ?? existingPerbaikan.workDescription,
        contractor: updateData['contractor'] ?? existingPerbaikan.contractor,
        status: updateData['status'] ?? existingPerbaikan.status,
        startDate: updateData['startDate'] != null 
            ? DateTime.parse(updateData['startDate']) 
            : existingPerbaikan.startDate,
        endDate: updateData['endDate'] != null 
            ? DateTime.parse(updateData['endDate']) 
            : existingPerbaikan.endDate,
        progress: updateData['progress']?.toDouble() ?? existingPerbaikan.progress,
        beforePhotos: updateData['beforePhotos'] != null 
            ? List<String>.from(updateData['beforePhotos']) 
            : existingPerbaikan.beforePhotos,
        progressPhotos: updateData['progressPhotos'] != null 
            ? List<String>.from(updateData['progressPhotos']) 
            : existingPerbaikan.progressPhotos,
        afterPhotos: updateData['afterPhotos'] != null 
            ? List<String>.from(updateData['afterPhotos']) 
            : existingPerbaikan.afterPhotos,
        assignedTo: updateData['assignedTo'] ?? existingPerbaikan.assignedTo,
        createdAt: existingPerbaikan.createdAt,
        createdBy: existingPerbaikan.createdBy,
        notes: updateData['notes'] ?? existingPerbaikan.notes,
        cost: updateData['cost']?.toDouble() ?? existingPerbaikan.cost,
      );

      perbaikanList[index] = updatedPerbaikan;
      await _savePerbaikanList(perbaikanList);
      
      return updatedPerbaikan;
    } catch (e) {
      print('Error updating perbaikan: $e');
      throw Exception('Failed to update perbaikan');
    }
  }

  // Delete perbaikan
  Future<void> deletePerbaikan(String id) async {
    try {
      final perbaikanList = await getAllPerbaikan();
      perbaikanList.removeWhere((perbaikan) => perbaikan.id == id);
      await _savePerbaikanList(perbaikanList);
    } catch (e) {
      print('Error deleting perbaikan: $e');
      throw Exception('Failed to delete perbaikan');
    }
  }

  // Get perbaikan by ID
  Future<Perbaikan?> getPerbaikanById(String id) async {
    try {
      final perbaikanList = await getAllPerbaikan();
      return perbaikanList.firstWhere(
        (perbaikan) => perbaikan.id == id,
        orElse: () => throw Exception('Perbaikan not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // ==================== STATISTICS ====================

  // Get summary statistics
  Future<Map<String, int>> getSummaryStatistics() async {
    try {
      final temuanList = await getAllTemuan();
      final perbaikanList = await getAllPerbaikan();

      final temuanPending = temuanList.where((t) => t.status == 'pending').length;
      final temuanInProgress = temuanList.where((t) => t.status == 'in_progress').length;
      final temuanCompleted = temuanList.where((t) => t.status == 'completed').length;

      final perbaikanPending = perbaikanList.where((p) => p.status == 'pending').length;
      final perbaikanOngoing = perbaikanList.where((p) => p.status == 'ongoing').length;
      final perbaikanCompleted = perbaikanList.where((p) => p.status == 'selesai').length;

      return {
        'totalTemuan': temuanList.length,
        'temuanPending': temuanPending,
        'temuanInProgress': temuanInProgress,
        'temuanCompleted': temuanCompleted,
        'totalPerbaikan': perbaikanList.length,
        'perbaikanPending': perbaikanPending,
        'perbaikanOngoing': perbaikanOngoing,
        'perbaikanCompleted': perbaikanCompleted,
      };
    } catch (e) {
      print('Error getting statistics: $e');
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

  // Clear all data (for testing purposes)
  Future<void> clearAllData() async {
    try {
      final temuanFile = await _temuanFile;
      final perbaikanFile = await _perbaikanFile;
      
      if (await temuanFile.exists()) {
        await temuanFile.delete();
      }
      
      if (await perbaikanFile.exists()) {
        await perbaikanFile.delete();
      }
    } catch (e) {
      print('Error clearing data: $e');
    }
  }
}