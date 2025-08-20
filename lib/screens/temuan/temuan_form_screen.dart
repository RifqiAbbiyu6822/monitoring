// lib/screens/temuan/temuan_form_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/form_components.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';
import '../../services/local_storage_service.dart';

class TemuanFormScreen extends StatefulWidget {
  final String? temuanId;

  const TemuanFormScreen({super.key, this.temuanId});

  @override
  State<TemuanFormScreen> createState() => _TemuanFormScreenState();
}

class _TemuanFormScreenState extends State<TemuanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _kmPointController = TextEditingController();
  final _notesController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  final LocalStorageService _storageService = LocalStorageService();

  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedSection;
  String? _selectedLane;
  String? _selectedPriority;
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isEditMode = false;

  final List<String> _categories = ['jalan', 'jembatan', 'marka', 'rambu', 'drainase', 'penerangan'];
  final List<String> _sections = ['A', 'B', 'C', 'D'];
  final List<String> _lanes = ['Lajur 1', 'Lajur 2', 'Lajur 3', 'Lajur 4', 'Bahu Kiri', 'Bahu Kanan'];
  final List<String> _priorities = ['low', 'medium', 'high', 'critical'];

  final Map<String, List<String>> _subcategories = {
    'jalan': ['lubang', 'retak', 'aus', 'amblas'],
    'jembatan': ['kerusakan', 'korosi', 'retak', 'kebocoran'],
    'marka': ['faded', 'rusak', 'hilang', 'tidak_terlihat'],
    'rambu': ['rusak', 'hilang', 'terbalik', 'tertutup'],
    'drainase': ['tersumbat', 'rusak', 'bocor', 'tidak_ada'],
    'penerangan': ['mati', 'redup', 'rusak', 'tidak_ada'],
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    if (widget.temuanId != null) {
      _isEditMode = true;
      _loadTemuanData();
    }
  }

  Future<void> _loadTemuanData() async {
    if (widget.temuanId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final temuan = await _storageService.getTemuanById(widget.temuanId!);
      if (temuan != null) {
        _descriptionController.text = temuan.description;
        _kmPointController.text = temuan.kmPoint;
        _notesController.text = temuan.notes ?? '';
        _latitudeController.text = temuan.latitude.toString();
        _longitudeController.text = temuan.longitude.toString();

        setState(() {
          _selectedCategory = temuan.category;
          _selectedSubcategory = temuan.subcategory;
          _selectedSection = temuan.section;
          _selectedLane = temuan.lane;
          _selectedPriority = temuan.priority;
          _selectedDate = temuan.createdAt;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memuat data temuan');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _kmPointController.dispose();
    _notesController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
      _selectedSubcategory = null;
    });
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final temuanData = {
        'category': _selectedCategory!,
        'subcategory': _selectedSubcategory!,
        'section': _selectedSection!,
        'kmPoint': _kmPointController.text.trim(),
        'lane': _selectedLane!,
        'description': _descriptionController.text.trim(),
        'priority': _selectedPriority!,
        'latitude': double.tryParse(_latitudeController.text.trim()) ?? 0.0,
        'longitude': double.tryParse(_longitudeController.text.trim()) ?? 0.0,
        'photos': <String>[],
        'createdBy': 'Current User', // Replace with actual user
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      };

      if (_isEditMode) {
        await _storageService.updateTemuan(widget.temuanId!, temuanData);
        _showSuccessSnackBar('Temuan berhasil diperbarui');
      } else {
        await _storageService.addTemuan(temuanData);
        _showSuccessSnackBar('Temuan berhasil ditambahkan');
      }

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      _showErrorSnackBar(_isEditMode ? 'Gagal memperbarui temuan' : 'Gagal menambah temuan');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius12),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Temuan' : 'Temuan Baru'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.surfaceColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _onSubmit,
              child: Text(_isEditMode ? 'Simpan' : 'Tambah'),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _isLoading && _isEditMode
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeaderSection(),
                    const SizedBox(height: AppTheme.spacing24),

                    // Location Information
                    _buildLocationSection(),
                    const SizedBox(height: AppTheme.spacing24),

                    // Temuan Details
                    _buildDetailsSection(),
                    const SizedBox(height: AppTheme.spacing24),

                    // Coordinates Section
                    _buildCoordinatesSection(),
                    const SizedBox(height: AppTheme.spacing32),

                    // Submit Button
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radius12),
            ),
            child: Icon(
              _isEditMode ? Icons.edit : Icons.add_circle_outline,
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
                  _isEditMode ? 'Edit Temuan' : 'Laporkan Temuan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  _isEditMode
                      ? 'Perbarui informasi temuan'
                      : 'Isi form di bawah untuk melaporkan temuan baru',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return FormSection(
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
          validator: Validators.validateKmPoint,
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return FormSection(
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
    );
  }

  Widget _buildCoordinatesSection() {
    return FormSection(
      title: 'Koordinat GPS',
      subtitle: 'Koordinat lokasi temuan (opsional)',
      children: [
        Row(
          children: [
            Expanded(
              child: EnhancedTextField(
                label: 'Latitude',
                hint: 'Contoh: -6.2088',
                controller: _latitudeController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.my_location),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final lat = double.tryParse(value);
                    if (lat == null) return 'Format latitude tidak valid';
                    if (lat < -90 || lat > 90) return 'Latitude harus antara -90 dan 90';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: EnhancedTextField(
                label: 'Longitude',
                hint: 'Contoh: 106.8456',
                controller: _longitudeController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.place),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final lng = double.tryParse(value);
                    if (lng == null) return 'Format longitude tidak valid';
                    if (lng < -180 || lng > 180) return 'Longitude harus antara -180 dan 180';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: AppTheme.infoColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radius12),
            border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.infoColor,
                size: 20,
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Text(
                  'Koordinat GPS akan membantu lokalisasi temuan dengan lebih akurat',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.infoColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onSubmit,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isEditMode ? 'Perbarui Temuan' : 'Simpan Temuan',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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