import 'package:flutter/material.dart';
import '../../widgets/form_components.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';

class TemuanFormScreen extends StatefulWidget {
  const TemuanFormScreen({super.key});

  @override
  State<TemuanFormScreen> createState() => _TemuanFormScreenState();
}

class _TemuanFormScreenState extends State<TemuanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _kmPointController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedSection;
  String? _selectedLane;
  String? _selectedPriority;
  DateTime? _selectedDate;

  final List<String> _categories = ['jalan', 'jembatan', 'marka', 'rambu', 'drainase', 'penerangan'];
  final List<String> _sections = ['A', 'B', 'C', 'D'];
  final List<String> _lanes = ['Lajur 1', 'Lajur 2', 'Lajur 3', 'Lajur 4', 'Bahul', 'Bahu Kanan'];
  final List<String> _priorities = ['low', 'medium', 'high', 'critical'];

  Map<String, List<String>> _subcategories = {
    'jalan': ['lubang', 'retak', 'aus', 'amblas'],
    'jembatan': ['kerusakan', 'korosi', 'retak', 'kebocoran'],
    'marka': ['faded', 'rusak', 'hilang', 'tidak_terlihat'],
    'rambu': ['rusak', 'hilang', 'terbalik', 'tertutup'],
    'drainase': ['tersumbat', 'rusak', 'bocor', 'tidak_ada'],
    'penerangan': ['mati', 'redup', 'rusak', 'tidak_ada'],
  };

  @override
  void dispose() {
    _descriptionController.dispose();
    _kmPointController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
      _selectedSubcategory = null;
    });
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Temuan berhasil disimpan'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius12),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Temuan Baru'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.surfaceColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _onSubmit,
            child: const Text('Simpan'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.radius16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacing12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radius12),
                          ),
                          child: Icon(
                            Icons.add_circle_outline,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Laporkan Temuan',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacing4),
                              Text(
                                'Isi form di bawah untuk melaporkan temuan baru',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),

              // Form Sections
              FormSection(
                title: 'Informasi Lokasi',
                subtitle: 'Detail lokasi temuan',
                children: [
                  EnhancedDropdownField<String>(
                    label: 'Kategori',
                    hint: 'Pilih kategori',
                    value: _selectedCategory,
                    items: _categories,
                    itemText: (category) => _getCategoryText(category),
                    onChanged: _onCategoryChanged,
                    prefixIcon: const Icon(Icons.category),
                    validator: (value) {
                      if (value == null) return 'Kategori harus dipilih';
                      return null;
                    },
                  ),
                  if (_selectedCategory != null)
                    EnhancedDropdownField<String>(
                      label: 'Sub Kategori',
                      hint: 'Pilih sub kategori',
                      value: _selectedSubcategory,
                      items: _subcategories[_selectedCategory!] ?? [],
                      itemText: (subcategory) => _getSubcategoryText(subcategory),
                      onChanged: (value) => setState(() => _selectedSubcategory = value),
                      prefixIcon: const Icon(Icons.subdirectory_arrow_right),
                      validator: (value) {
                        if (value == null) return 'Sub kategori harus dipilih';
                        return null;
                      },
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: EnhancedDropdownField<String>(
                          label: 'Seksi',
                          hint: 'Pilih seksi',
                          value: _selectedSection,
                          items: _sections,
                          itemText: (section) => section,
                          onChanged: (value) => setState(() => _selectedSection = value),
                          prefixIcon: const Icon(Icons.map),
                          validator: (value) {
                            if (value == null) return 'Seksi harus dipilih';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing16),
                      Expanded(
                        child: EnhancedDropdownField<String>(
                          label: 'Lajur',
                          hint: 'Pilih lajur',
                          value: _selectedLane,
                          items: _lanes,
                          itemText: (lane) => lane,
                          onChanged: (value) => setState(() => _selectedLane = value),
                          prefixIcon: const Icon(Icons.directions_car),
                          validator: (value) {
                            if (value == null) return 'Lajur harus dipilih';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                                     EnhancedTextField(
                     label: 'KM Point',
                     hint: 'Contoh: 12+300',
                     controller: _kmPointController,
                     prefixIcon: const Icon(Icons.location_on),
                     validator: (value) {
                       if (value == null || value.isEmpty) {
                         return 'KM Point harus diisi';
                       }
                       return null;
                     },
                   ),
                ],
              ),

              FormSection(
                title: 'Detail Temuan',
                subtitle: 'Deskripsi dan prioritas temuan',
                children: [
                                     EnhancedTextField(
                     label: 'Deskripsi',
                     hint: 'Jelaskan detail temuan',
                     controller: _descriptionController,
                     maxLines: 3,
                     prefixIcon: const Icon(Icons.description),
                     validator: (value) {
                       if (value == null || value.isEmpty) {
                         return 'Deskripsi harus diisi';
                       }
                       if (value.length < 10) {
                         return 'Deskripsi minimal 10 karakter';
                       }
                       return null;
                     },
                   ),
                  EnhancedDropdownField<String>(
                    label: 'Prioritas',
                    hint: 'Pilih prioritas',
                    value: _selectedPriority,
                    items: _priorities,
                    itemText: (priority) => _getPriorityText(priority),
                    onChanged: (value) => setState(() => _selectedPriority = value),
                    prefixIcon: const Icon(Icons.priority_high),
                    validator: (value) {
                      if (value == null) return 'Prioritas harus dipilih';
                      return null;
                    },
                  ),
                  EnhancedDateField(
                    label: 'Tanggal Temuan',
                    selectedDate: _selectedDate,
                    onDateSelected: (date) => setState(() => _selectedDate = date),
                    validator: (date) {
                      if (date == null) return 'Tanggal harus dipilih';
                      return null;
                    },
                  ),
                  EnhancedTextField(
                    label: 'Catatan Tambahan',
                    hint: 'Catatan tambahan (opsional)',
                    controller: _notesController,
                    maxLines: 2,
                    prefixIcon: const Icon(Icons.note),
                  ),
                ],
              ),

              // Photo Section
              FormSection(
                title: 'Foto Bukti',
                subtitle: 'Ambil foto untuk bukti temuan',
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing20),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(AppTheme.radius12),
                      border: Border.all(color: AppTheme.borderColor, style: BorderStyle.solid),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 48,
                          color: AppTheme.textTertiary,
                        ),
                        const SizedBox(height: AppTheme.spacing12),
                        Text(
                          'Ambil Foto',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          'Foto akan membantu tim perbaikan memahami kondisi temuan',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Handle photo capture
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Ambil Foto'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacing32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radius12),
                    ),
                  ),
                  child: const Text(
                    'Simpan Temuan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryText(String category) {
    switch (category) {
      case 'jalan':
        return 'Jalan';
      case 'jembatan':
        return 'Jembatan';
      case 'marka':
        return 'Marka Jalan';
      case 'rambu':
        return 'Rambu Lalu Lintas';
      case 'drainase':
        return 'Drainase';
      case 'penerangan':
        return 'Penerangan Jalan';
      default:
        return category;
    }
  }

  String _getSubcategoryText(String subcategory) {
    switch (subcategory) {
      case 'lubang':
        return 'Lubang';
      case 'retak':
        return 'Retak';
      case 'aus':
        return 'Aus';
      case 'amblas':
        return 'Amblas';
      case 'kerusakan':
        return 'Kerusakan';
      case 'korosi':
        return 'Korosi';
      case 'kebocoran':
        return 'Kebocoran';
      case 'faded':
        return 'Memudar';
      case 'rusak':
        return 'Rusak';
      case 'hilang':
        return 'Hilang';
      case 'tidak_terlihat':
        return 'Tidak Terlihat';
      case 'terbalik':
        return 'Terbalik';
      case 'tertutup':
        return 'Tertutup';
      case 'tersumbat':
        return 'Tersumbat';
      case 'bocor':
        return 'Bocor';
      case 'tidak_ada':
        return 'Tidak Ada';
      case 'mati':
        return 'Mati';
      case 'redup':
        return 'Redup';
      default:
        return subcategory;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'low':
        return 'Rendah';
      case 'medium':
        return 'Sedang';
      case 'high':
        return 'Tinggi';
      case 'critical':
        return 'Kritis';
      default:
        return priority;
    }
  }
}