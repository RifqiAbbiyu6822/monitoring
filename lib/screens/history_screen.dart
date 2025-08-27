// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import '../model/temuan.dart';
import '../model/perbaikan.dart';
import '../services/local_storage_service.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';
import '../utils/date_formatter.dart';
import '../widgets/animated_loading.dart';
import '../widgets/photo_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final LocalStorageService _storageService = LocalStorageService();
  
  bool _isLoading = true;
  List<Temuan> _temuanList = [];
  List<Perbaikan> _perbaikanList = [];
  
  String _temuanFilter = 'Semua';
  String _perbaikanFilter = 'Semua';
  String _sortBy = 'Terbaru';
  
  final List<String> _temuanFilterOptions = ['Semua', 'Pending', 'In Progress', 'Completed'];
  final List<String> _perbaikanFilterOptions = ['Semua', 'Pending', 'Ongoing', 'Selesai', 'Cancelled'];
  final List<String> _sortOptions = ['Terbaru', 'Terlama', 'Prioritas Tinggi', 'Progress'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistoryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistoryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final temuanList = await _storageService.getAllTemuan();
      final perbaikanList = await _storageService.getAllPerbaikan();

      setState(() {
        _temuanList = temuanList;
        _perbaikanList = perbaikanList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Gagal memuat riwayat data');
    }
  }

  List<Temuan> get _filteredAndSortedTemuanList {
    var filtered = _temuanList;
    
    // Apply filter
    if (_temuanFilter != 'Semua') {
      filtered = filtered.where((temuan) {
        switch (_temuanFilter) {
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
    
    // Apply sorting
    switch (_sortBy) {
      case 'Terbaru':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Terlama':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'Prioritas Tinggi':
        filtered.sort((a, b) {
          const priorityOrder = {'critical': 4, 'high': 3, 'medium': 2, 'low': 1};
          return (priorityOrder[b.priority] ?? 0).compareTo(priorityOrder[a.priority] ?? 0);
        });
        break;
    }
    
    return filtered;
  }

  List<Perbaikan> get _filteredAndSortedPerbaikanList {
    var filtered = _perbaikanList;
    
    // Apply filter
    if (_perbaikanFilter != 'Semua') {
      filtered = filtered.where((perbaikan) {
        switch (_perbaikanFilter) {
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
    
    // Apply sorting
    switch (_sortBy) {
      case 'Terbaru':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Terlama':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'Progress':
        filtered.sort((a, b) => (b.progress ?? 0).compareTo(a.progress ?? 0));
        break;
    }
    
    return filtered;
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
        title: const Text('Riwayat'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.surfaceColor,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => _sortOptions.map((sort) {
              return PopupMenuItem(
                value: sort,
                child: Row(
                  children: [
                    if (_sortBy == sort)
                      Icon(Icons.check, size: 16, color: AppTheme.primaryColor)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: AppTheme.spacing8),
                    Text(sort),
                  ],
                ),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistoryData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Temuan (${_filteredAndSortedTemuanList.length})',
              icon: const Icon(Icons.search),
            ),
            Tab(
              text: 'Perbaikan (${_filteredAndSortedPerbaikanList.length})',
              icon: const Icon(Icons.build),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedLoading(size: 60, color: AppTheme.primaryColor),
                  SizedBox(height: AppTheme.spacing20),
                  Text(
                    'Memuat riwayat...',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTemuanHistoryTab(),
                _buildPerbaikanHistoryTab(),
              ],
            ),
    );
  }

  Widget _buildTemuanHistoryTab() {
    return Column(
      children: [
        // Filter Section
        _buildFilterSection(
          filterValue: _temuanFilter,
          filterOptions: _temuanFilterOptions,
          onFilterChanged: (value) => setState(() => _temuanFilter = value),
          itemCount: _filteredAndSortedTemuanList.length,
        ),
        
        // Content
        Expanded(
          child: _filteredAndSortedTemuanList.isEmpty
              ? _buildEmptyState('temuan')
              : RefreshIndicator(
                  onRefresh: _loadHistoryData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacing20),
                    itemCount: _filteredAndSortedTemuanList.length,
                    itemBuilder: (context, index) {
                      final temuan = _filteredAndSortedTemuanList[index];
                      return _buildTemuanCard(temuan);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPerbaikanHistoryTab() {
    return Column(
      children: [
        // Filter Section
        _buildFilterSection(
          filterValue: _perbaikanFilter,
          filterOptions: _perbaikanFilterOptions,
          onFilterChanged: (value) => setState(() => _perbaikanFilter = value),
          itemCount: _filteredAndSortedPerbaikanList.length,
        ),
        
        // Content
        Expanded(
          child: _filteredAndSortedPerbaikanList.isEmpty
              ? _buildEmptyState('perbaikan')
              : RefreshIndicator(
                  onRefresh: _loadHistoryData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacing20),
                    itemCount: _filteredAndSortedPerbaikanList.length,
                    itemBuilder: (context, index) {
                      final perbaikan = _filteredAndSortedPerbaikanList[index];
                      return _buildPerbaikanCard(perbaikan);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterSection({
    required String filterValue,
    required List<String> filterOptions,
    required ValueChanged<String> onFilterChanged,
    required int itemCount,
  }) {
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
                'Filter & Urutan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing8,
                  vertical: AppTheme.spacing4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radius8),
                ),
                child: Text(
                  '$itemCount item • $_sortBy',
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
              children: filterOptions.map((filter) {
                final isSelected = filterValue == filter;
                final count = _getFilterCount(filter, filterOptions == _temuanFilterOptions);
                
                return Container(
                  margin: const EdgeInsets.only(right: AppTheme.spacing8),
                  child: FilterChip(
                    label: Text('$filter ($count)'),
                    selected: isSelected,
                    onSelected: (selected) {
                      onFilterChanged(filter);
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
    );
  }

  int _getFilterCount(String filter, bool isTemuan) {
    if (isTemuan) {
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
    } else {
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
  }

  Widget _buildEmptyState(String type) {
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
                    type == 'temuan' ? Icons.search_off : Icons.build_circle_outlined,
                    size: 48,
                    color: AppTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                Text(
                  'Tidak ada riwayat $type',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  type == 'temuan'
                      ? 'Belum ada data temuan yang tersimpan'
                      : 'Belum ada data perbaikan yang tersimpan',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing20),
                OutlinedButton.icon(
                  onPressed: () {
                    if (type == 'temuan') {
                      Navigator.pushNamed(context, '/temuan');
                    } else {
                      Navigator.pushNamed(context, '/perbaikan');
                    }
                  },
                  icon: Icon(type == 'temuan' ? Icons.add_circle_outline : Icons.build_circle_outlined),
                  label: Text('Tambah ${type == 'temuan' ? 'Temuan' : 'Perbaikan'}'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemuanCard(Temuan temuan) {
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
                        color: Helpers.getStatusColor(temuan.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radius8),
                      ),
                      child: Icon(
                        Helpers.getCategoryIcon(temuan.category),
                        color: Helpers.getStatusColor(temuan.status),
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
                            'KM ${temuan.kmPoint} • ${temuan.section} • ${temuan.createdBy}',
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
                      onSelected: (value) => _handleTemuanMenuAction(value, temuan),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 16),
                              SizedBox(width: AppTheme.spacing8),
                              Text('Lihat Detail'),
                            ],
                          ),
                        ),
                        if (temuan.status != 'completed')
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
                      onSelected: (value) => _handlePerbaikanMenuAction(value, perbaikan),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 16),
                              SizedBox(width: AppTheme.spacing8),
                              Text('Lihat Detail'),
                            ],
                          ),
                        ),
                        if (perbaikan.status != 'selesai')
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
                        if (perbaikan.status != 'selesai')
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
                
                // Progress Bar (if applicable)
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

  void _showTemuanDetail(Temuan temuan) {
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
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacing12),
                          decoration: BoxDecoration(
                            color: Helpers.getStatusColor(temuan.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radius12),
                          ),
                          child: Icon(
                            Helpers.getCategoryIcon(temuan.category),
                            color: Helpers.getStatusColor(temuan.status),
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
                                'ID: ${temuan.id}',
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

                    // Details sections (similar to previous implementation)
                    _buildDetailSection('Informasi Umum', [
                      _buildDetailItem('Deskripsi', temuan.description, isDescription: true),
                      _buildDetailItem('Kategori', '${temuan.category} - ${temuan.subcategory}'),
                      _buildDetailItem('Status', Helpers.getStatusText(temuan.status)),
                      _buildDetailItem('Prioritas', Helpers.getPriorityText(temuan.priority)),
                    ]),
                    const SizedBox(height: AppTheme.spacing20),

                    _buildDetailSection('Lokasi', [
                      _buildDetailItem('Seksi', temuan.section),
                      _buildDetailItem('KM Point', temuan.kmPoint),
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
                  ],
                ),
              ),
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
                    // Header (similar to perbaikan screen implementation)
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

                    // Progress section and other details (similar to perbaikan screen)
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

                    // Other detail sections...
                    _buildDetailSection('Informasi Umum', [
                      _buildDetailItem('Deskripsi Pekerjaan', perbaikan.workDescription, isDescription: true),
                      _buildDetailItem('Kontraktor', perbaikan.contractor),
                      _buildDetailItem('Status', Helpers.getStatusText(perbaikan.status)),
                    ]),
                    const SizedBox(height: AppTheme.spacing20),

                    // Foto sections
                    if (perbaikan.beforePhotos.isNotEmpty) ...[
                      _buildDetailSection('Foto Sebelum', [
                        PhotoViewerWidget(
                          photos: perbaikan.beforePhotos,
                          title: 'Foto Sebelum Perbaikan',
                          emptyMessage: 'Tidak ada foto sebelum perbaikan',
                        ),
                      ]),
                      const SizedBox(height: AppTheme.spacing20),
                    ],

                    if (perbaikan.progressPhotos.isNotEmpty) ...[
                      _buildDetailSection('Foto Progress', [
                        ProgressPhotoViewerWidget(
                          photos: perbaikan.progressPhotos,
                          title: 'Foto Progress Pekerjaan',
                          emptyMessage: 'Tidak ada foto progress',
                        ),
                      ]),
                      const SizedBox(height: AppTheme.spacing20),
                    ],

                    if (perbaikan.afterPhotos.isNotEmpty) ...[
                      _buildDetailSection('Foto Sesudah', [
                        PhotoViewerWidget(
                          photos: perbaikan.afterPhotos,
                          title: 'Foto Sesudah Perbaikan',
                          emptyMessage: 'Tidak ada foto sesudah perbaikan',
                        ),
                      ]),
                      const SizedBox(height: AppTheme.spacing20),
                    ],

                    if (perbaikan.documentationPhotos != null && perbaikan.documentationPhotos!.isNotEmpty) ...[
                      _buildDetailSection('Foto Dokumentasi', [
                        PhotoViewerWidget(
                          photos: perbaikan.documentationPhotos!,
                          title: 'Foto Dokumentasi Update',
                          emptyMessage: 'Tidak ada foto dokumentasi',
                        ),
                      ]),
                      const SizedBox(height: AppTheme.spacing20),
                    ],

                    const SizedBox(height: AppTheme.spacing32),
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
          child: Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
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

  void _handleTemuanMenuAction(String action, Temuan temuan) {
    switch (action) {
      case 'view':
        _showTemuanDetail(temuan);
        break;
      case 'edit':
        Navigator.pushNamed(context, '/temuan');
        break;
      case 'delete':
        _confirmDeleteTemuan(temuan);
        break;
    }
  }

  void _handlePerbaikanMenuAction(String action, Perbaikan perbaikan) {
    switch (action) {
      case 'view':
        _showPerbaikanDetail(perbaikan);
        break;
      case 'edit':
        Navigator.pushNamed(context, '/perbaikan');
        break;
      case 'update_progress':
        // Handle progress update
        break;
      case 'delete':
        _confirmDeletePerbaikan(perbaikan);
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

  Future<void> _deleteTemuan(String temuanId) async {
    try {
      await _storageService.deleteTemuan(temuanId);
      _showSuccessSnackBar('Temuan berhasil dihapus');
      _loadHistoryData();
    } catch (e) {
      _showErrorSnackBar('Gagal menghapus temuan');
    }
  }

  Future<void> _deletePerbaikan(String perbaikanId) async {
    try {
      await _storageService.deletePerbaikan(perbaikanId);
      _showSuccessSnackBar('Perbaikan berhasil dihapus');
      _loadHistoryData();
    } catch (e) {
      _showErrorSnackBar('Gagal menghapus perbaikan');
    }
  }
}