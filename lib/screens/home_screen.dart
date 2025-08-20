import 'package:flutter/material.dart';
import '../widgets/menu_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/enhanced_card.dart';
import '../widgets/animated_loading.dart';
import '../models/summary_data.dart';

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
      appBar: AppBar(
        title: const Text('Monitoring Jalan Tol MBZ'),
        centerTitle: true,
        elevation: 2,
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              GradientCard(
                colors: [Colors.blue.shade600, Colors.blue.shade400, Colors.blue.shade300],
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selamat Datang',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Petugas Monitoring',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.engineering,
                      size: 60,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),

              // Summary Section
              const Text(
                'Ringkasan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: EnhancedCard(
                      margin: const EdgeInsets.only(right: 6),
                      child: SummaryCard(
                        title: 'Total Temuan',
                        value: summaryData.totalTemuan.toString(),
                        icon: Icons.search,
                        color: Colors.orange,
                        subtitle: '${summaryData.temuanPending} Pending',
                      ),
                    ),
                  ),
                  Expanded(
                    child: EnhancedCard(
                      margin: const EdgeInsets.only(left: 6),
                      child: SummaryCard(
                        title: 'Total Perbaikan',
                        value: summaryData.totalPerbaikan.toString(),
                        icon: Icons.build,
                        color: Colors.green,
                        subtitle: '${summaryData.perbaikanOngoing} Ongoing',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

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