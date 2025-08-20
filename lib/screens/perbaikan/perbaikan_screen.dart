import 'package:flutter/material.dart';
import '../../model/perbaikan.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/animated_loading.dart';

class PerbaikanScreen extends StatefulWidget {
  const PerbaikanScreen({super.key});

  @override
  State<PerbaikanScreen> createState() => _PerbaikanScreenState();
}

class _PerbaikanScreenState extends State<PerbaikanScreen> {
  List<Perbaikan> _perbaikanList = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';

  final List<String> _filterOptions = ['Semua', 'Ongoing', 'Selesai', 'Pending'];

  @override
  void initState() {
    super.initState();
    _loadPerbaikanData();
  }

  Future<void> _loadPerbaikanData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
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
          status: 'ongoing',
          startDate: DateTime.now().subtract(const Duration(days: 2)),
          endDate: DateTime.now().add(const Duration(days: 3)),
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
          endDate: DateTime.now().add(const Duration(days: 7)),
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
          status: 'selesai',
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
  }

  List<Perbaikan> get _filteredPerbaikanList {
    if (_selectedFilter == 'Semua') {
      return _perbaikanList;
    }
    return _perbaikanList.where((perbaikan) {
      switch (_selectedFilter) {
        case 'Ongoing':
          return perbaikan.status == 'ongoing';
        case 'Selesai':
          return perbaikan.status == 'selesai';
        case 'Pending':
          return perbaikan.status == 'pending';
        default:
          return true;
      }
    }).toList();
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
                                'Progress',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${perbaikan.progress?.toStringAsFixed(0)}%',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing12),
                          LinearProgressIndicator(
                            value: (perbaikan.progress ?? 0) / 100,
                            backgroundColor: AppTheme.borderColor,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                            borderRadius: BorderRadius.circular(AppTheme.radius4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing20),

                    // Details Section
                    _buildDetailSection('Informasi Umum', [
                      _buildDetailItem('Kategori', perbaikan.category),
                      _buildDetailItem('Status', Helpers.getStatusText(perbaikan.status)),
                      _buildDetailItem('KM Point', perbaikan.kmPoint),
                      _buildDetailItem('Assigned To', perbaikan.assignedTo),
                    ]),
                    const SizedBox(height: AppTheme.spacing20),

                                         _buildDetailSection('Jadwal', [
                       _buildDetailItem('Start Date', DateFormatter.formatDate(perbaikan.startDate)),
                       _buildDetailItem('End Date', perbaikan.endDate != null ? DateFormatter.formatDate(perbaikan.endDate!) : 'Belum ditentukan'),
                       _buildDetailItem('Duration', '${perbaikan.endDate != null ? perbaikan.endDate!.difference(perbaikan.startDate).inDays : 0} hari'),
                     ]),
                     const SizedBox(height: AppTheme.spacing20),

                     _buildDetailSection('Deskripsi Pekerjaan', [
                       _buildDetailItem('Work Description', perbaikan.workDescription, isDescription: true),
                       _buildDetailItem('Contractor', perbaikan.contractor),
                       _buildDetailItem('Notes', perbaikan.notes ?? 'Tidak ada catatan'),
                     ]),
                     const SizedBox(height: AppTheme.spacing20),

                     _buildDetailSection('Biaya', [
                       _buildDetailItem('Cost', 'Rp ${perbaikan.cost?.toStringAsFixed(0) ?? '0'}'),
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
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radius12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: children,
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
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add perbaikan form
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
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
                Text(
                  'Filter Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Container(
                        margin: const EdgeInsets.only(right: AppTheme.spacing8),
                        child: FilterChip(
                          label: Text(filter),
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
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedLoading(size: 60, color: AppTheme.primaryColor),
                        SizedBox(height: AppTheme.spacing20),
                        Text(
                          'Memuat data perbaikan...',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : _filteredPerbaikanList.isEmpty
                    ? Center(
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
                                    'Tidak ada data perbaikan',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacing8),
                                  Text(
                                    'Belum ada data perbaikan untuk status ini',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPerbaikanData,
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
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            // Handle edit
                            break;
                          case 'delete':
                            // Handle delete
                            break;
                        }
                      },
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
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radius8),
                      ),
                      child: Text(
                        '${perbaikan.progress?.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.primaryColor,
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
                    const Spacer(),
                    Text(
                      DateFormatter.formatDate(perbaikan.startDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
                if (perbaikan.progress != null) ...[
                  const SizedBox(height: AppTheme.spacing12),
                  LinearProgressIndicator(
                    value: perbaikan.progress! / 100,
                    backgroundColor: AppTheme.borderColor,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    borderRadius: BorderRadius.circular(AppTheme.radius4),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 