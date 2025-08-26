// lib/widgets/photo_widgets.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/photo_service.dart';
import '../utils/theme.dart';

// Widget untuk menampilkan grid foto
class PhotoGridWidget extends StatelessWidget {
  final List<String> photos;
  final VoidCallback? onAddPhoto;
  final Function(String)? onDeletePhoto;
  final Function(String)? onViewPhoto;
  final bool canEdit;
  final int maxPhotos;
  final String emptyMessage;

  const PhotoGridWidget({
    super.key,
    required this.photos,
    this.onAddPhoto,
    this.onDeletePhoto,
    this.onViewPhoto,
    this.canEdit = true,
    this.maxPhotos = 5,
    this.emptyMessage = 'Belum ada foto',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (photos.isEmpty) ...[
          Container(
            constraints: const BoxConstraints(
              minHeight: 120,
              maxHeight: 200,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.radius12),
              border: Border.all(color: AppTheme.borderColor, style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 32,
                  color: AppTheme.textTertiary,
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  emptyMessage,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (canEdit && onAddPhoto != null) ...[
                  const SizedBox(height: AppTheme.spacing12),
                  ElevatedButton.icon(
                    onPressed: onAddPhoto,
                    icon: const Icon(Icons.add_a_photo, size: 16),
                    label: const Text('Tambah Foto'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing16,
                        vertical: AppTheme.spacing8,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ] else ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppTheme.spacing8,
              mainAxisSpacing: AppTheme.spacing8,
              childAspectRatio: 1.0,
            ),
            itemCount: photos.length + (canEdit && photos.length < maxPhotos ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < photos.length) {
                return _buildPhotoItem(context, photos[index], index);
              } else {
                return _buildAddPhotoButton(context);
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoItem(BuildContext context, String photoPath, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius8),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.shadowSm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radius8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo Image
            GestureDetector(
              onTap: () => onViewPhoto?.call(photoPath),
              child: File(photoPath).existsSync()
                  ? Image.file(
                      File(photoPath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.backgroundColor,
                          child: const Icon(
                            Icons.broken_image,
                            color: AppTheme.textTertiary,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppTheme.backgroundColor,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: AppTheme.textTertiary,
                      ),
                    ),
            ),
            
            // Photo actions overlay
            if (canEdit)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(AppTheme.radius4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => onViewPhoto?.call(photoPath),
                        icon: const Icon(
                          Icons.visibility,
                          color: Colors.white,
                          size: 16,
                        ),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showDeleteConfirmation(context, photoPath),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 16,
                        ),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Photo index
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(AppTheme.radius4),
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
          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoButton(BuildContext context) {
    return GestureDetector(
      onTap: onAddPhoto,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radius8),
          border: Border.all(color: AppTheme.borderColor, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              'Tambah',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String photoPath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Foto'),
        content: const Text('Apakah Anda yakin ingin menghapus foto ini?'),
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
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// Widget untuk memilih dan mengelola foto
class PhotoPickerWidget extends StatefulWidget {
  final List<String> initialPhotos;
  final Function(List<String>) onPhotosChanged;
  final int maxPhotos;
  final String title;
  final String subtitle;

  const PhotoPickerWidget({
    super.key,
    required this.initialPhotos,
    required this.onPhotosChanged,
    this.maxPhotos = 5,
    this.title = 'Foto',
    this.subtitle = 'Pilih foto untuk ditambahkan',
  });

  @override
  State<PhotoPickerWidget> createState() => _PhotoPickerWidgetState();
}

class _PhotoPickerWidgetState extends State<PhotoPickerWidget> {
  late List<String> _photos;
  final PhotoService _photoService = PhotoService();

  @override
  void initState() {
    super.initState();
    _photos = List.from(widget.initialPhotos);
  }

  Future<void> _addPhoto() async {
    if (_photos.length >= widget.maxPhotos) {
      _showMaxPhotosDialog();
      return;
    }

    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _buildPhotoSourceBottomSheet(),
    );

    if (result != null) {
      String? photoPath;
      
      try {
        if (result == 'camera') {
          photoPath = await _photoService.takePhoto();
        } else if (result == 'gallery') {
          photoPath = await _photoService.pickFromGallery();
        }

                 if (photoPath != null && photoPath.isNotEmpty) {
           setState(() {
             _photos.add(photoPath!);
           });
           widget.onPhotosChanged(_photos);
         }
      } catch (e) {
        _showErrorSnackBar('Gagal menambahkan foto: $e');
      }
    }
  }

  void _deletePhoto(String photoPath) {
    setState(() {
      _photos.remove(photoPath);
    });
    widget.onPhotosChanged(_photos);
  }

  void _viewPhoto(String photoPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewerScreen(photoPath: photoPath),
      ),
    );
  }

  Widget _buildPhotoSourceBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pilih Sumber Foto',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacing20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, 'camera'),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, 'gallery'),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeri'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  void _showMaxPhotosDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batas Foto'),
        content: Text('Maksimal ${widget.maxPhotos} foto yang dapat ditambahkan.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing8,
                vertical: AppTheme.spacing4,
              ),
              decoration: BoxDecoration(
                color: _photos.length >= widget.maxPhotos 
                    ? AppTheme.errorColor.withOpacity(0.1)
                    : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radius8),
              ),
              child: Text(
                '${_photos.length}/${widget.maxPhotos}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _photos.length >= widget.maxPhotos 
                      ? AppTheme.errorColor
                      : AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing16),
        PhotoGridWidget(
          photos: _photos,
          onAddPhoto: _photos.length < widget.maxPhotos ? _addPhoto : null,
          onDeletePhoto: _deletePhoto,
          onViewPhoto: _viewPhoto,
          maxPhotos: widget.maxPhotos,
          emptyMessage: 'Tambahkan foto untuk dokumentasi',
        ),
      ],
    );
  }
}

// Widget untuk menampilkan foto dalam layar penuh
class PhotoViewerScreen extends StatelessWidget {
  final String photoPath;

  const PhotoViewerScreen({
    super.key,
    required this.photoPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Lihat Foto',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: File(photoPath).existsSync()
            ? Image.file(
                File(photoPath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 64,
                      ),
                      SizedBox(height: AppTheme.spacing16),
                      Text(
                        'Gagal memuat foto',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  );
                },
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    color: Colors.white,
                    size: 64,
                  ),
                  SizedBox(height: AppTheme.spacing16),
                  Text(
                    'Foto tidak ditemukan',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
}

// Widget untuk menampilkan foto dalam mode view-only (untuk detail temuan)
class PhotoViewerWidget extends StatelessWidget {
  final List<String> photos;
  final String title;
  final String emptyMessage;

  const PhotoViewerWidget({
    super.key,
    required this.photos,
    this.title = 'Foto',
    this.emptyMessage = 'Tidak ada foto',
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radius12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: AppTheme.spacing12),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo_library,
              size: 20,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: AppTheme.spacing8),
            Text(
              '$title (${photos.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: AppTheme.spacing8,
            mainAxisSpacing: AppTheme.spacing8,
            childAspectRatio: 1.0,
          ),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            return _buildPhotoItem(context, photos[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildPhotoItem(BuildContext context, String photoPath, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius8),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.shadowSm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radius8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo Image
            GestureDetector(
              onTap: () => _viewPhoto(context, photoPath),
              child: File(photoPath).existsSync()
                  ? Image.file(
                      File(photoPath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.backgroundColor,
                          child: const Icon(
                            Icons.broken_image,
                            color: AppTheme.textTertiary,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppTheme.backgroundColor,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: AppTheme.textTertiary,
                      ),
                    ),
            ),
            
            // Photo index
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(AppTheme.radius4),
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
            
            // View icon overlay
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(AppTheme.radius4),
                ),
                child: const Icon(
                  Icons.visibility,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewPhoto(BuildContext context, String photoPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewerScreen(photoPath: photoPath),
      ),
    );
  }
}

// Widget untuk menampilkan foto progress dengan informasi tambahan
class ProgressPhotoViewerWidget extends StatelessWidget {
  final List<String> photos;
  final String title;
  final String emptyMessage;
  final List<Map<String, dynamic>>? photoMetadata; // Optional metadata for each photo

  const ProgressPhotoViewerWidget({
    super.key,
    required this.photos,
    this.title = 'Foto Progress',
    this.emptyMessage = 'Tidak ada foto progress',
    this.photoMetadata,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radius12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          children: [
            Icon(
              Icons.timeline,
              size: 48,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: AppTheme.spacing12),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.timeline,
              size: 20,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: AppTheme.spacing8),
            Text(
              '$title (${photos.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppTheme.spacing8,
            mainAxisSpacing: AppTheme.spacing8,
            childAspectRatio: 0.8,
          ),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            return _buildProgressPhotoItem(context, photos[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildProgressPhotoItem(BuildContext context, String photoPath, int index) {
    final metadata = photoMetadata != null && index < photoMetadata!.length 
        ? photoMetadata![index] 
        : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.shadowSm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Image
            Expanded(
              child: GestureDetector(
                onTap: () => _viewPhoto(context, photoPath),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                  ),
                  child: File(photoPath).existsSync()
                      ? Image.file(
                          File(photoPath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.backgroundColor,
                              child: const Icon(
                                Icons.broken_image,
                                color: AppTheme.textTertiary,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppTheme.backgroundColor,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                ),
              ),
            ),
            
            // Metadata section
            if (metadata != null) ...[
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (metadata['date'] != null)
                      Text(
                        metadata['date'],
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (metadata['progress'] != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: metadata['progress'] / 100,
                              backgroundColor: AppTheme.borderColor,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacing8),
                          Text(
                            '${metadata['progress']}%',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (metadata['description'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        metadata['description'],
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _viewPhoto(BuildContext context, String photoPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewerScreen(photoPath: photoPath),
      ),
    );
  }
}