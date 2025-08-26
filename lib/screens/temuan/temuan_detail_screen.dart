// lib/screens/temuan/temuan_detail_screen.dart - Enhanced Detail View
import 'package:flutter/material.dart';
import '../../model/temuan.dart';
import '../../config/category_config.dart';
import '../../utils/theme.dart';
import '../../utils/date_formatter.dart';
import '../../utils/helpers.dart';
import '../../widgets/photo_widgets.dart';
import '../../widgets/form_components.dart';

class TemuanDetailScreen extends StatefulWidget {
  final Temuan temuan;
  final bool canEdit;

  const TemuanDetailScreen({
    super.key,
    required this.temuan,
    this.canEdit = true,
  });

  @override
  State<TemuanDetailScreen> createState() => _TemuanDetailScreenState();
}

class _TemuanDetailScreenState extends State<TemuanDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryConfig = AppCategoryConfigs.getConfig(widget.temuan.category);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(categoryConfig),
      body: Column(
        children: [
          // Header with status and priority
          _buildHeader(categoryConfig),
          
          // Tab bar
          _buildTabBar(),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(),
                _buildPhotosTab(),
                _buildLocationTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.canEdit ? _buildFloatingActionButton() : null,
    );
  }

  PreferredSizeWidget _buildAppBar(CategoryConfig? categoryConfig) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.textPrimary,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Temuan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            categoryConfig?.name ?? widget.temuan.category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        if (widget.canEdit)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'create_perbaikan',
                child: Row(
                  children: [
                    Icon(Icons.build_outlined, size: 18),
                    SizedBox(width: 12),
                    Text('Buat Perbaikan'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outlined, size: 18, color: AppTheme.errorColor),
                    SizedBox(width: 12),
                    Text('Hapus', style: TextStyle(color: AppTheme.errorColor)),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildHeader(CategoryConfig? categoryConfig) {
    return ModernCard(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Category icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (categoryConfig?.color ?? AppTheme.primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  categoryConfig?.icon ?? Icons.construction,
                  color: categoryConfig?.color ?? AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.temuan.description,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${categoryConfig?.name ?? widget.temuan.category} • ${widget.temuan.subcategory}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Status and Priority badges
          Row(
            children: [
              _buildStatusBadge(widget.temuan.status),
              const SizedBox(width: 12),
              _buildPriorityBadge(widget.temuan.priority),
              const Spacer(),
              
              // Created info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormatter.formatRelativeTime(widget.temuan.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'oleh ${widget.temuan.createdBy}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Location info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.borderColor.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Seksi ${widget.temuan.section} • KM ${widget.temuan.kmPoint} • ${widget.temuan.lane}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.primaryColor,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: [
          Tab(
            icon: Icon(Icons.info_outline, size: 18),
            text: 'Informasi',
          ),
          Tab(
            icon: Icon(Icons.photo_library_outlined, size: 18),
            text: 'Foto (${widget.temuan.photos.length})',
          ),
          Tab(
            icon: Icon(Icons.map_outlined, size: 18),
            text: 'Lokasi',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            'Detail Temuan',
            [
              _buildInfoRow('ID Temuan', widget.temuan.id),
              _buildInfoRow('Kategori', '${widget.temuan.category} - ${widget.temuan.subcategory}'),
              _buildInfoRow('Status', Helpers.getStatusText(widget.temuan.status)),
              _buildInfoRow('Prioritas', Helpers.getPriorityText(widget.temuan.priority)),
              _buildInfoRow('Tanggal Temuan', DateFormatter.formatDateTime(widget.temuan.createdAt)),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildInfoSection(
            'Lokasi Detail',
            [
              _buildInfoRow('Seksi', widget.temuan.section),
              _buildInfoRow('KM Point', widget.temuan.kmPoint),
              _buildInfoRow('Lajur', widget.temuan.lane),
              if (widget.temuan.latitude != 0.0 || widget.temuan.longitude != 0.0)
                _buildInfoRow('Koordinat GPS', '${widget.temuan.latitude.toStringAsFixed(6)}, ${widget.temuan.longitude.toStringAsFixed(6)}'),
            ],
          ),
          const SizedBox(height: 24),
          
          if (widget.temuan.notes != null && widget.temuan.notes!.isNotEmpty) ...[
            _buildInfoSection(
              'Catatan Tambahan',
              [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.borderColor.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    widget.temuan.notes!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          
          _buildInfoSection(
            'Informasi Sistem',
            [
              _buildInfoRow('Dibuat Oleh', widget.temuan.createdBy),
              _buildInfoRow('Tanggal Dibuat', DateFormatter.formatDateTime(widget.temuan.createdAt)),
              if (widget.temuan.updatedAt != null) ...[
                _buildInfoRow('Terakhir Diupdate', DateFormatter.formatDateTime(widget.temuan.updatedAt!)),
                if (widget.temuan.updatedBy != null)
                  _buildInfoRow('Diupdate Oleh', widget.temuan.updatedBy!),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.temuan.photos.isEmpty) ...[
            _buildEmptyPhotosState(),
          ] else ...[
            ModernPhotoGrid(
              photos: widget.temuan.photos,
              canEdit: false,
              title: 'Dokumentasi Temuan',
              onViewPhoto: (photoPath) => _viewPhoto(photoPath),
            ),
            const SizedBox(height: 24),
            
            // Photo metadata
            _buildPhotoMetadata(),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location overview card
          ModernCard(
            child: Column(
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
                        Icons.location_on,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Informasi Lokasi',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                _buildLocationDetail('Seksi Jalan Tol', widget.temuan.section, Icons.route),
                const SizedBox(height: 16),
                _buildLocationDetail('Kilometer Point', widget.temuan.kmPoint, Icons.straighten),
                const SizedBox(height: 16),
                _buildLocationDetail('Lajur/Posisi', widget.temuan.lane, Icons.directions_car),
                
                if (widget.temuan.latitude != 0.0 || widget.temuan.longitude != 0.0) ...[
                  const SizedBox(height: 16),
                  _buildLocationDetail(
                    'Koordinat GPS',
                    '${widget.temuan.latitude.toStringAsFixed(6)}, ${widget.temuan.longitude.toStringAsFixed(6)}',
                    Icons.gps_fixed,
                  ),
                  const SizedBox(height: 20),
                  
                  // GPS accuracy info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.successColor.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.successColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Koordinat GPS tersedia - lokasi dapat dipetakan dengan akurat',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.warningColor.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: AppTheme.warningColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Koordinat GPS tidak tersedia - lokasi hanya berdasarkan deskripsi manual',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.warningColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Map placeholder or actual map integration
          const SizedBox(height: 24),
          _buildMapPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusColor = Helpers.getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            Helpers.getStatusText(status),
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    final priorityColor = Helpers.getPriorityColor(priority);
    final priorityData = PriorityConfig.getPriorityData(priority);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: priorityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            priorityData?.icon ?? Icons.flag,
            color: priorityColor,
            size: 12,
          ),
          const SizedBox(width: 6),
          Text(
            Helpers.getPriorityText(priority),
            style: TextStyle(
              color: priorityColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPhotosState() {
    return ModernCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(16),
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
                    Icons.photo_library_outlined,
                    size: 48,
                    color: AppTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak Ada Foto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tidak ada dokumentasi foto untuk temuan ini',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoMetadata() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.infoColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Informasi Foto',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildPhotoMetadataRow('Total Foto', '${widget.temuan.photos.length} file'),
          _buildPhotoMetadataRow('Tanggal Upload', DateFormatter.formatDateTime(widget.temuan.createdAt)),
          _buildPhotoMetadataRow('Kualitas', 'Resolusi tinggi (1920x1080)'),
          _buildPhotoMetadataRow('Format', 'JPEG dengan kompresi optimal'),
        ],
      ),
    );
  }

  Widget _buildPhotoMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.infoColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.infoColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapPlaceholder() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.map_outlined,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Peta Lokasi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.borderColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 48,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Integrasi Peta',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fitur peta akan tersedia di versi mendatang',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _handleMenuAction('create_perbaikan'),
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.build_outlined),
      label: const Text(
        'Buat Perbaikan',
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        Navigator.pushNamed(
          context,
          '/temuan/edit',
          arguments: widget.temuan.id,
        );
        break;
      case 'create_perbaikan':
        Navigator.pushNamed(
          context,
          '/perbaikan/create',
          arguments: widget.temuan,
        );
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_outlined, color: AppTheme.errorColor),
            const SizedBox(width: 12),
            const Text('Hapus Temuan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin ingin menghapus temuan ini?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Tindakan ini tidak dapat dibatalkan dan akan menghapus semua data terkait.',
                style: TextStyle(
                  color: AppTheme.warningColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, 'deleted');
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

  void _viewPhoto(String photoPath) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: EnhancedPhotoViewer(
              photoPath: photoPath,
              title: 'Foto Temuan',
              subtitle: widget.temuan.description,
            ),
          );
        },
      ),
    );
  }
}

// Enhanced Photo Viewer with better UI
class EnhancedPhotoViewer extends StatelessWidget {
  final String photoPath;
  final String title;
  final String? subtitle;

  const EnhancedPhotoViewer({
    super.key,
    required this.photoPath,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Implement photo sharing
            },
          ),
        ],
      ),
      body: Center(
        child: Hero(
          tag: photoPath,
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.file(
              File(photoPath),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Gagal memuat foto',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'File mungkin telah dipindah atau dihapus',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}