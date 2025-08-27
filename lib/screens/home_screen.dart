// lib/screens/home_screen.dart - Enhanced Modern UI with Better Data Loading
import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../utils/theme.dart';
import '../utils/date_formatter.dart';
import '../utils/helpers.dart';
import '../widgets/animated_loading.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final LocalStorageService _storageService = LocalStorageService();
  
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _lastRefresh;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final dashboardData = await _storageService.getDashboardSummary();
      
      if (mounted) {
        setState(() {
          _dashboardData = dashboardData;
          _isLoading = false;
          _lastRefresh = DateTime.now();
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat data dashboard';
        });
      }
    }
  }

  Future<void> _refreshData() async {
    try {
      await _storageService.refreshAllData();
      await _loadDashboardData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data berhasil dimuat ulang'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat ulang data: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          _buildSliverAppBar(),
          
          // Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: _isLoading 
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.surfaceColor,
      foregroundColor: AppTheme.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: null,
        background: Container(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Dashboard',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _lastRefresh != null 
                          ? 'Diperbarui ${DateFormatter.formatRelativeTime(_lastRefresh!)}'
                          : 'Sistem Monitoring MBZ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Quick Actions
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _refreshData,
                  icon: const Icon(Icons.refresh_rounded),
                  color: AppTheme.primaryColor,
                  tooltip: 'Muat ulang data',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AnimatedLoading(
              size: 48,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Memuat dashboard...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return SliverFillRemaining(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: AppTheme.errorColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Gagal Memuat Data',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'Terjadi kesalahan yang tidak diketahui',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadDashboardData,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final summary = _dashboardData?['summary'] as Map<String, int>? ?? {};
    final recentActivities = _dashboardData?['recentActivities'] as List<Map<String, dynamic>>? ?? [];
    
    return SliverList(
      delegate: SliverChildListDelegate([
        // Statistics Cards
        _buildStatisticsSection(summary),
        const SizedBox(height: 32),
        
        // Quick Actions
        _buildQuickActionsSection(),
        const SizedBox(height: 32),
        
        // Recent Activities
        _buildRecentActivitiesSection(recentActivities),
        const SizedBox(height: 32),
        
        // Insights
        _buildInsightsSection(summary),
      ]),
    );
  }

  Widget _buildStatisticsSection(Map<String, int> summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Primary Stats
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Temuan',
                value: '${summary['totalTemuan'] ?? 0}',
                subtitle: '${summary['temuanPending'] ?? 0} pending',
                icon: Icons.search_rounded,
                color: AppTheme.primaryColor,
                trend: _calculateTrend(summary['totalTemuan'] ?? 0),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Total Perbaikan',
                value: '${summary['totalPerbaikan'] ?? 0}',
                subtitle: '${summary['perbaikanOngoing'] ?? 0} ongoing',
                icon: Icons.construction_rounded,
                color: AppTheme.successColor,
                trend: _calculateTrend(summary['totalPerbaikan'] ?? 0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Secondary Stats
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Selesai',
                value: '${summary['temuanCompleted'] ?? 0}',
                subtitle: 'temuan',
                icon: Icons.check_circle_rounded,
                color: AppTheme.successColor,
                isCompact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Progress',
                value: '${summary['temuanInProgress'] ?? 0}',
                subtitle: 'berlangsung',
                icon: Icons.hourglass_empty_rounded,
                color: AppTheme.warningColor,
                isCompact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Selesai',
                value: '${summary['perbaikanCompleted'] ?? 0}',
                subtitle: 'perbaikan',
                icon: Icons.done_all_rounded,
                color: AppTheme.infoColor,
                isCompact: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    double? trend,
    bool isCompact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
        boxShadow: AppTheme.shadowXs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isCompact ? 16 : 20,
                ),
              ),
              const Spacer(),
              if (trend != null && !isCompact)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (trend > 0 ? AppTheme.successColor : AppTheme.errorColor).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trend > 0 ? Icons.trending_up : Icons.trending_down,
                        size: 12,
                        color: trend > 0 ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${trend.abs().toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: trend > 0 ? AppTheme.successColor : AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: isCompact ? 12 : 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: isCompact ? 20 : 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: isCompact ? 11 : 12,
            ),
          ),
          if (!isCompact) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textTertiary,
              ),
            ),
          ] else ...[
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                title: 'Temuan Baru',
                subtitle: 'Laporkan temuan',
                icon: Icons.add_circle_outline,
                color: AppTheme.primaryColor,
                onTap: () => Navigator.pushNamed(context, '/temuan'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                title: 'Perbaikan',
                subtitle: 'Kelola perbaikan',
                icon: Icons.construction,
                color: AppTheme.successColor,
                onTap: () => Navigator.pushNamed(context, '/perbaikan'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                title: 'Riwayat',
                subtitle: 'Lihat riwayat data',
                icon: Icons.history_rounded,
                color: AppTheme.secondaryColor,
                onTap: () => Navigator.pushNamed(context, '/history'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                title: 'Laporan',
                subtitle: 'Analisis & laporan',
                icon: Icons.assessment_rounded,
                color: AppTheme.infoColor,
                onTap: () => Navigator.pushNamed(context, '/reports'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor, width: 0.5),
            boxShadow: AppTheme.shadowXs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesSection(List<Map<String, dynamic>> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivitas Terbaru',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            if (activities.isNotEmpty)
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/history'),
                child: const Text('Lihat Semua'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (activities.isEmpty) 
          _buildEmptyActivities()
        else
          ...activities.map((activity) => _buildActivityItem(activity)),
      ],
    );
  }

  Widget _buildEmptyActivities() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.textTertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.inbox_rounded,
              color: AppTheme.textTertiary,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Aktivitas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai dengan menambah temuan atau perbaikan baru',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final status = activity['status'] as String;
    final createdAt = activity['createdAt'] as DateTime;
    final statusColor = AppTheme.getStatusColor(status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            activity['icon'] as IconData,
            color: statusColor,
            size: 20,
          ),
        ),
        title: Text(
          activity['title'] as String,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              activity['subtitle'] as String,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatRelativeTime(createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            Helpers.getStatusText(status),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsSection(Map<String, int> summary) {
    final totalTemuan = summary['totalTemuan'] ?? 0;
    final completedTemuan = summary['temuanCompleted'] ?? 0;
    final totalPerbaikan = summary['totalPerbaikan'] ?? 0;
    final completedPerbaikan = summary['perbaikanCompleted'] ?? 0;
    
    final completionRate = totalTemuan > 0 
        ? ((completedTemuan / totalTemuan) * 100).round()
        : 0;
    
    final perbaikanRate = totalPerbaikan > 0 
        ? ((completedPerbaikan / totalPerbaikan) * 100).round()
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wawasan',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor, width: 0.5),
            boxShadow: AppTheme.shadowXs,
          ),
          child: Column(
            children: [
              _buildInsightItem(
                title: 'Tingkat Penyelesaian Temuan',
                value: '$completionRate%',
                description: '$completedTemuan dari $totalTemuan temuan telah diselesaikan',
                progress: completionRate / 100,
                color: _getInsightColor(completionRate),
              ),
              const SizedBox(height: 20),
              _buildInsightItem(
                title: 'Tingkat Penyelesaian Perbaikan',
                value: '$perbaikanRate%',
                description: '$completedPerbaikan dari $totalPerbaikan perbaikan telah selesai',
                progress: perbaikanRate / 100,
                color: _getInsightColor(perbaikanRate),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Performance metrics card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.05),
                AppTheme.primaryColor.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.insights_rounded,
                  color: AppTheme.infoColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tips Produktivitas',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getProductivityTip(summary),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem({
    required String title,
    required String value,
    required String description,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.borderColor,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(2),
          minHeight: 4,
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // Helper methods
  double _calculateTrend(int currentValue) {
    // Mock trend calculation - in real app, compare with previous period
    if (currentValue == 0) return 0;
    return (currentValue * 0.1 - 5).clamp(-100.0, 100.0);
  }

  Color _getInsightColor(int percentage) {
    if (percentage >= 80) return AppTheme.successColor;
    if (percentage >= 60) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  String _getProductivityTip(Map<String, int> summary) {
    final pendingTemuan = summary['temuanPending'] ?? 0;
    final ongoingPerbaikan = summary['perbaikanOngoing'] ?? 0;
    
    if (pendingTemuan > ongoingPerbaikan && pendingTemuan > 5) {
      return 'Anda memiliki $pendingTemuan temuan pending. Prioritaskan untuk membuat perbaikan pada temuan dengan prioritas tinggi.';
    } else if (ongoingPerbaikan > 10) {
      return 'Fokus pada penyelesaian $ongoingPerbaikan perbaikan yang sedang berlangsung untuk meningkatkan efisiensi.';
    } else if (summary['totalTemuan'] == 0) {
      return 'Mulai monitoring dengan menambahkan temuan baru untuk melacak kondisi infrastruktur.';
    } else {
      return 'Sistem monitoring berjalan dengan baik. Lanjutkan konsistensi dalam pelaporan dan penanganan.';
    }
  }
}