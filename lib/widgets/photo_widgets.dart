// lib/widgets/photo_widgets.dart - Enhanced with Progress Tracking
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/photo_service.dart';
import '../utils/theme.dart';
import '../utils/date_formatter.dart';

// Model for progress photos with metadata
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

  Map<String, dynamic> toJson() => {
    'photoPath': photoPath,
    'progress': progress,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    'notes': notes,
  };

  factory ProgressPhotoItem.fromJson(Map<String, dynamic> json) => ProgressPhotoItem(
    photoPath: json['photoPath'],
    progress: json['progress'],
    description: json['description'],
    timestamp: DateTime.parse(json['timestamp']),
    notes: json['notes'],
  );
}

class ModernPhotoGrid extends StatelessWidget {
  final List<String> photos;
  final VoidCallback? onAddPhoto;
  final Function(String)? onDeletePhoto;
  final Function(String)? onViewPhoto;
  final bool canEdit;
  final int maxPhotos;
  final String emptyMessage;
  final String title;

  const ModernPhotoGrid({
    super.key,
    required this.photos,
    this.onAddPhoto,
    this.onDeletePhoto,
    this.onViewPhoto,
    this.canEdit = true,
    this.maxPhotos = 5,
    this.emptyMessage = 'Belum ada foto',
    this.title = 'Foto',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.photo_library_outlined,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: photos.length >= maxPhotos
                    ? AppTheme.warningColor.withOpacity(0.1)
                    : AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: photos.length >= maxPhotos
                      ? AppTheme.warningColor.withOpacity(0.3)
                      : AppTheme.infoColor.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Text(
                '${photos.length}/$maxPhotos',
                style: TextStyle(
                  color: photos.length >= maxPhotos
                      ? AppTheme.warningColor
                      : AppTheme.infoColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Photo grid or empty state
        if (photos.isEmpty) ...[
          _buildEmptyState(context),
        ] else ...[
          _buildPhotoGrid(context),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.3),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.textTertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.photo_camera_outlined,
              size: 32,
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan foto untuk dokumentasi yang lebih baik',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          if (canEdit && onAddPhoto != null) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onAddPhoto,
              icon: const Icon(Icons.add_a_photo, size: 18),
              label: const Text('Tambah Foto'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(BuildContext context) {
    final itemCount = photos.length + (canEdit && photos.length < maxPhotos ? 1 : 0);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < photos.length) {
          return _buildPhotoItem(context, photos[index], index);
        } else {
          return _buildAddPhotoButton(context);
        }
      },
    );
  }

  Widget _buildPhotoItem(BuildContext context, String photoPath, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            GestureDetector(
              onTap: () => onViewPhoto?.call(photoPath),
              child: File(photoPath).existsSync()
                  ? Image.file(
                      File(photoPath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildErrorPhoto(),
                    )
                  : _buildErrorPhoto(),
            ),
            
            // Overlay gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                  stops: const [0.7, 1.0],
                ),
              ),
            ),
            
            // Photo number
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            // Action buttons
            if (canEdit)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => onViewPhoto?.call(photoPath),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.visibility_outlined,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showDeleteConfirmation(context, photoPath),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPhoto() {
    return Container(
      color: AppTheme.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: AppTheme.textTertiary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            'Error',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onAddPhoto,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambah',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String photoPath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: AppTheme.errorColor),
            const SizedBox(width: 12),
            const Text('Hapus Foto'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin menghapus foto ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDeletePhoto?.call(photoPath);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// Enhanced Progress Photo Widget with detailed tracking
class ProgressPhotoWidget extends StatelessWidget {
  final List<ProgressPhotoItem> progressPhotos;
  final String title;
  final String emptyMessage;

  const ProgressPhotoWidget({
    super.key,
    required this.progressPhotos,
    this.title = 'Progress Pekerjaan',
    this.emptyMessage = 'Belum ada foto progress',
  });

  @override
  Widget build(BuildContext context) {
    if (progressPhotos.isEmpty) {
      return _buildEmptyState(context);
    }

    // Sort by progress percentage
    final sortedPhotos = List<ProgressPhotoItem>.from(progressPhotos)
      ..sort((a, b) => a.progress.compareTo(b.progress));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.timeline,
                size: 16,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${sortedPhotos.length} update',
                style: TextStyle(
                  color: AppTheme.successColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Timeline view
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedPhotos.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = sortedPhotos[index];
            final isLast = index == sortedPhotos.length - 1;
            return _buildProgressItem(context, item, isLast);
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.textTertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.timeline_outlined,
              size: 32,
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Progress foto akan muncul di sini saat pekerjaan berjalan',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(BuildContext context, ProgressPhotoItem item, bool isLast) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getProgressColor(item.progress).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getProgressColor(item.progress),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${item.progress.toInt()}%',
                      style: TextStyle(
                        color: _getProgressColor(item.progress),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (!isLast) ...[
                  Container(
                    width: 2,
                    height: 40,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.borderColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.description,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getProgressColor(item.progress).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getProgressStatus(item.progress),
                          style: TextStyle(
                            color: _getProgressColor(item.progress),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Timestamp
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormatter.formatDateTime(item.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Photo
                  if (File(item.photoPath).existsSync()) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GestureDetector(
                        onTap: () => _viewPhoto(context, item),
                        child: Stack(
                          children: [
                            Image.file(
                              File(item.photoPath),
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.zoom_in,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Notes
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.borderColor.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        item.notes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress <= 25) return AppTheme.warningColor;
    if (progress <= 50) return AppTheme.infoColor;
    if (progress <= 75) return AppTheme.primaryColor;
    return AppTheme.successColor;
  }

  String _getProgressStatus(double progress) {
    if (progress <= 25) return 'Mulai';
    if (progress <= 50) return 'Progress';
    if (progress <= 75) return 'Lanjut';
    if (progress < 100) return 'Hampir';
    return 'Selesai';
  }

  void _viewPhoto(BuildContext context, ProgressPhotoItem item) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ProgressPhotoViewer(item: item),
          );
        },
      ),
    );
  }
}

// Full-screen photo viewer with progress details
class ProgressPhotoViewer extends StatelessWidget {
  final ProgressPhotoItem item;

  const ProgressPhotoViewer({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Progress ${item.progress.toInt()}%',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Photo
          Expanded(
            child: Center(
              child: InteractiveViewer(
                child: File(item.photoPath).existsSync()
                    ? Image.file(
                        File(item.photoPath),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, color: Colors.white, size: 64),
                              SizedBox(height: 16),
                              Text('Gagal memuat foto', style: TextStyle(color: Colors.white)),
                            ],
                          );
                        },
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, color: Colors.white, size: 64),
                          SizedBox(height: 16),
                          Text('Foto tidak ditemukan', style: TextStyle(color: Colors.white)),
                        ],
                      ),
              ),
            ),
          ),
          
          // Details panel
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress indicator
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${item.progress.toInt()}% Complete',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormatter.formatDateTime(item.timestamp),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Description
                Text(
                  item.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                // Notes
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    item.notes!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}