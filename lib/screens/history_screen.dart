import 'package:flutter/material.dart';
import '../model/temuan.dart';
import '../model/perbaikan.dart';
import '../utils/helpers.dart';
import '../utils/date_formatter.dart';
import '../widgets/animated_loading.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Temuan> _temuanHistory = [];
  List<Perbaikan> _perbaikanHistory = [];
  bool _isLoading = true;

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

  void _loadHistoryData() {
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _temuanHistory = [
          Temuan(
            id: 'T001',
            category: 'jalan',
            subcategory: 'lubang',
            section: 'A',
            kmPoint: '12+300',
            lane: 'Lajur 1',
            description: 'Lubang di jalan tol',
            priority: 'high',
            status: 'completed',
            latitude: -6.2088,
            longitude: 106.8456,
            photos: [],
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
            createdBy: 'Petugas A',
            updatedAt: DateTime.now().subtract(const Duration(days: 25)),
            updatedBy: 'Petugas A',
            notes: 'Sudah diperbaiki',
          ),
          Temuan(
            id: 'T002',
            category: 'jembatan',
            subcategory: 'kerusakan',
            section: 'B',
            kmPoint: '15+500',
            lane: 'Lajur 2',
            description: 'Kerusakan pada jembatan',
            priority: 'critical',
            status: 'completed',
            latitude: -6.2088,
            longitude: 106.8456,
            photos: [],
            createdAt: DateTime.now().subtract(const Duration(days: 45)),
            createdBy: 'Petugas B',
            updatedAt: DateTime.now().subtract(const Duration(days: 40)),
            updatedBy: 'Petugas B',
            notes: 'Perbaikan selesai',
          ),
        ];

        _perbaikanHistory = [
          Perbaikan(
            id: '1',
            temuanId: 'T001',
            category: 'jalan',
            subcategory: 'lubang',
            section: 'A',
            kmPoint: '12+300',
            lane: 'Lajur 1',
            workDescription: 'Perbaikan lubang di jalan tol',
            contractor: 'PT Jaya Konstruksi',
            status: 'completed',
            startDate: DateTime.now().subtract(const Duration(days: 28)),
            endDate: DateTime.now().subtract(const Duration(days: 25)),
            progress: 100.0,
            beforePhotos: [],
            progressPhotos: [],
            afterPhotos: [],
            assignedTo: 'Tim Perbaikan A',
            createdAt: DateTime.now().subtract(const Duration(days: 28)),
            createdBy: 'admin',
            notes: 'Pekerjaan selesai sesuai target',
            cost: 5000000.0,
          ),
          Perbaikan(
            id: '2',
            temuanId: 'T002',
            category: 'jembatan',
            subcategory: 'kerusakan',
            section: 'B',
            kmPoint: '15+500',
            lane: 'Lajur 2',
            workDescription: 'Perbaikan kerusakan pada jembatan',
            contractor: 'PT Bangun Jaya',
            status: 'completed',
            startDate: DateTime.now().subtract(const Duration(days: 42)),
            endDate: DateTime.now().subtract(const Duration(days: 40)),
            progress: 100.0,
            beforePhotos: [],
            progressPhotos: [],
            afterPhotos: [],
            assignedTo: 'Tim Perbaikan B',
            createdAt: DateTime.now().subtract(const Duration(days: 42)),
            createdBy: 'admin',
            notes: 'Perbaikan selesai',
            cost: 15000000.0,
          ),
        ];
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Temuan'),
            Tab(text: 'Perbaikan'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedLoading(size: 60, color: Colors.blue),
                  SizedBox(height: 20),
                  Text(
                    'Memuat riwayat...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTemuanHistory(),
                _buildPerbaikanHistory(),
              ],
            ),
    );
  }

  Widget _buildTemuanHistory() {
    if (_temuanHistory.isEmpty) {
      return _buildEmptyState('Temuan');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _temuanHistory.length,
      itemBuilder: (context, index) {
        final temuan = _temuanHistory[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Helpers.getStatusColor(temuan.status),
              child: Icon(
                Helpers.getCategoryIcon(temuan.category),
                color: Colors.white,
              ),
            ),
            title: Text(
              temuan.description,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('KM ${temuan.kmPoint}'),
                    const SizedBox(width: 16),
                                         Icon(Icons.person, size: 16, color: Colors.grey[600]),
                     const SizedBox(width: 4),
                     Text(temuan.createdBy),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Helpers.getPriorityColor(temuan.priority),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        Helpers.getPriorityText(temuan.priority),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Helpers.getStatusColor(temuan.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        Helpers.getStatusText(temuan.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                                 Text(
                   'Dilaporkan: ${DateFormatter.formatDate(temuan.createdAt)}',
                   style: TextStyle(
                     fontSize: 12,
                     color: Colors.grey[600],
                   ),
                 ),
                 if (temuan.updatedAt != null) ...[
                   Text(
                     'Update: ${DateFormatter.formatDate(temuan.updatedAt!)}',
                     style: TextStyle(
                       fontSize: 12,
                       color: Colors.grey[600],
                     ),
                   ),
                 ],
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () => _showTemuanDetail(temuan),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerbaikanHistory() {
    if (_perbaikanHistory.isEmpty) {
      return _buildEmptyState('Perbaikan');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _perbaikanHistory.length,
      itemBuilder: (context, index) {
        final perbaikan = _perbaikanHistory[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: Helpers.getStatusColor(perbaikan.status),
              child: Icon(
                Helpers.getCategoryIcon(perbaikan.category),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              perbaikan.workDescription,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'KM ${perbaikan.kmPoint}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        perbaikan.assignedTo,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${perbaikan.progress?.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Helpers.getStatusColor(perbaikan.status),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          Helpers.getStatusText(perbaikan.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Mulai: ${DateFormatter.formatDate(perbaikan.startDate)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (perbaikan.endDate != null) ...[
                  Text(
                    'Selesai: ${DateFormatter.formatDate(perbaikan.endDate!)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () => _showPerbaikanDetail(perbaikan),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == 'Temuan' ? Icons.search_outlined : Icons.build_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat $type',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showTemuanDetail(Temuan temuan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail Temuan',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailItem('ID', temuan.id),
                    _buildDetailItem('KM Point', temuan.kmPoint),
                    _buildDetailItem('Kategori', temuan.category),
                    _buildDetailItem('Sub Kategori', temuan.subcategory),
                    _buildDetailItem('Deskripsi', temuan.description),
                    _buildDetailItem('Prioritas', Helpers.getPriorityText(temuan.priority)),
                    _buildDetailItem('Status', Helpers.getStatusText(temuan.status)),
                                         _buildDetailItem('Dilaporkan Oleh', temuan.createdBy),
                     _buildDetailItem('Tanggal Laporan', DateFormatter.formatDate(temuan.createdAt)),
                     if (temuan.updatedAt != null)
                       _buildDetailItem('Tanggal Update', DateFormatter.formatDate(temuan.updatedAt!)),
                     if (temuan.notes?.isNotEmpty == true)
                       _buildDetailItem('Catatan', temuan.notes!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPerbaikanDetail(Perbaikan perbaikan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail Perbaikan',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailItem('ID', perbaikan.id),
                    _buildDetailItem('ID Temuan', perbaikan.temuanId),
                    _buildDetailItem('KM Point', perbaikan.kmPoint),
                    _buildDetailItem('Kategori', perbaikan.category),
                    _buildDetailItem('Deskripsi', perbaikan.workDescription),
                    _buildDetailItem('Status', Helpers.getStatusText(perbaikan.status)),
                    _buildDetailItem('Ditugaskan Kepada', perbaikan.assignedTo),
                    _buildDetailItem('Kontraktor', perbaikan.contractor),
                    _buildDetailItem('Tanggal Mulai', DateFormatter.formatDate(perbaikan.startDate)),
                    if (perbaikan.endDate != null)
                      _buildDetailItem('Tanggal Selesai', DateFormatter.formatDate(perbaikan.endDate!)),
                    _buildDetailItem('Progress', '${perbaikan.progress?.toStringAsFixed(0)}%'),
                    if (perbaikan.cost != null)
                      _buildDetailItem('Biaya', 'Rp ${perbaikan.cost!.toStringAsFixed(0)}'),
                    if (perbaikan.notes?.isNotEmpty == true)
                      _buildDetailItem('Catatan', perbaikan.notes!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
} 