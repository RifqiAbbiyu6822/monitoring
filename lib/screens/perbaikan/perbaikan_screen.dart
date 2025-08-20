// lib/screens/perbaikan/perbaikan_screen.dart
import 'package:flutter/material.dart';
import 'perbaikan_form_screen.dart';
import '../../model/perbaikan.dart';
import '../../model/temuan.dart';
import '../../services/local_storage_service.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../utils/date_formatter.dart';

class PerbaikanScreen extends StatefulWidget {
  const PerbaikanScreen({super.key});

  @override
  State<PerbaikanScreen> createState() => _PerbaikanScreenState();
}

class _PerbaikanScreenState extends State<PerbaikanScreen> {
  final LocalStorageService _storageService = LocalStorageService();
  
  List<Perbaikan> _perbaikanList = [];
  List<Temuan> _availableTemuan = [];
  bool _isLoading = false;
  String _selectedFilter = 'Semua';

  final List<String> _filterOptions = ['Semua', 'Pending', 'Ongoing', 'Selesai', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final perbaikanList = await _storageService.getAllPerbaikan();
      final temuanList = await _storageService.getAllTemuan();
      
      // Filter temuan that don't have perbaikan yet
      final temuanWithPerbaikan = perbaikanList.map((p) => p.temuanId).toSet();
      final availableTemuan = temuanList.where((t) => !temuanWithPerbaikan.contains(t.id)).toList();

      setState(() {
        _perbaikanList = perbaikanList;
        _availableTemuan = availableTemuan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Gagal memuat data perbaikan');
    }
  }

  List<Perbaikan> get _filteredPerbaikanList {
    if (_selectedFilter == 'Semua') {
      return _perbaikanList;
    }
    return _perbaikanList.where((perbaikan) {
      switch (_selectedFilter) {
        case 'Pending':
          return perbaikan.status == 'pending';
        case 'Ongoing':
          return perbaikan.status == 'ongoing';
        case 'Selesai':
          return perbaikan.status == 'selesai';
        case 'Cancelled':
          return perbaikan.status == 'cancelled';
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Perbaikan'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.surfaceColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.add),
            onSelected: (value) {
              if (value == 'new') {
                _navigateToPerbaikanForm();
              } else if (value == 'from_temuan') {
                _showAvailableTemuanDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, size: 20),
                    SizedBox(width: AppTheme.spacing8),
                    Text('Perbaikan Baru'),
                  ],
                ),
              ),
              if (_availableTemuan.isNotEmpty)
                const PopupMenuItem(
                  value: 'from_temuan',
                  child: Row(
                    children: [
                      Icon(Icons.build_circle_outlined, size: 20),
                      SizedBox(width: AppTheme.spacing8),
                      Text('Dari Temuan'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter and Stats Section
          _buildFilterSection(),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPerbaikanList.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppTheme.spacing20),
                          itemCount: _filteredPerbaikanList.length,
                          itemBuilder: (context, index) {
                            final perbaikan = _filteredPerbaikanList[index];
                            return _buildPerbaikanCard(perbaikan);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
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
                  '${_filteredPerbaikanList.length} item',
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
          if (_availableTemuan.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacing12),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radius8),
                border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.infoColor,
                    size: 16,
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Expanded(
                    child: Text(
                      '${_availableTemuan.length} temuan belum memiliki perbaikan',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.infoColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _showAvailableTemuanDialog,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.infoColor,
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing8),
                    ),
                    child: const Text('Lihat'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  int _getFilterCount(String filter) {
    if (filter == 'Semua') return _perbaikanList.length;
    return _perbaikanList.where((p) {
      switch (filter) {
        case 'Pending':
          return p.status == 'pending';
        case 'Ongoing':
          return p.status == 'ongoing';
        case 'Selesai':
          return p.status == 'selesai';
        case 'Cancelled':
          return p.status == 'cancelled';
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
                    Icons.construction_outlined,
                    size: 48,
                    color: AppTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                Text(
                  _selectedFilter == 'Semua' ? 'Belum ada perbaikan' : 'Tidak ada perbaikan $_selectedFilter',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  _selectedFilter == 'Semua'
                      ? 'Mulai dengan menambah perbaikan baru'
                      : 'Coba ubah filter atau tambah perbaikan baru',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _navigateToPerbaikanForm,
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Perbaikan'),
                    ),
                    if (_availableTemuan.isNotEmpty) ...[
                      const SizedBox(width: AppTheme.spacing12),
                      OutlinedButton.icon(
                        onPressed: _showAvailableTemuanDialog,
                        icon: const Icon(Icons.build_circle_outlined),
                        label: const Text('Dari Temuan'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerbaikanCard(Perbaikan perbaikan) {
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
          onTap: () => _showPerbaikanDetail(perbaikan),
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
                        color: Helpers.getStatusColor(perbaikan.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radius8),
                      ),
                      child: Icon(
                        Helpers.getCategoryIcon(perbaikan.category),
                        color: Helpers.getStatusColor(perbaikan.status),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            perbaikan.workDescription,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppTheme.spacing4),
                          Text(
                            'KM ${perbaikan.kmPoint} • ${perbaikan.assignedTo}',
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
                      onSelected: (value) => _handleMenuAction(value, perbaikan),
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
                          value: 'update_progress',
                          child: Row(
                            children: [
                              Icon(Icons.timeline, size: 16),
                              SizedBox(width: AppTheme.spacing8),
                              Text('Update Progress'),
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
                
                // Progress Bar
                if (perbaikan.progress != null && perbaikan.progress! > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${perbaikan.progress!.toInt()}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  LinearProgressIndicator(
                    value: perbaikan.progress! / 100,
                    backgroundColor: AppTheme.borderColor,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    borderRadius: BorderRadius.circular(AppTheme.radius4),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                ],

                // Status and Info Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing8,
                        vertical: AppTheme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: Helpers.getStatusColor(perbaikan.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radius8),
                      ),
                      child: Text(
                        Helpers.getStatusText(perbaikan.status),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Helpers.getStatusColor(perbaikan.status),
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
                        color: AppTheme.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radius8),
                      ),
                      child: Text(
                        perbaikan.contractor,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormatter.formatRelativeTime(perbaikan.createdAt),
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

  void _showAvailableTemuanDialog() {
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
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: AppTheme.spacing8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacing12),
                        decoration: BoxDecoration(
                          color: AppTheme.infoColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radius12),
                        ),
                        child: Icon(
                          Icons.build_circle_outlined,
                          color: AppTheme.infoColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Temuan Tersedia',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${_availableTemuan.length} temuan belum memiliki perbaikan',
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
                const Divider(height: 1),
                Expanded(
                  child: _availableTemuan.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 48,
                                color: AppTheme.successColor,
                              ),
                              const SizedBox(height: AppTheme.spacing16),
                              Text(
                                'Semua temuan sudah memiliki perbaikan',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _availableTemuan.length,
                          itemBuilder: (context, index) {
                            final temuan = _availableTemuan[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing20,
                                vertical: AppTheme.spacing8,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(AppTheme.spacing8),
                                decoration: BoxDecoration(
                                  color: Helpers.getPriorityColor(temuan.priority).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppTheme.radius8),
                                ),
                                child: Icon(
                                  Helpers.getCategoryIcon(temuan.category),
                                  color: Helpers.getPriorityColor(temuan.priority),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                temuan.description,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: AppTheme.spacing4),
                                  Text(
                                    'KM ${temuan.kmPoint} • ${temuan.section}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacing4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppTheme.spacing6,
                                          vertical: AppTheme.spacing2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Helpers.getPriorityColor(temuan.priority).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(AppTheme.radius4),
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
                                      Text(
                                        DateFormatter.formatRelativeTime(temuan.createdAt),
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppTheme.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _navigateToPerbaikanForm(temuan: temuan);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.spacing12,
                                    vertical: AppTheme.spacing8,
                                  ),
                                ),
                                child: const Text('Buat Perbaikan'),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPerbaikanDetail(Perbaikan perbaikan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radius20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacing12),
                          decoration: BoxDecoration(
                            color: Helpers.getStatusColor(perbaikan.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radius12),
                          ),
                          child: Icon(
                            Helpers.getCategoryIcon(perbaikan.category),
                            color: Helpers.getStatusColor(perbaikan.status),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detail Perbaikan',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacing4),
                              Text(
                                'ID: ${perbaikan.id}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

                    // Progress Section
                    if (perbaikan.progress != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacing20),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(AppTheme.radius16),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress Pekerjaan',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${perbaikan.progress!.toInt()}%',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacing12),
                            LinearProgressIndicator(
                              value: perbaikan.progress! / 100,
                              backgroundColor: AppTheme.borderColor,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                              borderRadius: BorderRadius.circular(AppTheme.radius4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing20),
                    ],

                    // Details Sections
                    _buildDetailSection('Informasi Umum', [
                      _buildDetailItem('Deskripsi Pekerjaan', perbaikan.workDescription, isDescription: true),
                      _buildDetailItem('Kategori', '${perbaikan.category} - ${perbaikan.subcategory}'),
                      _buildDetailItem('Status', Helpers.getStatusText(perbaikan.status)),
                      _buildDetailItem('Kontraktor', perbaikan.contractor),
                      _buildDetailItem('Assigned To', perbaikan.assignedTo),
                    ]),
                    const SizedBox(height: AppTheme.spacing20),

                    _buildDetailSection('Lokasi', [
                      _buildDetailItem('Seksi', perbaikan.section),
                      _buildDetailItem('KM Point', perbaikan.kmPoint),
                      _buildDetailItem('Lajur', perbaikan.lane),
                    ]),
                    const SizedBox(height: AppTheme.spacing20),

                    _buildDetailSection('Jadwal', [
                      _buildDetailItem('Tanggal Mulai', DateFormatter.formatDate(perbaikan.startDate)),
                      _buildDetailItem(
                        'Tanggal Selesai',
                        perbaikan.endDate != null
                            ? DateFormatter.formatDate(perbaikan.endDate!)
                            : 'Belum ditentukan',
                      ),
                      if (perbaikan.endDate != null)
                        _buildDetailItem(
                          'Durasi',
                          '${perbaikan.endDate!.difference(perbaikan.startDate).inDays} hari',
                        ),
                    ]),
                    const SizedBox(height: AppTheme.spacing20),

                    if (perbaikan.cost != null) ...[
                      _buildDetailSection('Biaya', [
                        _buildDetailItem(
                          'Total Biaya',
                          'Rp ${perbaikan.cost!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                        ),
                      ]),
                      const SizedBox(height: AppTheme.spacing20),
                    ],

                    if (perbaikan.notes != null && perbaikan.notes!.isNotEmpty) ...[
                      _buildDetailSection('Catatan', [
                        _buildDetailItem('Catatan', perbaikan.notes!, isDescription: true),
                      ]),
                      const SizedBox(height: AppTheme.spacing20),
                    ],

                    _buildDetailSection('Informasi Tambahan', [
                      _buildDetailItem('Dibuat Oleh', perbaikan.createdBy),
                      _buildDetailItem('Tanggal Dibuat', DateFormatter.formatDateTime(perbaikan.createdAt)),
                      _buildDetailItem('Temuan ID', perbaikan.temuanId),
                    ]),

                    const SizedBox(height: AppTheme.spacing32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _navigateToPerbaikanForm(perbaikanId: perbaikan.id);
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
                              _showUpdateProgressDialog(perbaikan);
                            },
                            icon: const Icon(Icons.timeline),
                            label: const Text('Update Progress'),
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

  void _showUpdateProgressDialog(Perbaikan perbaikan) {
    double currentProgress = perbaikan.progress ?? 0.0;
    String currentStatus = perbaikan.status;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Progress'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress: ${currentProgress.toInt()}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    Slider(
                      value: currentProgress,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: '${currentProgress.toInt()}%',
                      onChanged: (value) {
                        setState(() {
                          currentProgress = value;
                          // Auto update status based on progress
                          if (value == 0) {
                            currentStatus = 'pending';
                          } else if (value > 0 && value < 100) {
                            currentStatus = 'ongoing';
                          } else if (value == 100) {
                            currentStatus = 'selesai';
                          }
                        });
                      },
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    DropdownButtonFormField<String>(
                      value: currentStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'ongoing', child: Text('Ongoing')),
                        DropdownMenuItem(value: 'selesai', child: Text('Selesai')),
                        DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          currentStatus = value!;
                        });
                      },
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan Update (Opsional)',
                        border: OutlineInputBorder(),
                        hintText: 'Tambahkan catatan progress...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _updatePerbaikanProgress(perbaikan.id, currentProgress, currentStatus, notesController.text);
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updatePerbaikanProgress(String perbaikanId, double progress, String status, String notes) async {
    try {
      final updateData = {
        'progress': progress,
        'status': status,
        'notes': notes.isEmpty ? null : notes,
        if (status == 'selesai') 'endDate': DateTime.now().toIso8601String(),
      };

      await _storageService.updatePerbaikan(perbaikanId, updateData);
      _showSuccessSnackBar('Progress berhasil diupdate');
      _loadData();
    } catch (e) {
      _showErrorSnackBar('Gagal mengupdate progress');
    }
  }

  void _handleMenuAction(String action, Perbaikan perbaikan) {
    switch (action) {
      case 'edit':
        _navigateToPerbaikanForm(perbaikanId: perbaikan.id);
        break;
      case 'update_progress':
        _showUpdateProgressDialog(perbaikan);
        break;
      case 'delete':
        _confirmDeletePerbaikan(perbaikan);
        break;
    }
  }

  void _confirmDeletePerbaikan(Perbaikan perbaikan) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Perbaikan'),
          content: Text('Apakah Anda yakin ingin menghapus perbaikan "${perbaikan.workDescription}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deletePerbaikan(perbaikan.id);
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

  Future<void> _deletePerbaikan(String perbaikanId) async {
    try {
      await _storageService.deletePerbaikan(perbaikanId);
      _showSuccessSnackBar('Perbaikan berhasil dihapus');
      _loadData();
    } catch (e) {
      _showErrorSnackBar('Gagal menghapus perbaikan');
    }
  }

  void _navigateToPerbaikanForm({String? perbaikanId, Temuan? temuan}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PerbaikanFormScreen(
          perbaikanId: perbaikanId,
          temuan: temuan,
        ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }
}