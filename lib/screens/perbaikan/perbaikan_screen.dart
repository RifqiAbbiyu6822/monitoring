import 'package:flutter/material.dart';
import '../../model/perbaikan.dart';
import '../../utils/helpers.dart';
import '../../utils/date_formatter.dart';
import 'perbaikan_form_screen.dart';

class PerbaikanScreen extends StatefulWidget {
  const PerbaikanScreen({super.key});

  @override
  State<PerbaikanScreen> createState() => _PerbaikanScreenState();
}

class _PerbaikanScreenState extends State<PerbaikanScreen> {
  List<Perbaikan> _perbaikanList = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadPerbaikanData();
  }

  void _loadPerbaikanData() {
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _perbaikanList = [
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
            status: 'in_progress',
            startDate: DateTime.now().subtract(const Duration(days: 2)),
            endDate: null,
            progress: 60.0,
            beforePhotos: [],
            progressPhotos: [],
            afterPhotos: [],
            assignedTo: 'Tim Perbaikan A',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            createdBy: 'admin',
            notes: 'Pengerjaan sedang berlangsung',
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
            status: 'pending',
            startDate: DateTime.now(),
            endDate: null,
            progress: 0.0,
            beforePhotos: [],
            progressPhotos: [],
            afterPhotos: [],
            assignedTo: 'Tim Perbaikan B',
            createdAt: DateTime.now(),
            createdBy: 'admin',
            notes: 'Menunggu persetujuan',
            cost: 15000000.0,
          ),
          Perbaikan(
            id: '3',
            temuanId: 'T003',
            category: 'marka',
            subcategory: 'pengecatan',
            section: 'C',
            kmPoint: '8+200',
            lane: 'Lajur 1',
            workDescription: 'Pengecatan ulang marka jalan',
            contractor: 'PT Cat Jaya',
            status: 'completed',
            startDate: DateTime.now().subtract(const Duration(days: 5)),
            endDate: DateTime.now().subtract(const Duration(days: 1)),
            progress: 100.0,
            beforePhotos: [],
            progressPhotos: [],
            afterPhotos: [],
            assignedTo: 'Tim Perbaikan C',
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            createdBy: 'admin',
            notes: 'Pekerjaan selesai sesuai target',
            cost: 3000000.0,
          ),
        ];
        _isLoading = false;
      });
    });
  }

  List<Perbaikan> get _filteredList {
    if (_selectedFilter == 'all') {
      return _perbaikanList;
    }
    return _perbaikanList.where((perbaikan) => 
      perbaikan.status == _selectedFilter
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perbaikan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredList.isEmpty
              ? _buildEmptyState()
              : _buildPerbaikanList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.build_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data perbaikan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + untuk menambah perbaikan baru',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerbaikanList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredList.length,
      itemBuilder: (context, index) {
        final perbaikan = _filteredList[index];
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
                ...[
                  const SizedBox(height: 4),
                  Text(
                    'Mulai: ${DateFormatter.formatDate(perbaikan.startDate)}',
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Semua'),
              value: 'all',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Menunggu'),
              value: 'pending',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Sedang Berlangsung'),
              value: 'in_progress',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Selesai'),
              value: 'completed',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PerbaikanFormScreen(),
      ),
    ).then((_) => _loadPerbaikanData());
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
                    _buildDetailItem('ID Temuan', perbaikan.temuanId),
                    _buildDetailItem('KM Point', perbaikan.kmPoint),
                    _buildDetailItem('Kategori', perbaikan.category),
                                         _buildDetailItem('Deskripsi', perbaikan.workDescription),
                     _buildDetailItem('Status', Helpers.getStatusText(perbaikan.status)),
                     _buildDetailItem('Ditugaskan Kepada', perbaikan.assignedTo),
                     _buildDetailItem('Tanggal Mulai', DateFormatter.formatDate(perbaikan.startDate)),
                     if (perbaikan.endDate != null)
                       _buildDetailItem('Tanggal Selesai', DateFormatter.formatDate(perbaikan.endDate!)),
                     if (perbaikan.notes?.isNotEmpty == true)
                       _buildDetailItem('Catatan', perbaikan.notes!),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PerbaikanFormScreen(perbaikan: perbaikan),
                      ),
                    ).then((_) => _loadPerbaikanData());
                  },
                  child: const Text('Edit Perbaikan'),
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