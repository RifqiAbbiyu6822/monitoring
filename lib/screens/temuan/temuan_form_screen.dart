import 'package:flutter/material.dart';
import 'dart:io';
import '../../model/temuan.dart';

class TemuanFormScreen extends StatefulWidget {
  final String category;
  final String subcategory;

  const TemuanFormScreen({
    super.key,
    required this.category,
    required this.subcategory,
  });

  @override
  State<TemuanFormScreen> createState() => _TemuanFormScreenState();
}

class _TemuanFormScreenState extends State<TemuanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _kmController = TextEditingController();
  final _laneController = TextEditingController();
  
  String? _selectedPriority = 'Medium';
  String? _selectedSection;
  String? _selectedLane;
  List<File> _photos = [];
  Map<String, double>? _location;
  
  final List<String> _priorities = ['Low', 'Medium', 'High', 'Critical'];
  final List<String> _sections = [
    'Section 1 (KM 0+000 - KM 5+000)',
    'Section 2 (KM 5+000 - KM 10+000)',
    'Section 3 (KM 10+000 - KM 15+000)',
    'Section 4 (KM 15+000 - KM 20+000)',
  ];
  
  final List<String> _lanes = [
    'Bahu Luar',
    'Bahu Dalam',
    'Lajur 1',
    'Lajur 2',
    'Lajur 3',
    'Median',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _kmController.dispose();
    _laneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Temuan'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _resetForm,
            child: const Text('Reset'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.category, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Kategori:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(widget.category),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.subdirectory_arrow_right, 
                            color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Sub-kategori:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(widget.subcategory)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section Selection
              _buildSectionTitle('Lokasi'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedSection,
                decoration: InputDecoration(
                  labelText: 'Pilih Section',
                  prefixIcon: const Icon(Icons.map),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _sections.map((section) {
                  return DropdownMenuItem(
                    value: section,
                    child: Text(section, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSection = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih section';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // KM Point
              TextFormField(
                controller: _kmController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'KM Point (contoh: 12+300)',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan KM point';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Lane Selection
              DropdownButtonFormField<String>(
                value: _selectedLane,
                decoration: InputDecoration(
                  labelText: 'Pilih Lajur/Bahu',
                  prefixIcon: const Icon(Icons.directions_car),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _lanes.map((lane) {
                  return DropdownMenuItem(
                    value: lane,
                    child: Text(lane),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLane = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih lajur/bahu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // GPS Location
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Lokasi GPS akan diambil otomatis',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Description
              _buildSectionTitle('Deskripsi Temuan'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Deskripsi detail temuan',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Jelaskan kondisi temuan secara detail...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan deskripsi temuan';
                  }
                  if (value.length < 20) {
                    return 'Deskripsi minimal 20 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Priority
              _buildSectionTitle('Prioritas'),
              const SizedBox(height: 12),
              Row(
                children: _priorities.map((priority) {
                  Color getColor() {
                    switch (priority) {
                      case 'Low':
                        return Colors.green;
                      case 'Medium':
                        return Colors.yellow.shade700;
                      case 'High':
                        return Colors.orange;
                      case 'Critical':
                        return Colors.red;
                      default:
                        return Colors.grey;
                    }
                  }

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(
                          priority,
                          style: TextStyle(
                            color: _selectedPriority == priority
                                ? Colors.white
                                : getColor(),
                            fontSize: 12,
                          ),
                        ),
                        selected: _selectedPriority == priority,
                        selectedColor: getColor(),
                        onSelected: (selected) {
                          setState(() {
                            _selectedPriority = priority;
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Photo Section
              _buildSectionTitle('Dokumentasi Foto'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(Icons.camera_alt, color: Colors.grey.shade600, size: 48),
                    const SizedBox(height: 8),
                    const Text(
                      'Fitur foto akan segera hadir',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Simpan Temuan',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _resetForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Form'),
        content: const Text('Apakah Anda yakin ingin mereset form ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _formKey.currentState?.reset();
                _descriptionController.clear();
                _kmController.clear();
                _laneController.clear();
                _selectedPriority = 'Medium';
                _selectedSection = null;
                _selectedLane = null;
                _photos.clear();
                _location = null;
              });
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_photos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tambahkan minimal 1 foto dokumentasi'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_location == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tentukan lokasi GPS'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Create Temuan object
      final temuan = Temuan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: widget.category,
        subcategory: widget.subcategory,
        section: _selectedSection!,
        kmPoint: _kmController.text,
        lane: _selectedLane!,
        description: _descriptionController.text,
        priority: _selectedPriority!,
        status: 'Pending',
        latitude: _location!['latitude']!,
        longitude: _location!['longitude']!,
        photos: _photos.map((e) => e.path).toList(),
        createdAt: DateTime.now(),
        createdBy: 'Petugas 001', // This should come from user session
      );

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: const Text('Berhasil'),
          content: Text(
            'Temuan ${widget.subcategory} berhasil disimpan dengan ID: ${temuan.id}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Back to category selection
              },
              child: const Text('Selesai'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _resetForm(); // Reset form for new entry
              },
              child: const Text('Buat Temuan Baru'),
            ),
          ],
        ),
      );
    }
  }
}