import 'package:flutter/material.dart';
import '../widgets/enhanced_card.dart';
import '../utils/helpers.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'bulan';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'minggu',
                child: Text('Minggu Ini'),
              ),
              const PopupMenuItem(
                value: 'bulan',
                child: Text('Bulan Ini'),
              ),
              const PopupMenuItem(
                value: 'tahun',
                child: Text('Tahun Ini'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getPeriodText(_selectedPeriod)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(),
                  const SizedBox(height: 24),
                  _buildCategoryChart(),
                  const SizedBox(height: 24),
                  _buildStatusChart(),
                  const SizedBox(height: 24),
                  _buildPriorityChart(),
                  const SizedBox(height: 24),
                  _buildRecentActivity(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'Total Temuan',
          '156',
          Icons.search,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Temuan Selesai',
          '142',
          Icons.check_circle,
          Colors.green,
        ),
        _buildSummaryCard(
          'Dalam Proses',
          '8',
          Icons.pending,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Menunggu',
          '6',
          Icons.schedule,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return EnhancedCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: color,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart() {
    return EnhancedCard(
      padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temuan berdasarkan Kategori',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildCategoryItem('Jalan', 45, Colors.blue),
            _buildCategoryItem('Jembatan', 23, Colors.green),
            _buildCategoryItem('Marka', 18, Colors.orange),
            _buildCategoryItem('Rambu', 15, Colors.purple),
            _buildCategoryItem('Drainase', 12, Colors.teal),
            _buildCategoryItem('Penerangan', 8, Colors.indigo),
          ],
        ),
      );
  }

  Widget _buildCategoryItem(String category, int count, Color color) {
    final percentage = (count / 121 * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(category),
          ),
          Text(
            '$count ($percentage%)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChart() {
    return EnhancedCard(
      padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Temuan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusItem('Selesai', 142, Helpers.getStatusColor('completed')),
            _buildStatusItem('Dalam Proses', 8, Helpers.getStatusColor('in_progress')),
            _buildStatusItem('Menunggu', 6, Helpers.getStatusColor('pending')),
          ],
        ),
      );
  }

  Widget _buildStatusItem(String status, int count, Color color) {
    final percentage = (count / 156 * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(status),
          ),
          Text(
            '$count ($percentage%)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChart() {
    return EnhancedCard(
      padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prioritas Temuan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPriorityItem('Kritis', 12, Helpers.getPriorityColor('critical')),
            _buildPriorityItem('Tinggi', 34, Helpers.getPriorityColor('high')),
            _buildPriorityItem('Sedang', 67, Helpers.getPriorityColor('medium')),
            _buildPriorityItem('Rendah', 43, Helpers.getPriorityColor('low')),
          ],
        ),
      );
  }

  Widget _buildPriorityItem(String priority, int count, Color color) {
    final percentage = (count / 156 * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(priority),
          ),
          Text(
            '$count ($percentage%)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return EnhancedCard(
      padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aktivitas Terbaru',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              'Temuan baru dilaporkan',
              'Lubang di KM 12+300',
              '2 jam yang lalu',
              Icons.add_circle,
              Colors.blue,
            ),
            _buildActivityItem(
              'Perbaikan selesai',
              'Pengecatan marka di KM 8+200',
              '4 jam yang lalu',
              Icons.check_circle,
              Colors.green,
            ),
            _buildActivityItem(
              'Status diupdate',
              'Perbaikan jembatan dimulai',
              '6 jam yang lalu',
              Icons.update,
              Colors.orange,
            ),
            _buildActivityItem(
              'Temuan baru dilaporkan',
              'Rambu rusak di KM 15+500',
              '1 hari yang lalu',
              Icons.add_circle,
              Colors.blue,
            ),
          ],
        ),
      );
  }

  Widget _buildActivityItem(String title, String description, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
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
} 