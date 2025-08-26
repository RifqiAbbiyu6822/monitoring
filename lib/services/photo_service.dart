// lib/services/photo_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class PhotoService {
  static final PhotoService _instance = PhotoService._internal();
  factory PhotoService() => _instance;
  PhotoService._internal();

  final ImagePicker _picker = ImagePicker();

  // Direktori untuk menyimpan foto
  Future<String> get _photoDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory(path.join(appDir.path, 'photos'));
    
    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }
    
    return photoDir.path;
  }

  // Mengambil foto dari kamera
  Future<String?> takePhoto() async {
    try {
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        throw Exception('Izin kamera diperlukan untuk mengambil foto');
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        return await _savePhoto(photo);
      }
      return null;
    } catch (e) {
      print('Error taking photo: $e');
      rethrow;
    }
  }

  // Memilih foto dari galeri
  Future<String?> pickFromGallery() async {
    try {
      // Request storage permission for Android
      if (Platform.isAndroid) {
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          final mediaStatus = await Permission.photos.request();
          if (!mediaStatus.isGranted) {
            throw Exception('Izin akses media diperlukan untuk memilih foto');
          }
        }
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        return await _savePhoto(photo);
      }
      return null;
    } catch (e) {
      print('Error picking photo: $e');
      rethrow;
    }
  }

  // Memilih beberapa foto dari galeri
  Future<List<String>> pickMultipleFromGallery() async {
    try {
      if (Platform.isAndroid) {
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          final mediaStatus = await Permission.photos.request();
          if (!mediaStatus.isGranted) {
            throw Exception('Izin akses media diperlukan untuk memilih foto');
          }
        }
      }

      final List<XFile> photos = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
        limit: 5, // Maksimal 5 foto
      );

      List<String> savedPaths = [];
      for (final photo in photos) {
        final savedPath = await _savePhoto(photo);
        if (savedPath != null) {
          savedPaths.add(savedPath);
        }
      }
      
      return savedPaths;
    } catch (e) {
      print('Error picking multiple photos: $e');
      rethrow;
    }
  }

  // Menyimpan foto ke direktori aplikasi
  Future<String?> _savePhoto(XFile photo) async {
    try {
      final photoDir = await _photoDirectory;
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = path.join(photoDir, fileName);
      
      final File savedFile = await File(photo.path).copy(savedPath);
      return savedFile.path;
    } catch (e) {
      print('Error saving photo: $e');
      return null;
    }
  }

  // Menghapus foto
  Future<bool> deletePhoto(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting photo: $e');
      return false;
    }
  }

  // Mendapatkan ukuran file foto
  Future<int> getPhotoSize(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      print('Error getting photo size: $e');
      return 0;
    }
  }

  // Membaca foto sebagai bytes
  Future<Uint8List?> readPhotoBytes(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      print('Error reading photo bytes: $e');
      return null;
    }
  }

  // Mendapatkan info foto
  Future<Map<String, dynamic>?> getPhotoInfo(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        final stat = await file.stat();
        return {
          'path': photoPath,
          'size': stat.size,
          'modified': stat.modified,
          'exists': true,
        };
      }
      return {
        'path': photoPath,
        'exists': false,
      };
    } catch (e) {
      print('Error getting photo info: $e');
      return null;
    }
  }

  // Membersihkan foto lama (lebih dari 30 hari)
  Future<int> cleanupOldPhotos({int daysToKeep = 30}) async {
    try {
      final photoDir = await _photoDirectory;
      final directory = Directory(photoDir);
      
      if (!await directory.exists()) return 0;
      
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      int deletedCount = 0;
      
      await for (final entity in directory.list()) {
        if (entity is File && entity.path.endsWith('.jpg')) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            deletedCount++;
          }
        }
      }
      
      return deletedCount;
    } catch (e) {
      print('Error cleaning up old photos: $e');
      return 0;
    }
  }

  // Menghitung total ukuran semua foto
  Future<int> getTotalPhotosSize() async {
    try {
      final photoDir = await _photoDirectory;
      final directory = Directory(photoDir);
      
      if (!await directory.exists()) return 0;
      
      int totalSize = 0;
      await for (final entity in directory.list()) {
        if (entity is File && entity.path.endsWith('.jpg')) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      
      return totalSize;
    } catch (e) {
      print('Error calculating total photos size: $e');
      return 0;
    }
  }

  // Show dialog untuk memilih sumber foto
  Future<String?> showPhotoSourceDialog(BuildContext context) async {
    return await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pilih Sumber Foto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.blue),
              ),
              title: const Text('Ambil dari Kamera'),
              subtitle: const Text('Foto langsung dengan kamera'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_library, color: Colors.green),
              ),
              title: const Text('Pilih dari Galeri'),
              subtitle: const Text('Pilih foto yang sudah ada'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Handle foto action berdasarkan pilihan user
  Future<String?> handlePhotoAction(BuildContext context) async {
    try {
      final source = await showPhotoSourceDialog(context);
      
      if (source == null) return null;
      
      switch (source) {
        case 'camera':
          return await takePhoto();
        case 'gallery':
          return await pickFromGallery();
        default:
          return null;
      }
    } catch (e) {
      print('Error handling photo action: $e');
      rethrow;
    }
  }
}