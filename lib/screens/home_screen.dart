import 'package:flutter/material.dart';
import '../widgets/menu_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/enhanced_card.dart';
import '../widgets/animated_loading.dart';
import '../models/summary_data.dart';
import '../utils/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SummaryData summaryData = SummaryData(
    totalTemuan: 45,
    temuanPending: 12,
    temuanSelesai: 33,
    totalPerbaikan: 38,
    perbaikanOngoing: 8,
    perbaikanSelesai: 30,
  );

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
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
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
        onRefresh: () async {
          // Refresh data
          await Future.delayed(const Duration(seconds: 2));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
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
                            'Petugas Monitoring',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing8),
                          Text(
                            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radius16),
                      ),
                      child: Icon(
                        Icons.engineering,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Summary Section
              Text(
                'Ringkasan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: AppTheme.spacing8),
                      padding: const EdgeInsets.all(AppTheme.spacing20),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(AppTheme.radius16),
                        border: Border.all(color: AppTheme.borderColor),
                        boxShadow: AppTheme.shadowSm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppTheme.spacing8),
                                decoration: BoxDecoration(
                                  color: AppTheme.warningColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppTheme.radius8),
                                ),
                                child: Icon(
                                  Icons.search,
                                  color: AppTheme.warningColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacing12),
                              Expanded(
                                child: Text(
                                  'Total Temuan',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing12),
                          Text(
                            summaryData.totalTemuan.toString(),
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing4),
                          Text(
                            '${summaryData.temuanPending} Pending',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: AppTheme.spacing8),
                      padding: const EdgeInsets.all(AppTheme.spacing20),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(AppTheme.radius16),
                        border: Border.all(color: AppTheme.borderColor),
                        boxShadow: AppTheme.shadowSm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppTheme.spacing8),
                                decoration: BoxDecoration(
                                  color: AppTheme.successColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppTheme.radius8),
                                ),
                                child: Icon(
                                  Icons.build,
                                  color: AppTheme.successColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacing12),
                              Expanded(
                                child: Text(
                                  'Total Perbaikan',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing12),
                          Text(
                            summaryData.totalPerbaikan.toString(),
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing4),
                          Text(
                            '${summaryData.perbaikanOngoing} Ongoing',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing32),

              // Quick Actions
              const Text(
                'Menu Cepat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  EnhancedCard(
                    onTap: () {
                      Navigator.pushNamed(context, '/temuan');
                    },
                    child: MenuCard(
                      title: 'Temuan Baru',
                      icon: Icons.add_circle_outline,
                      color: Colors.blue,
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
                      color: Colors.green,
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
                      color: Colors.purple,
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
                      icon: Icons.description,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pushNamed(context, '/reports');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Recent Activities
              const Text(
                'Aktivitas Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return EnhancedCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: index % 2 == 0
                            ? Colors.orange.shade100
                            : Colors.green.shade100,
                        child: Icon(
                          index % 2 == 0 ? Icons.search : Icons.build,
                          color: index % 2 == 0 ? Colors.orange : Colors.green,
                        ),
                      ),
                      title: Text(
                        index % 2 == 0
                            ? 'Temuan: Kerusakan Pagar KM 12+300'
                            : 'Perbaikan: Lampu Jalan KM 8+500',
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        '${DateTime.now().subtract(Duration(hours: index + 1)).hour}:00 WIB',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: index % 2 == 0
                              ? Colors.orange.shade100
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          index % 2 == 0 ? 'Pending' : 'Ongoing',
                          style: TextStyle(
                            fontSize: 12,
                            color: index % 2 == 0
                                ? Colors.orange.shade700
                                : Colors.green.shade700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}