// lib/screens/temuan/temuan_form_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/form_components.dart';
import '../../widgets/priority_info_widget.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';
import '../../services/local_storage_service.dart';
import '../../config/category_config.dart';

class TemuanFormScreen extends StatefulWidget {
  final String? temuanId;
  final String? preselectedCategory;

  const TemuanFormScreen({
    super.key, 
    this.temuanId,
    this.preselectedCategory,
  });

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

  // Simplified sections and lanes
  final List<String> _sections = ['A', 'B'];
  final List<String> _lanes = ['Lajur 1', 'Lajur 2', 'Bahu Dalam', 'Bahu Luar'];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedCategory = widget.preselectedCategory;
    
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
      _selectedLane = null; // Reset lane when category changes
    });
  }

  CategoryConfig? get _currentCategoryConfig {
    if (_selectedCategory == null) return null;
    return AppCategoryConfigs.getConfig(_selectedCategory!);
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
        'lane': _selectedLane ?? 'N/A',
        'description': _descriptionController.text.trim(),
        'priority': _selectedPriority!,
        'latitude': double.tryParse(_latitudeController.text.trim()) ?? 0.0,
        'longitude': double.tryParse(_longitudeController.text.trim()) ?? 0.0,
        'photos': <String>[],
        'createdBy': 'Current User',
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      };

      if (_isEditMode) {
        await _storageService.updateTemuan(widget.temuanId!, temuanData);
        _showSuccessSnackBar('Temuan berhasil diperbarui');
      } else {
        await _storageService.addTemuan(temuanData);
        _showSuccessSnackBar('Temuan berhasil ditambahkan');
      }

      Navigator.pop(context, true);
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

                    // Category Selection (using new widget)
                    if (!_isEditMode) ...[
                      CategoryInfoWidget(
                        selectedCategory: _selectedCategory,
                        onCategoryChanged: _onCategoryChanged,
                        showDescription: true,
                      ),
                      const SizedBox(height: AppTheme.spacing24),
                    ],

                    // Location Information (conditional based on category)
                    if (_selectedCategory != null) ...[
                      _buildLocationSection(),
                      const SizedBox(height: AppTheme.spacing24),
                    ],

                    // Temuan Details
                    if (_selectedCategory != null) ...[
                      _buildDetailsSection(),
                      const SizedBox(height: AppTheme.spacing24),
                    ],

                    // Priority Selection (using new widget)
                    if (_selectedCategory != null) ...[
                      PriorityInfoWidget(
                        selectedPriority: _selectedPriority,
                        onPriorityChanged: (priority) => setState(() => _selectedPriority = priority),
                        showDescription: true,
                      ),
                      const SizedBox(height: AppTheme.spacing24),
                    ],

                    // Coordinates Section
                    if (_selectedCategory != null) ...[
                      _buildCoordinatesSection(),
                      const SizedBox(height: AppTheme.spacing32),
                    ],

                    // Submit Button
                    if (_selectedCategory != null) _buildSubmitButton(),
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
              color: (_currentCategoryConfig?.color ?? AppTheme.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radius12),
            ),
            child: Icon(
              _currentCategoryConfig?.icon ?? (_isEditMode ? Icons.edit : Icons.add_circle_outline),
              color: _currentCategoryConfig?.color ?? AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode ? 'Edit Temuan' : (_selectedCategory != null ? 'Temuan ${_currentCategoryConfig!.name}' : 'Laporkan Temuan'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  _selectedCategory != null 
                      ? _currentCategoryConfig!.description
                      : 'Pilih kategori untuk melanjutkan',
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
    final config = _currentCategoryConfig!;
    
    return FormSection(
      title: 'Informasi Lokasi',
      subtitle: 'Detail lokasi temuan ${config.name.toLowerCase()}',
      children: [
        // Sub Category
        EnhancedDropdownField<String>(
          label: 'Jenis ${config.name}',
          hint: 'Pilih jenis ${config.name.toLowerCase()}',
          value: _selectedSubcategory,
          items: config.subcategories,
          itemText: (subcategory) => subcategory,
          onChanged: (value) => setState(() => _selectedSubcategory = value),
          prefixIcon: Icon(config.icon),
          validator: (value) {
            if (value == null) return 'Jenis ${config.name.toLowerCase()} harus dipilih';
            return null;
          },
        ),

        // Section (always show)
        if (config.showSection)
          EnhancedDropdownField<String>(
            label: 'Seksi',
            hint: 'Pilih seksi',
            value: _selectedSection,
            items: _sections,
            itemText: (section) => 'Seksi $section',
            onChanged: (value) => setState(() => _selectedLane = value),
            prefixIcon: const Icon(Icons.directions_car),
            validator: (value) {
              if (value == null) return 'Lajur/posisi harus dipilih';
              return null;
            },
          ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    final config = _currentCategoryConfig!;
    
    return FormSection(
      title: 'Detail Temuan',
      subtitle: 'Deskripsi dan informasi temuan ${config.name.toLowerCase()}',
      children: [
        EnhancedTextField(
          label: 'Deskripsi Detail',
          hint: 'Jelaskan kondisi ${config.name.toLowerCase()} yang ditemukan secara detail',
          controller: _descriptionController,
          maxLines: 4,
          prefixIcon: Icon(config.icon),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Deskripsi harus diisi';
            }
            if (value.length < 15) {
              return 'Deskripsi minimal 15 karakter untuk memberikan informasi yang cukup';
            }
            return null;
          },
          helperText: 'Berikan deskripsi yang jelas dan detail untuk memudahkan tim lapangan',
        ),
        
        EnhancedDateField(
          label: 'Tanggal Temuan',
          selectedDate: _selectedDate,
          onDateSelected: (date) => setState(() => _selectedDate = date),
          validator: (date) {
            if (date == null) return 'Tanggal harus dipilih';
            if (date.isAfter(DateTime.now())) return 'Tanggal tidak boleh di masa depan';
            return null;
          },
        ),
        
        EnhancedTextField(
          label: 'Catatan Tambahan',
          hint: 'Informasi tambahan yang diperlukan (opsional)',
          controller: _notesController,
          maxLines: 3,
          prefixIcon: const Icon(Icons.note),
          helperText: 'Tambahkan informasi seperti cuaca, kondisi lalu lintas, atau hal penting lainnya',
        ),
      ],
    );
  }

  Widget _buildCoordinatesSection() {
    return FormSection(
      title: 'Koordinat GPS',
      subtitle: 'Koordinat lokasi temuan untuk pemetaan yang akurat',
      children: [
        Row(
          children: [
            Expanded(
              child: EnhancedTextField(
                label: 'Latitude',
                hint: 'Contoh: -6.2088',
                controller: _latitudeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
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
        
        // GPS Helper Section
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.infoColor.withOpacity(0.1),
                AppTheme.primaryColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radius12),
            border: Border.all(color: AppTheme.infoColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing6),
                    decoration: BoxDecoration(
                      color: AppTheme.infoColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radius6),
                    ),
                    child: Icon(
                      Icons.gps_fixed,
                      color: AppTheme.infoColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Text(
                    'Tips Koordinat GPS',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.infoColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                '• Gunakan aplikasi GPS atau Google Maps untuk mendapatkan koordinat yang akurat\n'
                '• Pastikan berada di lokasi temuan saat mengambil koordinat\n'
                '• Koordinat akan membantu tim lapangan menemukan lokasi dengan tepat',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      children: [
        // Summary before submit
        if (_selectedCategory != null && _selectedSubcategory != null && _selectedPriority != null) ...[
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppTheme.radius12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ringkasan Temuan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing12),
                Row(
                  children: [
                    Icon(
                      _currentCategoryConfig!.icon,
                      color: _currentCategoryConfig!.color,
                      size: 16,
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Text(
                      '${_currentCategoryConfig!.name} - $_selectedSubcategory',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing8),
                Row(
                  children: [
                    Icon(
                      PriorityConfig.getPriorityIcon(_selectedPriority!),
                      color: PriorityConfig.getPriorityColor(_selectedPriority!),
                      size: 16,
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Text(
                      'Prioritas: ${PriorityConfig.getPriorityName(_selectedPriority!)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PriorityConfig.getPriorityColor(_selectedPriority!),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (_selectedSection != null && _kmPointController.text.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacing8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppTheme.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Text(
                        'Lokasi: Seksi $_selectedSection, KM ${_kmPointController.text}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing20),
        ],
        
        // Submit button
        SizedBox(
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isEditMode ? Icons.save : Icons.send,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Text(
                        _isEditMode ? 'Perbarui Temuan' : 'Kirim Laporan Temuan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
} (value) => setState(() => _selectedSection = value),
            prefixIcon: const Icon(Icons.map),
            validator: (value) {
              if (value == null) return 'Seksi harus dipilih';
              return null;
            },
          ),

        // KM Point (always show for road infrastructure)
        if (config.showKmPoint)
          EnhancedTextField(
            label: 'KM Point',
            hint: 'Contoh: 12+300',
            controller: _kmPointController,
            prefixIcon: const Icon(Icons.location_on),
            validator: Validators.validateKmPoint,
          ),

        // Lane (conditional)
        if (config.showLane)
          EnhancedDropdownField<String>(
            label: 'Lajur/Posisi',
            hint: 'Pilih lajur atau posisi',
            value: _selectedLane,
            items: _lanes,
            itemText: (lane) => lane,
            onChanged:// lib/screens/temuan/temuan_form_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/form_components.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';
import '../../services/local_storage_service.dart';

class TemuanFormScreen extends StatefulWidget {
  final String? temuanId;
  final String? preselectedCategory;

  const TemuanFormScreen({
    super.key, 
    this.temuanId,
    this.preselectedCategory,
  });

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

  // Simplified sections and lanes
  final List<String> _sections = ['A', 'B'];
  final List<String> _lanes = ['Lajur 1', 'Lajur 2', 'Bahu Dalam', 'Bahu Luar'];
  final List<String> _priorities = ['low', 'medium', 'high', 'critical'];

  // Category definitions with specific fields
  final Map<String, CategoryConfig> _categoryConfigs = {
    'jalan': CategoryConfig(
      name: 'Jalan',
      icon: Icons.directions_car,
      color: Colors.blue,
      subcategories: ['Lubang', 'Retak', 'Aus', 'Amblas', 'Gelombang'],
      showKmPoint: true,
      showLane: true,
      showSection: true,
      description: 'Kerusakan pada permukaan jalan',
    ),
    'jembatan': CategoryConfig(
      name: 'Jembatan',
      icon: Icons.architecture,
      color: Colors.brown,
      subcategories: ['Kerusakan Struktur', 'Korosi', 'Retak Beton', 'Kebocoran', 'Joint Rusak'],
      showKmPoint: true,
      showLane: false,
      showSection: true,
      description: 'Kerusakan pada struktur jembatan',
    ),
    'marka': CategoryConfig(
      name: 'Marka Jalan',
      icon: Icons.straighten,
      color: Colors.orange,
      subcategories: ['Memudar', 'Rusak', 'Hilang', 'Tidak Terlihat', 'Salah Posisi'],
      showKmPoint: true,
      showLane: true,
      showSection: true,
      description: 'Kondisi marka dan garis jalan',
    ),
    'rambu': CategoryConfig(
      name: 'Rambu',
      icon: Icons.traffic,
      color: Colors.red,
      subcategories: ['Rusak', 'Hilang', 'Terbalik', 'Tertutup', 'Pudar'],
      showKmPoint: true,
      showLane: false,
      showSection: true,
      description: 'Kondisi rambu lalu lintas',
    ),
    'drainase': CategoryConfig(
      name: 'Drainase',
      icon: Icons.water_drop,
      color: Colors.teal,
      subcategories: ['Tersumbat', 'Rusak', 'Bocor', 'Tidak Ada', 'Dangkal'],
      showKmPoint: true,
      showLane: false,
      showSection: true,
      description: 'Kondisi sistem drainase',
    ),
    'penerangan': CategoryConfig(
      name: 'Penerangan',
      icon: Icons.lightbulb,
      color: Colors.amber.shade700,
      subcategories: ['Mati', 'Redup', 'Rusak', 'Tidak Ada', 'Berkedip'],
      showKmPoint: true,
      showLane: false,
      showSection: true,
      description: 'Kondisi lampu penerangan jalan',
    ),
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedCategory = widget.preselectedCategory;
    
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
      _selectedLane = null; // Reset lane when category changes
    });
  }

  CategoryConfig? get _currentCategoryConfig {
    if (_selectedCategory == null) return null;
    return _categoryConfigs[_selectedCategory!];
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
        'lane': _selectedLane ?? 'N/A',
        'description': _descriptionController.text.trim(),
        'priority': _selectedPriority!,
        'latitude': double.tryParse(_latitudeController.text.trim()) ?? 0.0,
        'longitude': double.tryParse(_longitudeController.text.trim()) ?? 0.0,
        'photos': <String>[],
        'createdBy': 'Current User',
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      };

      if (_isEditMode) {
        await _storageService.updateTemuan(widget.temuanId!, temuanData);
        _showSuccessSnackBar('Temuan berhasil diperbarui');
      } else {
        await _storageService.addTemuan(temuanData);
        _showSuccessSnackBar('Temuan berhasil ditambahkan');
      }

      Navigator.pop(context, true);
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

                    // Category Selection
                    if (!_isEditMode) ...[
                      _buildCategorySelectionSection(),
                      const SizedBox(height: AppTheme.spacing24),
                    ],

                    // Location Information (conditional based on category)
                    if (_selectedCategory != null) ...[
                      _buildLocationSection(),
                      const SizedBox(height: AppTheme.spacing24),
                    ],

                    // Temuan Details
                    if (_selectedCategory != null) ...[
                      _buildDetailsSection(),
                      const SizedBox(height: AppTheme.spacing24),
                    ],

                    // Coordinates Section
                    if (_selectedCategory != null) ...[
                      _buildCoordinatesSection(),
                      const SizedBox(height: AppTheme.spacing32),
                    ],

                    // Submit Button
                    if (_selectedCategory != null) _buildSubmitButton(),
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
              color: (_currentCategoryConfig?.color ?? AppTheme.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radius12),
            ),
            child: Icon(
              _currentCategoryConfig?.icon ?? (_isEditMode ? Icons.edit : Icons.add_circle_outline),
              color: _currentCategoryConfig?.color ?? AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode ? 'Edit Temuan' : (_selectedCategory != null ? 'Temuan ${_currentCategoryConfig!.name}' : 'Laporkan Temuan'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  _selectedCategory != null 
                      ? _currentCategoryConfig!.description
                      : 'Pilih kategori untuk melanjutkan',
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

  Widget _buildCategorySelectionSection() {
    return FormSection(
      title: 'Pilih Kategori Temuan',
      subtitle: 'Tentukan jenis temuan yang akan dilaporkan',
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppTheme.spacing12,
            mainAxisSpacing: AppTheme.spacing12,
            childAspectRatio: 1.2,
          ),
          itemCount: _categoryConfigs.length,
          itemBuilder: (context, index) {
            final categoryKey = _categoryConfigs.keys.elementAt(index);
            final config = _categoryConfigs[categoryKey]!;
            final isSelected = _selectedCategory == categoryKey;
            
            return Container(
              decoration: BoxDecoration(
                color: isSelected ? config.color.withOpacity(0.1) : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radius12),
                border: Border.all(
                  color: isSelected ? config.color : AppTheme.borderColor,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? AppTheme.shadowSm : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onCategoryChanged(categoryKey),
                  borderRadius: BorderRadius.circular(AppTheme.radius12),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacing8),
                          decoration: BoxDecoration(
                            color: config.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radius8),
                          ),
                          child: Icon(
                            config.icon,
                            size: 24,
                            color: config.color,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          config.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: isSelected ? config.color : AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          '${config.subcategories.length} jenis',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    final config = _currentCategoryConfig!;
    
    return FormSection(
      title: 'Informasi Lokasi',
      subtitle: 'Detail lokasi temuan ${config.name.toLowerCase()}',
      children: [
        // Sub Category
        EnhancedDropdownField<String>(
          label: 'Jenis ${config.name}',
          hint: 'Pilih jenis ${config.name.toLowerCase()}',
          value: _selectedSubcategory,
          items: config.subcategories,
          itemText: (subcategory) => subcategory,
          onChanged: (value) => setState(() => _selectedSubcategory = value),
          prefixIcon: Icon(config.icon),
          validator: (value) {
            if (value == null) return 'Jenis ${config.name.toLowerCase()} harus dipilih';
            return null;
          },
        ),

        // Section (always show)
        if (config.showSection)
          EnhancedDropdownField<String>(
            label: 'Seksi',
            hint: 'Pilih seksi',
            value: _selectedSection,
            items: _sections,
            itemText: (section) => 'Seksi $section',
            onChanged: (value) => setState(() => _selectedSection = value),
            prefixIcon: const Icon(Icons.map),
            validator: (value) {
              if (value == null) return 'Seksi harus dipilih';
              return null;
            },
          ),

        // KM Point (always show for road infrastructure)
        if (config.showKmPoint)
          EnhancedTextField(
            label: 'KM Point',
            hint: 'Contoh: 12+300',
            controller: _kmPointController,
            prefixIcon: const Icon(Icons.location_on),
            validator: Validators.validateKmPoint,
          ),

        // Lane (conditional)
        if (config.showLane)
          EnhancedDropdownField<String>(
            label: 'Lajur/Posisi',
            hint: 'Pilih lajur atau posisi',
            value: _selectedLane,
            items: _lanes,
            itemText: (lane) => lane,
            onChanged: (value) => setState(() => _selectedLane = value),
            prefixIcon: const Icon(Icons.directions_car),
            validator: (value) {
              if (value == null) return 'Lajur/posisi harus dipilih';
              return null;
            },
          ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    final config = _currentCategoryConfig!;
    
    return FormSection(
      title: 'Detail Temuan',
      subtitle: 'Deskripsi dan prioritas temuan ${config.name.toLowerCase()}',
      children: [
        EnhancedTextField(
          label: 'Deskripsi Detail',
          hint: 'Jelaskan kondisi ${config.name.toLowerCase()} yang ditemukan',
          controller: _descriptionController,
          maxLines: 3,
          prefixIcon: Icon(config.icon),
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
          label: 'Tingkat Prioritas',
          hint: 'Pilih tingkat prioritas',
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
          hint: 'Informasi tambahan yang diperlukan (opsional)',
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
      subtitle: 'Koordinat lokasi temuan untuk pemetaan (opsional)',
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
                  'Koordinat GPS akan membantu tim lapangan menemukan lokasi temuan dengan lebih akurat',
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

// Category configuration class
class CategoryConfig {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> subcategories;
  final bool showKmPoint;
  final bool showLane;
  final bool showSection;
  final String description;

  CategoryConfig({
    required this.name,
    required this.icon,
    required this.color,
    required this.subcategories,
    this.showKmPoint = true,
    this.showLane = true,
    this.showSection = true,
    required this.description,
  });
}