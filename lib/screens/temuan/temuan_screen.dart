import 'package:flutter/material.dart';
import 'temuan_form_screen.dart';
import '../../model/temuan_category.dart';

class TemuanScreen extends StatefulWidget {
  const TemuanScreen({super.key});

  @override
  State<TemuanScreen> createState() => _TemuanScreenState();
}

class _TemuanScreenState extends State<TemuanScreen> {
  final List<TemuanCategory> categories = [
    TemuanCategory(
      id: '1',
      name: 'Kebersihan',
      icon: Icons.cleaning_services,
      color: Colors.blue,
      subcategories: [
        'Jalan - Bahu Luar',
        'Jalan - Bahu Dalam',
        'Taman & Landscaping',
        'Saluran Drainase',
        'Sampah & Limbah',
      ],
    ),
    TemuanCategory(
      id: '2',
      name: 'Perkerasan',
      icon: Icons.directions_car,
      color: Colors.grey,
      subcategories: [
        'Kerusakan Aspal',
        'Lubang Jalan',
        'Retak Permukaan',
        'Amblas',
        'Marka Jalan',
      ],
    ),
    TemuanCategory(
      id: '3',
      name: 'Penerangan',
      icon: Icons.lightbulb,
      color: Colors.yellow.shade700,
      subcategories: [
        'Lampu Jalan',
        'Lampu Terowongan',
        'Lampu Hazard',
        'Panel Listrik',
        'Kabel & Instalasi',
      ],
    ),
    TemuanCategory(
      id: '4',
      name: 'Struktur',
      icon: Icons.foundation,
      color: Colors.brown,
      subcategories: [
        'Pilar & Kolom',
        'Expansion Joint',
        'Bearing Pad',
        'Deck Jembatan',
        'Parapet',
      ],
    ),
    TemuanCategory(
      id: '5',
      name: 'Perlengkapan Jalan',
      icon: Icons.traffic,
      color: Colors.orange,
      subcategories: [
        'Rambu Lalu Lintas',
        'Guardrail',
        'Pagar Pembatas',
        'Reflektor',
        'Delineator',
      ],
    ),
    TemuanCategory(
      id: '6',
      name: 'Fasilitas',
      icon: Icons.business,
      color: Colors.purple,
      subcategories: [
        'Rest Area',
        'Toilet',
        'Pos Pengawas',
        'Shelter',
        'Fasilitas Darurat',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Temuan'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Buat Temuan', icon: Icon(Icons.add_circle_outline)),
              Tab(text: 'Daftar Temuan', icon: Icon(Icons.list_alt)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCreateTemuanTab(),
            _buildTemuanListTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateTemuanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pilih kategori temuan untuk melanjutkan pelaporan',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Kategori Temuan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(category);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(TemuanCategory category) {
    return InkWell(
      onTap: () {
        _showSubcategoryDialog(category);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                size: 32,
                color: category.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${category.subcategories.length} sub-kategori',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemuanListTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Daftar Temuan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Fitur ini akan segera hadir',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showSubcategoryDialog(TemuanCategory category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category.icon,
                          color: category.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: category.subcategories.length,
                    itemBuilder: (context, index) {
                      final subcategory = category.subcategories[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: category.color.withOpacity(0.1),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: category.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(subcategory),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TemuanFormScreen(
                                category: category.name,
                                subcategory: subcategory,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}