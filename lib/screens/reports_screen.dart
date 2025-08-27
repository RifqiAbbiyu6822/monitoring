// lib/screens/reports_screen.dart
import 'package:flutter/material.dart';
import '../widgets/enhanced_card.dart';
import '../services/local_storage_service.dart';
import '../model/temuan.dart';
import '../model/perbaikan.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';
import '../utils/date_formatter.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final LocalStorageService _storageService = LocalStorageService();
  
  String _selectedPeriod = 'bulan';
  bool _isLoading = false;
  
  List<Temuan> _temuanList = [];
  List<Perbaikan> _perbaikanList = [];

  @override
  void initState() {
    super.initState();
    _loadReportsData();
  }

  Future<void> _loadReportsData() async {
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
    }
  }

  List<Temuan> get _filteredTemuan {
    final now = DateTime.now();
    return _temuanList.where((temuan) {
      switch (_selectedPeriod) {
        case 'minggu':
          return temuan.createdAt.isAfter(now.subtract(const Duration(days: 7)));
        case 'bulan':
          return temuan.createdAt.isAfter(now.subtract(const Duration(days: 30)));
        case 'tahun':
          return temuan.createdAt.isAfter(now.subtract(const Duration(days: 365)));
        default:
          return true;
      }
    }).toList();
  }

  List<Perbaikan> get _filteredPerbaikan {
    final now = DateTime.now();
    return _perbaikanList.where((perbaikan) {
      switch (_selectedPeriod) {
        case 'minggu':
          return perbaikan.createdAt.isAfter(now.subtract(const Duration(days: 7)));
        case 'bulan':
          return perbaikan.createdAt.isAfter(now.subtract(const Duration(days: 30)));
        case 'tahun':
          return perbaikan.createdAt.isAfter(now.subtract(const Duration(days: 365)));
        default:
          return true;
      }
    }).toList();
  }

  Map<String, int> get _categoryData {
    final Map<String, int> categoryCount = {};
    for (final temuan in _filteredTemuan) {
      categoryCount[temuan.category] = (categoryCount[temuan.category] ?? 0) + 1;
    }
    return categoryCount;
  }

  Map<String, int> get _statusData {
    final Map<String, int> statusCount = {};
    for (final temuan in _filteredTemuan) {
      statusCount[temuan.status] = (statusCount[temuan.status] ?? 0) + 1;
    }
    return statusCount;
  }

  Map<String, int> get _priorityData {
    final Map<String, int> priorityCount = {};
    for (final temuan in _filteredTemuan) {
      priorityCount[temuan.priority] = (priorityCount[temuan.priority] ?? 0) + 1;
    }
    return priorityCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Laporan'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.surfaceColor,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'minggu',
                child: Row(
                  children: [
                    if (_selectedPeriod == 'minggu')
                      Icon(Icons.check, size: 16, color: AppTheme.primaryColor)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: AppTheme.spacing8),
                    const Text('Minggu Ini'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'bulan',
                child: Row(
                  children: [
                    if (_selectedPeriod == 'bulan')
                      Icon(Icons.check, size: 16, color: AppTheme.primaryColor)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: AppTheme.spacing8),
                    const Text('Bulan Ini'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'tahun',
                child: Row(
                  children: [
                    if (_selectedPeriod == 'tahun')
                      Icon(Icons.check, size: 16, color: AppTheme.primaryColor)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: AppTheme.spacing8),
                    const Text('Tahun Ini'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReportsData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReportsData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTheme.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Header
                    _buildPeriodHeader(),
                    const SizedBox(height: AppTheme.spacing24),

                    // Summary Cards
                    _buildSummaryCards(),
                    const SizedBox(height: AppTheme.spacing24),

                    // Category Chart
                    _buildCategoryChart(),
                    const SizedBox(height: AppTheme.spacing24),

                    // Status Chart
                    _buildStatusChart(),
                    const SizedBox(height: AppTheme.spacing24),

                    // Priority Chart
                    _buildPriorityChart(),
                    const SizedBox(height: AppTheme.spacing24),

                    // Recent Activity
                    _buildRecentActivity(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        boxShadow: AppTheme.shadowLg,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radius12),
            ),
            child: const Icon(
              Icons.analytics,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laporan ${_getPeriodText(_selectedPeriod)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  'Data monitoring periode ${_selectedPeriod}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    // Gunakan data yang sudah difilter berdasarkan periode yang dipilih
    final filteredTemuanCount = _filteredTemuan.length;
    final filteredPerbaikanCount = _filteredPerbaikan.length;
    final completedTemuan = _filteredTemuan.where((t) => t.status == 'completed').length;
    final ongoingPerbaikan = _filteredPerbaikan.where((p) => p.status == 'ongoing').length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppTheme.spacing16,
      mainAxisSpacing: AppTheme.spacing16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'Total Temuan',
          filteredTemuanCount.toString(),
          Icons.search,
          AppTheme.warningColor,
        ),
        _buildSummaryCard(
          'Temuan Selesai',
          completedTemuan.toString(),
          Icons.check_circle,
          AppTheme.successColor,
        ),
        _buildSummaryCard(
          'Total Perbaikan',
          filteredPerbaikanCount.toString(),
          Icons.build,
          AppTheme.primaryColor,
        ),
        _buildSummaryCard(
          'Perbaikan Ongoing',
          ongoingPerbaikan.toString(),
          Icons.pending,
          AppTheme.infoColor,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return EnhancedCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radius12),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.spacing6),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing2),
          Flexible(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart() {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Temuan berdasarkan Kategori',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          if (_categoryData.isEmpty) 
            _buildEmptyChart('Tidak ada data kategori untuk periode ini')
          else
            ..._categoryData.entries.map((entry) => _buildCategoryItem(
              _getCategoryText(entry.key),
              entry.value,
              Helpers.getCategoryColor(entry.key),
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildStatusChart() {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Temuan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          if (_statusData.isEmpty)
            _buildEmptyChart('Tidak ada data status untuk periode ini')
          else
            ..._statusData.entries.map((entry) => _buildStatusItem(
              Helpers.getStatusText(entry.key),
              entry.value,
              Helpers.getStatusColor(entry.key),
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildPriorityChart() {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prioritas Temuan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          if (_priorityData.isEmpty)
            _buildEmptyChart('Tidak ada data prioritas untuk periode ini')
          else
            ..._priorityData.entries.map((entry) => _buildPriorityItem(
              Helpers.getPriorityText(entry.key),
              entry.value,
              Helpers.getPriorityColor(entry.key),
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 48,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category, int count, Color color) {
    final total = _filteredTemuan.length;
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Text(
              category,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$count ($percentage%)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String status, int count, Color color) {
    final total = _filteredTemuan.length;
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Text(
              status,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$count ($percentage%)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityItem(String priority, int count, Color color) {
    final total = _filteredTemuan.length;
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Text(
              priority,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$count ($percentage%)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final recentItems = <Map<String, dynamic>>[];
    
    // Add recent temuan
    for (final temuan in _filteredTemuan.take(3)) {
      recentItems.add({
        'type': 'temuan',
        'title': 'Temuan: ${temuan.description}',
        'description': 'KM ${temuan.kmPoint} • ${temuan.section}',
        'time': DateFormatter.formatRelativeTime(temuan.createdAt),
        'icon': Icons.search,
        'color': Helpers.getStatusColor(temuan.status),
        'status': Helpers.getStatusText(temuan.status),
      });
    }
    
    // Add recent perbaikan
    for (final perbaikan in _filteredPerbaikan.take(3)) {
      recentItems.add({
        'type': 'perbaikan',
        'title': 'Perbaikan: ${perbaikan.workDescription}',
        'description': 'KM ${perbaikan.kmPoint} • ${perbaikan.assignedTo}',
        'time': DateFormatter.formatRelativeTime(perbaikan.createdAt),
        'icon': Icons.build,
        'color': Helpers.getStatusColor(perbaikan.status),
        'status': Helpers.getStatusText(perbaikan.status),
      });
    }
    
    // Sort by most recent
    recentItems.sort((a, b) => b['time'].toString().compareTo(a['time'].toString()));

    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aktivitas Terbaru',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (recentItems.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/history');
                  },
                  child: const Text('Lihat Semua'),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          if (recentItems.isEmpty)
            _buildEmptyChart('Tidak ada aktivitas untuk periode ini')
          else
            ...recentItems.take(5).map((item) => _buildActivityItem(
              item['title'],
              item['description'],
              item['time'],
              item['icon'],
              item['color'],
              item['status'],
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
    String status,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radius8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.spacing2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing8,
                  vertical: AppTheme.spacing4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radius8),
                ),
                child: Text(
                  status,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                time,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPeriodText(String period) {
    switch (period) {
      case 'minggu':
        return 'Minggu Ini';
      case 'bulan':
        return 'Bulan Ini';
      case 'tahun':
        return 'Tahun Ini';
      default:
        return 'Bulan Ini';
    }
  }

  String _getCategoryText(String category) {
    switch (category) {
      case 'jalan':
        return 'Jalan';
      case 'jembatan':
        return 'Jembatan';
      case 'marka':
        return 'Marka';
      case 'rambu':
        return 'Rambu';
      case 'drainase':
        return 'Drainase';
      case 'penerangan':
        return 'Penerangan';
      default:
        return category;
    }
  }
}