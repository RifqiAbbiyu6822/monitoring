// lib/widgets/photo_widgets.dart - Fixed Implementation
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/photo_service.dart';
import '../utils/theme.dart';


class PhotoPickerWidget extends StatefulWidget {
  final List<String> initialPhotos;
  final ValueChanged<List<String>> onPhotosChanged;
  final int maxPhotos;
  final String title;
  final String subtitle;

  const PhotoPickerWidget({
    super.key,
    required this.initialPhotos,
    required this.onPhotosChanged,
    this.maxPhotos = 5,
    this.title = 'Foto',
    this.subtitle = 'Dokumentasi foto',
  });

  @override
  State<PhotoPickerWidget> createState() => _PhotoPickerWidgetState();
}

class _PhotoPickerWidgetState extends State<PhotoPickerWidget> {
  late List<String> _photos;
  final PhotoService _photoService = PhotoService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _photos = List.from(widget.initialPhotos);
  }

  @override
  void didUpdateWidget(PhotoPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPhotos != widget.initialPhotos) {
      _photos = List.from(widget.initialPhotos);
    }
  }

  Future<void> _addPhoto() async {
    if (_photos.length >= widget.maxPhotos) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final photoPath = await _photoService.handlePhotoAction(context);
      if (photoPath != null && photoPath.isNotEmpty) {
        setState(() {
          _photos.add(photoPath);
        });
        widget.onPhotosChanged(_photos);
      }
    } catch (e) {
      _showErrorSnackBar('Gagal menambah foto: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removePhoto(String photoPath) {
    setState(() {
      _photos.remove(photoPath);
    });
    widget.onPhotosChanged(_photos);
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(
              Icons.photo_library,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _photos.length >= widget.maxPhotos
                            ? AppTheme.warningColor.withValues(alpha: 0.1)
        : AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_photos.length}/${widget.maxPhotos}',
                style: TextStyle(
                  color: _photos.length >= widget.maxPhotos
                      ? AppTheme.warningColor
                      : AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // Photo grid
        if (_photos.isEmpty) ...[
          _buildEmptyState(),
        ] else ...[
          _buildPhotoGrid(),
          if (_photos.length < widget.maxPhotos) ...[
            const SizedBox(height: 12),
            _buildAddButton(),
          ],
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor,
          style: BorderStyle.solid,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 48,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada foto',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan foto untuk dokumentasi',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textTertiary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _addPhoto,
              icon: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Icon(Icons.add_photo_alternate, size: 18),
              label: const Text('Tambah Foto'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        return _buildPhotoItem(_photos[index], index);
      },
    );
  }

  Widget _buildPhotoItem(String photoPath, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildPhotoImage(photoPath),
            _buildPhotoOverlay(photoPath, index),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoImage(String photoPath) {
    final file = File(photoPath);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorState();
        },
      );
    } else {
      return _buildErrorState();
    }
  }

  Widget _buildErrorState() {
    return Container(
      color: AppTheme.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: AppTheme.textTertiary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            'Error',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoOverlay(String photoPath, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.5),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Photo number
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Delete button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _showDeleteDialog(photoPath),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Center(
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _addPhoto,
        icon: _isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              )
            : const Icon(Icons.add_photo_alternate, size: 18),
        label: const Text('Tambah Foto Lagi'),
      ),
    );
  }

  void _showDeleteDialog(String photoPath) {
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
              _removePhoto(photoPath);
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

// Simple photo viewer widget
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
        height: 120,
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 32,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(height: 8),
              Text(
                emptyMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Flexible(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.0,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photoPath = photos[index];
          return GestureDetector(
            onTap: () => _viewPhoto(context, photoPath),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImage(photoPath),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(String photoPath) {
    final file = File(photoPath);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorImage();
        },
      );
    } else {
      return _buildErrorImage();
    }
  }

  Widget _buildErrorImage() {
    return Container(
      color: AppTheme.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
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

  void _viewPhoto(BuildContext context, String photoPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewScreen(photoPath: photoPath),
      ),
    );
  }
}

// Progress photo viewer widget
class ProgressPhotoViewerWidget extends StatelessWidget {
  final List<String> photos;
  final String title;
  final String emptyMessage;

  const ProgressPhotoViewerWidget({
    super.key,
    required this.photos,
    this.title = 'Progress Photos',
    this.emptyMessage = 'No progress photos',
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 32,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(height: 8),
              Text(
                emptyMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
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
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${photos.length} foto',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Flexible(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photoPath = photos[index];
              return GestureDetector(
                onTap: () => _viewPhoto(context, photoPath, index),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImage(photoPath),
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String photoPath) {
    final file = File(photoPath);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppTheme.backgroundColor,
            child: Icon(
              Icons.broken_image,
              color: AppTheme.textTertiary,
              size: 24,
            ),
          );
        },
      );
    } else {
      return Container(
        color: AppTheme.backgroundColor,
        child: Icon(
          Icons.image_not_supported,
          color: AppTheme.textTertiary,
          size: 24,
        ),
      );
    }
  }

  void _viewPhoto(BuildContext context, String photoPath, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewScreen(
          photoPath: photoPath,
          title: 'Progress Photo ${index + 1}',
        ),
      ),
    );
  }
}

// Full screen photo viewer
class PhotoViewScreen extends StatelessWidget {
  final String photoPath;
  final String? title;

  const PhotoViewScreen({
    super.key,
    required this.photoPath,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: title != null ? Text(title!) : null,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final file = File(photoPath);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorState();
        },
      );
    } else {
      return _buildErrorState();
    }
  }

  Widget _buildErrorState() {
    return const Column(
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
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}