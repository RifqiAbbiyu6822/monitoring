// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/menu_card.dart';
import '../widgets/enhanced_card.dart';
import '../services/local_storage_service.dart';
import '../utils/theme.dart';
import '../utils/date_formatter.dart';
import '../utils/helpers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalStorageService _storageService = LocalStorageService();
  
  Map<String, int> _statistics = {};
  List<dynamic> _recentActivities = [];
  bool _isLoading = true;

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
      // Load statistics
      final stats = await _storageService.getSummaryStatistics();
      
      // Load recent activities (combine temuan and perbaikan)
      final temuanList = await _storageService.getAllTemuan();
      final perbaikanList = await _storageService.getAllPerbaikan();
      
      // Sort and get recent items
      final recentTemuan = temuanList
          .take(3)
          .map((t) => {
                'type': 'temuan',
                'title': 'Temuan: ${t.description}',
                'subtitle': 'KM ${t.kmPoint} • ${t.section}',
                'time': DateFormatter.formatRelativeTime(t.createdAt),
                'status': t.status,
                'icon': Icons.search,
                'color': Helpers.getStatusColor(t.status),
              })
          .toList();

      final recentPerbaikan = perbaikanList
          .take(3)
          .map((p) => {
                'type': 'perbaikan',
                'title': 'Perbaikan: ${p.workDescription}',
                'subtitle': 'KM ${p.kmPoint} • ${p.assignedTo}',
                'time': DateFormatter.formatRelativeTime(p.createdAt),
                'status': p.status,
                'icon': Icons.build,
                'color': Helpers.getStatusColor(p.status),
              })
          .toList();

      // Combine and sort by creation time
      final allActivities = [...recentTemuan, ...recentPerbaikan];
      allActivities.sort((a, b) => b['time'].toString().compareTo(a['time'].toString()));

      setState(() {
        _statistics = stats;
        _recentActivities = allActivities.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading home data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.surfaceColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // Handle profile
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(),
              const SizedBox(height: AppTheme.spacing24),

              // Statistics Section
              _buildStatisticsSection(),
              const SizedBox(height: AppTheme.spacing32),

              // Quick Actions
              _buildQuickActionsSection(),
              const SizedBox(height: AppTheme.spacing32),

              // Recent Activities
              _buildRecentActivitiesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radius20),
        boxShadow: AppTheme.shadowLg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  'Sistem Monitoring MBZ',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  DateFormatter.formatDate(DateTime.now()),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radius16),
            ),
            child: const Icon(
              Icons.engineering,
              size: 48,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Data',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Temuan',
                _statistics['totalTemuan']?.toString() ?? '0',
                '${_statistics['temuanPending'] ?? 0} Pending',
                Icons.search,
                AppTheme.warningColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: _buildStatCard(
                'Total Perbaikan',
                _statistics['totalPerbaikan']?.toString() ?? '0',
                '${_statistics['perbaikanOngoing'] ?? 0} Ongoing',
                Icons.build,
                AppTheme.successColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Temuan Selesai',
                _statistics['temuanCompleted']?.toString() ?? '0',
                'Completed',
                Icons.check_circle,
                AppTheme.successColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: _buildStatCard(
                'Perbaikan Selesai',
                _statistics['perbaikanCompleted']?.toString() ?? '0',
                'Completed',
                Icons.done_all,
                AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
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
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu Cepat',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppTheme.spacing16,
          mainAxisSpacing: AppTheme.spacing16,
          childAspectRatio: 1.2,
          children: [
            EnhancedCard(
              onTap: () {
                Navigator.pushNamed(context, '/temuan');
              },
              child: MenuCard(
                title: 'Temuan Baru',
                icon: Icons.add_circle_outline,
                color: AppTheme.primaryColor,
                onTap: () {
                  Navigator.pushNamed(context, '/temuan');
                },
              ),
            ),
            EnhancedCard(
              onTap: () {
                Navigator.pushNamed(context, '/perbaikan');
              },
              child: MenuCard(
                title: 'Perbaikan',
                icon: Icons.construction,
                color: AppTheme.successColor,
                onTap: () {
                  Navigator.pushNamed(context, '/perbaikan');
                },
              ),
            ),
            EnhancedCard(
              onTap: () {
                Navigator.pushNamed(context, '/history');
              },
              child: MenuCard(
                title: 'Riwayat',
                icon: Icons.history,
                color: AppTheme.secondaryColor,
                onTap: () {
                  Navigator.pushNamed(context, '/history');
                },
              ),
            ),
            EnhancedCard(
              onTap: () {
                Navigator.pushNamed(context, '/reports');
              },
              child: MenuCard(
                title: 'Laporan',
                icon: Icons.assessment,
                color: AppTheme.warningColor,
                onTap: () {
                  Navigator.pushNamed(context, '/reports');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivitas Terbaru',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_recentActivities.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history');
                },
                child: const Text('Lihat Semua'),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing16),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else if (_recentActivities.isEmpty)
          EnhancedCard(
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacing32),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Text(
                    'Belum ada aktivitas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    'Mulai dengan menambah temuan baru',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentActivities.length,
            itemBuilder: (context, index) {
              final activity = _recentActivities[index];
              return EnhancedCard(
                margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppTheme.spacing16),
                  leading: Container(
                    padding: const EdgeInsets.all(AppTheme.spacing8),
                    decoration: BoxDecoration(
                      color: activity['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radius8),
                    ),
                    child: Icon(
                      activity['icon'],
                      color: activity['color'],
                      size: 20,
                    ),
                  ),
                  title: Text(
                    activity['title'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        activity['subtitle'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        activity['time'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing8,
                      vertical: AppTheme.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: activity['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radius8),
                    ),
                    child: Text(
                      Helpers.getStatusText(activity['status']),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: activity['color'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}