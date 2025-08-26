// lib/screens/temuan/temuan_screen.dart
import 'package:flutter/material.dart';
import 'temuan_form_screen.dart';
import '../../model/temuan.dart';
import '../../services/local_storage_service.dart';
import '../../config/category_config.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/photo_widgets.dart';

class TemuanScreen extends StatefulWidget {
  const TemuanScreen({super.key});

  @override
  State<TemuanScreen> createState() => _TemuanScreenState();
}

class _TemuanScreenState extends State<TemuanScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final LocalStorageService _storageService = LocalStorageService();
  
  List<Temuan> _temuanList = [];
  bool _isLoading = false;
  String _selectedFilter = 'Semua';

  final List<String> _filterOptions = ['Semua', 'Pending', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTemuanData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTemuanData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final temuanList = await _storageService.getAllTemuan();
      setState(() {
        _temuanList = temuanList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Gagal memuat data temuan');
    }
  }

  List<Temuan> get _filteredTemuanList {
    if (_selectedFilter == 'Semua') {
      return _temuanList;
    }
    return _temuanList.where((temuan) {
      switch (_selectedFilter) {
        case 'Pending':
          return temuan.status == 'pending';
        case 'In Progress':
          return temuan.status == 'in_progress';
        case 'Completed':
          return temuan.status == 'completed';
        default:
          return true;
      }
    }).toList();
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Temuan'),
          centerTitle: true,
          backgroundColor: AppTheme.surfaceColor,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Buat Temuan', icon: Icon(Icons.add_circle_outline)),
              Tab(text: 'Daftar Temuan', icon: Icon(Icons.list_alt)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCreateTemuanTab(),
            _buildTemuanListTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateTemuanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.infoColor.withOpacity(0.1),
                  AppTheme.primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radius16),
              border: Border.all(color: AppTheme.infoColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radius8),
                  ),
                  child: Icon(Icons.info_outline, color: AppTheme.infoColor),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Kategori Temuan',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.infoColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        'Pilih kategori sesuai jenis temuan untuk melanjutkan pelaporan',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing24),

          // Categories grid
          Text(
            'Kategori Temuan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppTheme.spacing16,
              mainAxisSpacing: AppTheme.spacing16,
              childAspectRatio: 1.0,
            ),
            itemCount: AppCategoryConfigs.configs.length,
            itemBuilder: (context, index) {
              final categoryKey = AppCategoryConfigs.configs.keys.elementAt(index);
              final config = AppCategoryConfigs.configs[categoryKey]!;
              return _buildCategoryCard(categoryKey, config);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String categoryKey, CategoryConfig config) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToTemuanForm(preselectedCategory: categoryKey),
          borderRadius: BorderRadius.circular(AppTheme.radius16),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: config.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radius12),
                  ),
                  child: Icon(
                    config.icon,
                    size: 24,
                    color: config.color,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing6),
                Flexible(
                  child: Text(
                    config.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing2),
                Text(
                  '${config.subcategories.length} jenis',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing8,
                    vertical: AppTheme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: config.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radius8),
                  ),
                  child: Text(
                    'Laporkan',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: config.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemuanListTab() {
    return Column(
      children: [
        // Filter Section
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            border: Border(
              bottom: BorderSide(color: AppTheme.borderColor),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing12,
                      vertical: AppTheme.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radius8),
                    ),
                    child: Text(
                      '${_filteredTemuanList.length} item',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filterOptions.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    final count = _getFilterCount(filter);
                    
                    return Container(
                      margin: const EdgeInsets.only(right: AppTheme.spacing8),
                      child: FilterChip(
                        label: Text('$filter ($count)'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        backgroundColor: AppTheme.backgroundColor,
                        selectedColor: AppTheme.primaryColor.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _filteredTemuanList.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadTemuanData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppTheme.spacing20),
                        itemCount: _filteredTemuanList.length,
                        itemBuilder: (context, index) {
                          final temuan = _filteredTemuanList[index];
                          return _buildTemuanCard(temuan);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  int _getFilterCount(String filter) {
    if (filter == 'Semua') return _temuanList.length;
    return _temuanList.where((t) {
      switch (filter) {
        case 'Pending':
          return t.status == 'pending';
        case 'In Progress':
          return t.status == 'in_progress';
        case 'Completed':
          return t.status == 'completed';
        default:
          return false;
      }
    }).length;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radius20),
              border: Border.all(color: AppTheme.borderColor),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  decoration: BoxDecoration(
                    color: AppTheme.textTertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radius16),
                  ),
                  child: Icon(
                    Icons.search_off,
                    size: 48,
                    color: AppTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                Text(
                  _selectedFilter == 'Semua' ? 'Belum ada temuan' : 'Tidak ada temuan $_selectedFilter',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  _selectedFilter == 'Semua'
                      ? 'Mulai dengan menambah temuan baru'
                      : 'Coba ubah filter atau tambah temuan baru',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing20),
                ElevatedButton.icon(
                  onPressed: () {
                    _tabController.animateTo(0);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Temuan'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemuanCard(Temuan temuan) {
    final categoryConfig = AppCategoryConfigs.getConfig(temuan.category);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTemuanDetail(temuan),
          borderRadius: BorderRadius.circular(AppTheme.radius16),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing8),
                      decoration: BoxDecoration(
                        color: (categoryConfig?.color ?? Helpers.getStatusColor(temuan.status)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radius8),
                      ),
                      child: Icon(
                        categoryConfig?.icon ?? Helpers.getCategoryIcon(temuan.category),
                        color: categoryConfig?.color ?? Helpers.getStatusColor(temuan.status),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            temuan.description,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppTheme.spacing4),
                          Text(
                            'KM ${temuan.kmPoint} • ${temuan.section} • ${categoryConfig?.name ?? temuan.category}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) => _handleMenuAction(value, temuan),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: AppTheme.spacing8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: AppTheme.errorColor),
                              SizedBox(width: AppTheme.spacing8),
                              Text('Hapus', style: TextStyle(color: AppTheme.errorColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing8,
                        vertical: AppTheme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: Helpers.getPriorityColor(temuan.priority).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radius8),
                      ),
                      child: Text(
                        Helpers.getPriorityText(temuan.priority),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Helpers.getPriorityColor(temuan.priority),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing8,
                        vertical: AppTheme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: Helpers.getStatusColor(temuan.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radius8),
                      ),
                      child: Text(
                        Helpers.getStatusText(temuan.status),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Helpers.getStatusColor(temuan.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormatter.formatRelativeTime(temuan.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTemuanDetail(Temuan temuan) {
    final categoryConfig = AppCategoryConfigs.getConfig(temuan.category);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radius20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with close button
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacing12),
                          decoration: BoxDecoration(
                            color: (categoryConfig?.color ?? Helpers.getStatusColor(temuan.status)).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radius12),
                          ),
                          child: Icon(
                            categoryConfig?.icon ?? Helpers.getCategoryIcon(temuan.category),
                            color: categoryConfig?.color ?? Helpers.getStatusColor(temuan.status),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detail Temuan',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacing4),
                              Text(
                                categoryConfig?.name ?? temuan.category,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing24),

                    // Status and Priority Tags
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing12,
                            vertical: AppTheme.spacing6,
                          ),
                          decoration: BoxDecoration(
                            color: Helpers.getStatusColor(temuan.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radius8),
                          ),
                          child: Text(
                            Helpers.getStatusText(temuan.status),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Helpers.getStatusColor(temuan.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing12,
                            vertical: AppTheme.spacing6,
                          ),
                          decoration: BoxDecoration(
                            color: Helpers.getPriorityColor(temuan.priority).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radius8),
                          ),
                          child: Text(
                            Helpers.getPriorityText(temuan.priority),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Helpers.getPriorityColor(temuan.priority),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing24),

                    // Information sections
                    _buildDetailSection('Deskripsi', [
                      _buildDetailItem('Deskripsi', temuan.description, isDescription: true),
                      _buildDetailItem('Kategori', '${categoryConfig?.name ?? temuan.category} - ${temuan.subcategory}'),
                    ]),
                    const SizedBox(height: AppTheme.spacing20),

                    _buildDetailSection('Lokasi', [
                      _buildDetailItem('Seksi', temuan.section),
                      _buildDetailItem('KM Point', temuan.kmPoint),
                      if (temuan.lane != 'N/A')
                        _buildDetailItem('Lajur', temuan.lane),
                      if (temuan.latitude != 0.0 || temuan.longitude != 0.0)
                        _buildDetailItem('Koordinat', '${temuan.latitude}, ${temuan.longitude}'),
                    ]),
                    const SizedBox(height: AppTheme.spacing20),

                    _buildDetailSection('Informasi Tambahan', [
                      _buildDetailItem('Dibuat Oleh', temuan.createdBy),
                      _buildDetailItem('Tanggal Dibuat', DateFormatter.formatDateTime(temuan.createdAt)),
                      if (temuan.updatedAt != null)
                        _buildDetailItem('Terakhir Diupdate', DateFormatter.formatDateTime(temuan.updatedAt!)),
                      if (temuan.notes != null && temuan.notes!.isNotEmpty)
                        _buildDetailItem('Catatan', temuan.notes!, isDescription: true),
                    ]),
                    const SizedBox(height: AppTheme.spacing20),

                    // Foto section
                    _buildDetailSection('Foto', [
                      PhotoViewerWidget(
                        photos: temuan.photos,
                        title: 'Foto Temuan',
                        emptyMessage: 'Tidak ada foto untuk temuan ini',
                      ),
                    ]),

                    const SizedBox(height: AppTheme.spacing32),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _navigateToTemuanForm(temuanId: temuan.id);
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigate to create perbaikan with this temuan
                              Navigator.pushNamed(context, '/perbaikan');
                            },
                            icon: const Icon(Icons.build),
                            label: const Text('Buat Perbaikan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(AppTheme.radius12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isDescription = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: isDescription ? null : 1,
              overflow: isDescription ? null : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, Temuan temuan) {
    switch (action) {
      case 'edit':
        _navigateToTemuanForm(temuanId: temuan.id);
        break;
      case 'delete':
        _confirmDeleteTemuan(temuan);
        break;
    }
  }

  void _confirmDeleteTemuan(Temuan temuan) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Temuan'),
          content: Text('Apakah Anda yakin ingin menghapus temuan "${temuan.description}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteTemuan(temuan.id);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTemuan(String temuanId) async {
    try {
      await _storageService.deleteTemuan(temuanId);
      _showSuccessSnackBar('Temuan berhasil dihapus');
      _loadTemuanData();
    } catch (e) {
      _showErrorSnackBar('Gagal menghapus temuan');
    }
  }

  void _navigateToTemuanForm({String? temuanId, String? preselectedCategory}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemuanFormScreen(
          temuanId: temuanId,
          preselectedCategory: preselectedCategory,
        ),
      ),
    );

    if (result == true) {
      _loadTemuanData();
    }
  }
}