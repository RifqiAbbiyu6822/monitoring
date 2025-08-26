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
            height: 200,
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
                if (canEdit && onAddPhoto != null) ...[
                  const SizedBox(height: AppTheme.spacing16),
                  ElevatedButton.icon(
                    onPressed: onAddPhoto,
                    icon: const Icon(Icons.add_a_photo, size: 20),
                    label: const Text('Tambah Foto'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing20,
                        vertical: AppTheme.spacing12,
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
                fontWeight: FontWeight.w600,
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDeletePhoto?.call(photoPath);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// Widget untuk menampilkan foto tunggal
class PhotoViewWidget extends StatelessWidget {
  final String photoPath;
  final String? title;
  final bool showControls;
  final VoidCallback? onDelete;
  final VoidCallback? onReplace;

  const PhotoViewWidget({
    super.key,
    required this.photoPath,
    this.title,
    this.showControls = true,
    this.onDelete,
    this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          
          // Photo container
          Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radius8),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radius8),
              child: photoPath.isNotEmpty && File(photoPath).existsSync()
                  ? GestureDetector(
                      onTap: () => _showFullScreenPhoto(context),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(photoPath),
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      color: AppTheme.backgroundColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 48,
                            color: AppTheme.textTertiary,
                          ),
                          const SizedBox(height: AppTheme.spacing12),
                          Text(
                            'Belum ada foto',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          
          // Controls
          if (showControls) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacing16,
                0,
                AppTheme.spacing16,
                AppTheme.spacing16,
              ),
              child: Row(
                children: [
                  if (photoPath.isEmpty || !File(photoPath).existsSync()) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onReplace,
                        icon: const Icon(Icons.add_a_photo, size: 20),
                        label: const Text('Tambah Foto'),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReplace,
                        icon: const Icon(Icons.photo_camera, size: 20),
                        label: const Text('Ganti Foto'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 20),
                      label: const Text('Hapus'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: BorderSide(color: AppTheme.errorColor),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFullScreenPhoto(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenPhotoViewer(photoPath: photoPath),
      ),
    );
  }
}

// Widget untuk melihat foto fullscreen
class FullScreenPhotoViewer extends StatelessWidget {
  final String photoPath;

  const FullScreenPhotoViewer({
    super.key,
    required this.photoPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _sharePhoto(),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: File(photoPath).existsSync()
              ? Image.file(
                  File(photoPath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Gagal memuat foto',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        color: Colors.white,
                        size: 64,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Foto tidak ditemukan',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void _sharePhoto() {
    // Implementasi share foto jika diperlukan
    print('Share photo: $photoPath');
  }
}

// Widget untuk photo picker dengan preview
class PhotoPickerWidget extends StatefulWidget {
  final List<String> initialPhotos;
  final Function(List<String>) onPhotosChanged;
  final int maxPhotos;
  final String title;
  final String subtitle;

  const PhotoPickerWidget({
    super.key,
    this.initialPhotos = const [],
    required this.onPhotosChanged,
    this.maxPhotos = 5,
    this.title = 'Foto',
    this.subtitle = 'Tambahkan foto untuk dokumentasi',
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
    try {
      final photoPath = await _photoService.handlePhotoAction(context);
      if (photoPath != null) {
        setState(() {
          _photos.add(photoPath);
        });
        widget.onPhotosChanged(_photos);
      }
    } catch (e) {
      _showErrorSnackBar('Gagal menambah foto: $e');
    }
  }

  Future<void> _deletePhoto(String photoPath) async {
    try {
      await _photoService.deletePhoto(photoPath);
      setState(() {
        _photos.remove(photoPath);
      });
      widget.onPhotosChanged(_photos);
      _showSuccessSnackBar('Foto berhasil dihapus');
    } catch (e) {
      _showErrorSnackBar('Gagal menghapus foto: $e');
    }
  }

  void _viewPhoto(String photoPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenPhotoViewer(photoPath: photoPath),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
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
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
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