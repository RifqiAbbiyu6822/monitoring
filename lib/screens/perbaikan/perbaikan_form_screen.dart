// lib/screens/perbaikan/perbaikan_form_screen.dart - Updated with Photo Service
import 'package:flutter/material.dart';

import '../../model/temuan.dart';
import '../../services/local_storage_service.dart';

import '../../widgets/form_components.dart';
import '../../widgets/photo_widgets.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';
import '../../utils/status_validator.dart';

class PerbaikanFormScreen extends StatefulWidget {
  final String? perbaikanId;
  final Temuan? temuan;

  const PerbaikanFormScreen({
    super.key,
    this.perbaikanId,
    this.temuan,
  });

  @override
  State<PerbaikanFormScreen> createState() => _PerbaikanFormScreenState();
}

class _PerbaikanFormScreenState extends State<PerbaikanFormScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _workDescriptionController = TextEditingController();
  final _contractorController = TextEditingController();
  final _assignedToController = TextEditingController();
  final _notesController = TextEditingController();
  final _costController = TextEditingController();

  final LocalStorageService _storageService = LocalStorageService();

  late TabController _photoTabController;
  late TabController _editPhotoTabController;

  String? _selectedTemuanId;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  double _progress = 0.0;
  bool _isLoading = false;
  bool _isEditMode = false;

  List<Temuan> _availableTemuan = [];
  Temuan? _selectedTemuan;

  // Photo lists for different stages
  List<String> _beforePhotos = [];
  List<String> _progressPhotos = [];
  List<String> _afterPhotos = [];
  List<String> _documentationPhotos = [];

  final List<String> _statuses = ['pending', 'ongoing', 'selesai', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _photoTabController = TabController(length: 3, vsync: this);
    _editPhotoTabController = TabController(length: 4, vsync: this);
    _selectedStatus = 'pending';
    _startDate = DateTime.now();
    
    if (widget.perbaikanId != null) {
      _isEditMode = true;
      _loadPerbaikanData();
    } else {
      _loadAvailableTemuan();
      if (widget.temuan != null) {
        _selectedTemuan = widget.temuan;
        _selectedTemuanId = widget.temuan!.id;
        _prefillFromTemuan(widget.temuan!);
      }
    }
  }

  @override
  void dispose() {
    _photoTabController.dispose();
    _editPhotoTabController.dispose();
    _workDescriptionController.dispose();
    _contractorController.dispose();
    _assignedToController.dispose();
    _notesController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _loadPerbaikanData() async {
    if (widget.perbaikanId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final perbaikan = await _storageService.getPerbaikanById(widget.perbaikanId!);
      if (perbaikan != null) {
        _workDescriptionController.text = perbaikan.workDescription;
        _contractorController.text = perbaikan.contractor;
        _assignedToController.text = perbaikan.assignedTo;
        _notesController.text = perbaikan.notes ?? '';
        _costController.text = perbaikan.cost?.toString() ?? '';

        setState(() {
          _selectedTemuanId = perbaikan.temuanId;
          _selectedStatus = perbaikan.status;
          _startDate = perbaikan.startDate;
          _endDate = perbaikan.endDate;
          _progress = perbaikan.progress ?? 0.0;
          _beforePhotos = List.from(perbaikan.beforePhotos);
          _progressPhotos = List.from(perbaikan.progressPhotos);
          _afterPhotos = List.from(perbaikan.afterPhotos);
          _documentationPhotos = List.from(perbaikan.documentationPhotos ?? []);
        });

        // Load the related temuan
        final temuan = await _storageService.getTemuanById(perbaikan.temuanId);
        if (temuan != null) {
          _selectedTemuan = temuan;
        }
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memuat data perbaikan');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAvailableTemuan() async {
    try {
      final temuanList = await _storageService.getAllTemuan();
      final perbaikanList = await _storageService.getAllPerbaikan();
      
      // Filter temuan that don't have perbaikan yet and are not completed
      final temuanWithPerbaikan = perbaikanList.map((p) => p.temuanId).toSet();
      final availableTemuan = temuanList.where((t) => 
        !temuanWithPerbaikan.contains(t.id) && 
        t.status != 'completed'
      ).toList();

      setState(() {
        _availableTemuan = availableTemuan;
      });
    } catch (e) {
      _showErrorSnackBar('Gagal memuat data temuan');
    }
  }

  void _prefillFromTemuan(Temuan temuan) {
    _workDescriptionController.text = 'Perbaikan ${temuan.description}';
    _assignedToController.text = 'Tim Perbaikan ${temuan.section}';
  }

  void _onBeforePhotosChanged(List<String> photos) {
    setState(() {
      _beforePhotos = photos;
    });
  }

  void _onProgressPhotosChanged(List<String> photos) {
    setState(() {
      _progressPhotos = photos;
    });
  }

  void _onAfterPhotosChanged(List<String> photos) {
    setState(() {
      _afterPhotos = photos;
    });
  }

  void _onDocumentationPhotosChanged(List<String> photos) {
    setState(() {
      _documentationPhotos = photos;
    });
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTemuanId == null) {
      _showErrorSnackBar('Pilih temuan terlebih dahulu');
      return;
    }

    // Additional validation
    if (_workDescriptionController.text.trim().isEmpty) {
      _showErrorSnackBar('Deskripsi pekerjaan harus diisi');
      return;
    }
    if (_contractorController.text.trim().isEmpty) {
      _showErrorSnackBar('Kontraktor harus diisi');
      return;
    }
    if (_assignedToController.text.trim().isEmpty) {
      _showErrorSnackBar('Assigned To harus diisi');
      return;
    }
    if (_startDate == null) {
      _showErrorSnackBar('Tanggal mulai harus dipilih');
      return;
    }
    if (_selectedStatus == null) {
      _showErrorSnackBar('Status harus dipilih');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final perbaikanData = {
        'temuanId': _selectedTemuanId!,
        'category': _selectedTemuan?.category ?? 'general',
        'subcategory': _selectedTemuan?.subcategory ?? 'general',
        'section': _selectedTemuan?.section ?? 'A',
        'kmPoint': _selectedTemuan?.kmPoint ?? '0+000',
        'lane': _selectedTemuan?.lane ?? 'Lajur 1',
        'workDescription': _workDescriptionController.text.trim(),
        'contractor': _contractorController.text.trim(),
        'status': _selectedStatus!,
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate?.toIso8601String(),
        'progress': _progress,
        'beforePhotos': _beforePhotos,
        'progressPhotos': _progressPhotos,
        'afterPhotos': _afterPhotos,
        'documentationPhotos': _documentationPhotos,
        'assignedTo': _assignedToController.text.trim(),
        'createdBy': 'Current User', // Replace with actual user
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        'cost': _costController.text.trim().isEmpty ? null : double.tryParse(_costController.text.trim()),
      };

      if (_isEditMode) {
        await _storageService.updatePerbaikan(widget.perbaikanId!, perbaikanData);
        _showSuccessSnackBar('Perbaikan berhasil diperbarui');
      } else {
        await _storageService.addPerbaikan(perbaikanData);
        _showSuccessSnackBar('Perbaikan berhasil ditambahkan');
      }

      Navigator.pop(context, true);
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('UNIQUE constraint failed')) {
        errorMessage = 'ID perbaikan sudah ada dalam database';
      } else if (e.toString().contains('NOT NULL constraint failed')) {
        errorMessage = 'Data wajib tidak boleh kosong';
      } else if (e.toString().contains('foreign key')) {
        errorMessage = 'Temuan yang dipilih tidak valid atau sudah dihapus';
      } else if (e.toString().contains('FOREIGN KEY constraint failed')) {
        errorMessage = 'Temuan terkait tidak ditemukan';
      } else {
        errorMessage = _isEditMode ? 'Gagal memperbarui perbaikan: ${e.toString()}' : 'Gagal menambah perbaikan: ${e.toString()}';
      }
      _showErrorSnackBar(errorMessage);
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
        title: Text(_isEditMode ? 'Edit Perbaikan' : 'Perbaikan Baru'),
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

                    // Temuan Selection (only for new perbaikan)
                    if (!_isEditMode) ...[
                      _buildTemuanSelectionSection(),
                      const SizedBox(height: AppTheme.spacing24),
                    ],

                    // Work Details Section
                    _buildWorkDetailsSection(),
                    const SizedBox(height: AppTheme.spacing24),

                    // Schedule Section
                    _buildScheduleSection(),
                    const SizedBox(height: AppTheme.spacing24),

                    // Progress Section (only for edit mode)
                    if (_isEditMode) ...[
                      _buildProgressSection(),
                      const SizedBox(height: AppTheme.spacing24),
                    ],

                    // Photo Documentation Section
                    _buildPhotoDocumentationSection(),
                    const SizedBox(height: AppTheme.spacing24),

                    // Additional Info Section
                    _buildAdditionalInfoSection(),
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
                              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radius12),
            ),
            child: Icon(
              _isEditMode ? Icons.edit : Icons.build_circle_outlined,
              color: AppTheme.successColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode ? 'Edit Perbaikan' : 'Perbaikan Baru',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  _isEditMode
                      ? 'Perbarui informasi perbaikan dan dokumentasi foto'
                      : 'Isi form untuk membuat perbaikan baru dengan dokumentasi lengkap',
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

  Widget _buildTemuanSelectionSection() {
    return FormSection(
      title: 'Pilih Temuan',
      subtitle: 'Pilih temuan yang akan diperbaiki',
      children: [
        if (_selectedTemuan != null) ...[
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radius12),
              border: Border.all(color: AppTheme.infoColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.infoColor,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Text(
                      'Temuan Terpilih',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.infoColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  _selectedTemuan!.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  'KM ${_selectedTemuan!.kmPoint} • ${_selectedTemuan!.section} • ${_selectedTemuan!.lane}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          if (!_isEditMode)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedTemuan = null;
                  _selectedTemuanId = null;
                });
              },
              icon: const Icon(Icons.change_circle),
              label: const Text('Pilih Temuan Lain'),
            ),
        ] else ...[
          if (_availableTemuan.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing20),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radius12),
                border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.warning_outlined,
                    color: AppTheme.warningColor,
                    size: 32,
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  Text(
                    'Tidak ada temuan tersedia',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    'Semua temuan sudah memiliki perbaikan atau belum ada temuan yang dibuat',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(AppTheme.radius12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih dari ${_availableTemuan.length} temuan tersedia:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: _availableTemuan.length,
                      itemBuilder: (context, index) {
                        final temuan = _availableTemuan[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacing4,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(AppTheme.spacing6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radius6),
                            ),
                            child: Icon(
                              Icons.search,
                              color: AppTheme.primaryColor,
                              size: 16,
                            ),
                          ),
                          title: Text(
                            temuan.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'KM ${temuan.kmPoint} • ${temuan.section}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedTemuan = temuan;
                              _selectedTemuanId = temuan.id;
                            });
                            _prefillFromTemuan(temuan);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildWorkDetailsSection() {
    return FormSection(
      title: 'Detail Pekerjaan',
      subtitle: 'Informasi pekerjaan perbaikan',
      children: [
        EnhancedTextField(
          label: 'Deskripsi Pekerjaan',
          hint: 'Jelaskan pekerjaan yang akan dilakukan',
          controller: _workDescriptionController,
          maxLines: 3,
          prefixIcon: const Icon(Icons.description),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Deskripsi pekerjaan harus diisi';
            }
            if (value.length < 10) {
              return 'Deskripsi minimal 10 karakter';
            }
            return null;
          },
        ),
        EnhancedTextField(
          label: 'Kontraktor',
          hint: 'Nama perusahaan kontraktor',
          controller: _contractorController,
          prefixIcon: const Icon(Icons.business),
          validator: (value) => Validators.validateRequired(value, 'Kontraktor'),
        ),
        EnhancedTextField(
          label: 'Assigned To',
          hint: 'Tim yang bertanggung jawab',
          controller: _assignedToController,
          prefixIcon: const Icon(Icons.group),
          validator: (value) => Validators.validateRequired(value, 'Assigned To'),
        ),
        EnhancedDropdownField<String>(
          label: 'Status',
          hint: 'Pilih status perbaikan',
          value: _selectedStatus,
          items: _statuses,
          itemText: (status) => _getStatusText(status),
          onChanged: (value) {
            setState(() {
              final oldStatus = _selectedStatus;
              _selectedStatus = value;
              
              // Auto-adjust progress based on status
              if (value == 'pending') {
                _progress = 0.0;
              } else if (value == 'selesai') {
                _progress = 100.0;
              } else if (value == 'ongoing' && _progress == 0.0) {
                _progress = 10.0; // Start with 10% for ongoing
              }
              
              // Validate status transition if in edit mode
              if (_isEditMode && oldStatus != null) {
                final validationError = StatusValidator.validatePerbaikanStatusChange(
                  oldStatus,
                  value!,
                  _selectedTemuan?.status ?? 'pending',
                  progress: _progress,
                );
                
                if (validationError != null) {
                  // Revert to old status and show error
                  _selectedStatus = oldStatus;
                  _showErrorSnackBar(validationError);
                }
              }
            });
          },
          prefixIcon: const Icon(Icons.info),
          validator: (value) {
            if (value == null) return 'Status harus dipilih';
            
            // Additional validation for status requirements
            final requirements = StatusValidator.getStatusRequirements(value);
            
            if (requirements['requiresProgress'] == 100.0 && _progress < 100) {
              return 'Progress harus 100% untuk status selesai';
            }
            
            if (requirements['requiresEndDate'] == true && _endDate == null) {
              return 'Tanggal selesai diperlukan untuk status selesai';
            }
            
            if (requirements['requiresPhotos'] == true && 
                _beforePhotos.isEmpty && _afterPhotos.isEmpty) {
              return 'Foto dokumentasi diperlukan untuk status selesai';
            }
            
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return FormSection(
      title: 'Jadwal Pekerjaan',
      subtitle: 'Waktu pelaksanaan perbaikan',
      children: [
        Row(
          children: [
            Expanded(
              child: EnhancedDateField(
                label: 'Tanggal Mulai',
                selectedDate: _startDate,
                onDateSelected: (date) => setState(() => _startDate = date),
                validator: (date) {
                  if (date == null) return 'Tanggal mulai harus dipilih';
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final selectedDate = DateTime(date.year, date.month, date.day);
                  
                  if (selectedDate.isBefore(today.subtract(const Duration(days: 30)))) {
                    return 'Tanggal mulai tidak boleh lebih dari 30 hari yang lalu';
                  }
                  if (selectedDate.isAfter(today.add(const Duration(days: 365)))) {
                    return 'Tanggal mulai tidak boleh lebih dari 1 tahun ke depan';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: EnhancedDateField(
                label: 'Tanggal Selesai',
                selectedDate: _endDate,
                onDateSelected: (date) => setState(() => _endDate = date),
                firstDate: _startDate,
                validator: (date) {
                  if (date != null && _startDate != null) {
                    if (date.isBefore(_startDate!)) {
                      return 'Tanggal selesai tidak boleh sebelum tanggal mulai';
                    }
                    final maxDuration = _startDate!.add(const Duration(days: 365 * 2)); // Max 2 tahun
                    if (date.isAfter(maxDuration)) {
                      return 'Durasi perbaikan tidak boleh lebih dari 2 tahun';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        if (_startDate != null && _endDate != null) ...[
          const SizedBox(height: AppTheme.spacing12),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radius8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppTheme.infoColor,
                  size: 16,
                ),
                const SizedBox(width: AppTheme.spacing8),
                Text(
                  'Durasi: ${_endDate!.difference(_startDate!).inDays} hari',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.infoColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressSection() {
    return FormSection(
      title: 'Progress Pekerjaan',
      subtitle: 'Status kemajuan perbaikan',
      children: [
        EnhancedSliderField(
          label: 'Progress',
          value: _progress,
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: (value) {
            setState(() {
              _progress = value;
              
              // Auto-suggest status based on progress
              final suggestedStatus = StatusValidator.suggestNextStatus(_selectedStatus ?? 'pending', progress: value);
              if (suggestedStatus != null && suggestedStatus != _selectedStatus) {
                // Show suggestion to user
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Saran: Ubah status ke ${_getStatusText(suggestedStatus)} berdasarkan progress'),
                        action: SnackBarAction(
                          label: 'Ubah',
                          onPressed: () {
                            setState(() => _selectedStatus = suggestedStatus);
                          },
                        ),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                });
              }
              
              // Auto-set end date if progress is 100%
              if (value >= 100 && _endDate == null) {
                _endDate = DateTime.now();
              }
            });
          },
          labelBuilder: (value) => _getProgressLabel(value),
          helperText: 'Geser untuk mengatur progress pekerjaan. Status akan disarankan secara otomatis.',
        ),
      ],
    );
  }

  Widget _buildPhotoDocumentationSection() {
    return FormSection(
      title: 'Dokumentasi Foto',
      subtitle: _isEditMode 
          ? 'Upload foto untuk dokumentasi tahapan perbaikan dan update'
          : 'Upload foto untuk dokumentasi tahapan perbaikan',
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radius12),
            border: Border.all(color: AppTheme.borderColor),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Column(
            children: [
              // Tab bar for photo categories
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radius12),
                  ),
                ),
                child: TabBar(
                  controller: _isEditMode ? _editPhotoTabController : _photoTabController,
                  tabs: _isEditMode ? [
                    Tab(
                      text: 'Sebelum',
                      icon: const Icon(Icons.camera_alt, size: 16),
                    ),
                    Tab(
                      text: 'Progress',
                      icon: const Icon(Icons.build, size: 16),
                    ),
                    Tab(
                      text: 'Setelah',
                      icon: const Icon(Icons.done, size: 16),
                    ),
                    Tab(
                      text: 'Dokumentasi',
                      icon: const Icon(Icons.photo_library, size: 16),
                    ),
                  ] : [
                    Tab(
                      text: 'Sebelum',
                      icon: const Icon(Icons.camera_alt, size: 16),
                    ),
                    Tab(
                      text: 'Progress',
                      icon: const Icon(Icons.build, size: 16),
                    ),
                    Tab(
                      text: 'Setelah',
                      icon: const Icon(Icons.done, size: 16),
                    ),
                  ],
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicatorColor: AppTheme.primaryColor,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              // Tab content
              SizedBox(
                height: 300,
                child: TabBarView(
                  controller: _isEditMode ? _editPhotoTabController : _photoTabController,
                  children: _isEditMode ? [
                    // Before photos (edit mode)
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      child: PhotoPickerWidget(
                        initialPhotos: _beforePhotos,
                        onPhotosChanged: _onBeforePhotosChanged,
                        maxPhotos: 1,
                        title: 'Foto Kondisi Sebelum',
                        subtitle: 'Dokumentasi kondisi sebelum perbaikan (${_beforePhotos.length}/1)',
                      ),
                    ),
                    
                    // Progress photos (edit mode)
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      child: PhotoPickerWidget(
                        initialPhotos: _progressPhotos,
                        onPhotosChanged: _onProgressPhotosChanged,
                        maxPhotos: 5,
                        title: 'Foto Progress',
                        subtitle: 'Dokumentasi proses perbaikan (${_progressPhotos.length}/5)',
                      ),
                    ),
                    
                    // After photos (edit mode)
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      child: PhotoPickerWidget(
                        initialPhotos: _afterPhotos,
                        onPhotosChanged: _onAfterPhotosChanged,
                        maxPhotos: 5,
                        title: 'Foto Hasil Akhir',
                        subtitle: 'Dokumentasi kondisi setelah perbaikan (${_afterPhotos.length}/5)',
                      ),
                    ),
                    
                    // Documentation photos (edit mode only)
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      child: PhotoPickerWidget(
                        initialPhotos: _documentationPhotos,
                        onPhotosChanged: _onDocumentationPhotosChanged,
                        maxPhotos: 10,
                        title: 'Foto Dokumentasi',
                        subtitle: 'Foto tambahan untuk dokumentasi update (${_documentationPhotos.length}/10)',
                      ),
                    ),
                  ] : [
                    // Before photos (create mode)
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      child: PhotoPickerWidget(
                        initialPhotos: _beforePhotos,
                        onPhotosChanged: _onBeforePhotosChanged,
                        maxPhotos: 1,
                        title: 'Foto Kondisi Sebelum',
                        subtitle: 'Dokumentasi kondisi sebelum perbaikan (${_beforePhotos.length}/1)',
                      ),
                    ),
                    
                    // Progress photos (create mode)
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      child: PhotoPickerWidget(
                        initialPhotos: _progressPhotos,
                        onPhotosChanged: _onProgressPhotosChanged,
                        maxPhotos: 5,
                        title: 'Foto Progress',
                        subtitle: 'Dokumentasi proses perbaikan (${_progressPhotos.length}/5)',
                      ),
                    ),
                    
                    // After photos (create mode)
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      child: PhotoPickerWidget(
                        initialPhotos: _afterPhotos,
                        onPhotosChanged: _onAfterPhotosChanged,
                        maxPhotos: 5,
                        title: 'Foto Hasil Akhir',
                        subtitle: 'Dokumentasi kondisi setelah perbaikan (${_afterPhotos.length}/5)',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Photo summary with validation
        const SizedBox(height: AppTheme.spacing12),
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing12),
          decoration: BoxDecoration(
            color: _getPhotoValidationColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radius8),
            border: Border.all(color: _getPhotoValidationColor().withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getPhotoValidationIcon(),
                    color: _getPhotoValidationColor(),
                    size: 16,
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Expanded(
                    child: Text(
                      'Total: ${_beforePhotos.length + _progressPhotos.length + _afterPhotos.length + _documentationPhotos.length} foto dokumentasi',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getPhotoValidationColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (_getPhotoValidationMessage().isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  _getPhotoValidationMessage(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getPhotoValidationColor(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return FormSection(
      title: 'Informasi Tambahan',
      subtitle: 'Catatan dan biaya perbaikan',
      children: [
        EnhancedTextField(
          label: 'Biaya (Rp)',
          hint: 'Contoh: 5000000',
          controller: _costController,
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.attach_money),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final cost = double.tryParse(value);
              if (cost == null) return 'Format biaya tidak valid';
              if (cost < 0) return 'Biaya tidak boleh negatif';
            }
            return null;
          },
        ),
        EnhancedTextField(
          label: 'Catatan',
          hint: 'Catatan tambahan (opsional)',
          controller: _notesController,
          maxLines: 3,
          prefixIcon: const Icon(Icons.note),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      children: [
        // Summary before submit
        if (_selectedTemuan != null) ...[
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppTheme.radius12),
              border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ringkasan Perbaikan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing12),
                Row(
                  children: [
                    Icon(
                      Icons.build,
                      color: AppTheme.successColor,
                      size: 16,
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Expanded(
                      child: Text(
                        _workDescriptionController.text.isEmpty 
                            ? 'Deskripsi pekerjaan...'
                            : _workDescriptionController.text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing8),
                Row(
                  children: [
                    Icon(
                      Icons.business,
                      color: AppTheme.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Text(
                      'Kontraktor: ${_contractorController.text.isEmpty ? "Belum dipilih" : _contractorController.text}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing8),
                Row(
                  children: [
                    Icon(
                      Icons.photo_library,
                      color: AppTheme.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Text(
                      'Dokumentasi: ${_beforePhotos.length + _progressPhotos.length + _afterPhotos.length + _documentationPhotos.length} foto',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (_isEditMode && _progress > 0) ...[
                  const SizedBox(height: AppTheme.spacing8),
                  Row(
                    children: [
                      Icon(
                        Icons.timeline,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Text(
                        'Progress: ${_progress.toInt()}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
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
                        _isEditMode ? Icons.save : Icons.build,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Text(
                        _isEditMode ? 'Perbarui Perbaikan' : 'Simpan Perbaikan',
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

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'ongoing':
        return 'Sedang Berlangsung';
      case 'selesai':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String _getProgressLabel(double value) {
    if (value == 0) return 'Belum dimulai';
    if (value < 25) return 'Baru dimulai';
    if (value < 50) return 'Dalam progress';
    if (value < 75) return 'Setengah jalan';
    if (value < 100) return 'Hampir selesai';
    return 'Selesai';
  }

  /// Get photo validation color based on current state
  Color _getPhotoValidationColor() {
    if (_selectedStatus == 'selesai') {
      // For completed status, require before and after photos
      if (_beforePhotos.isEmpty || _afterPhotos.isEmpty) {
        return AppTheme.errorColor;
      }
      return AppTheme.successColor;
    } else if (_selectedStatus == 'ongoing') {
      // For ongoing status, encourage progress photos
      if (_progressPhotos.isEmpty && _progress > 10) {
        return AppTheme.warningColor;
      }
      return AppTheme.infoColor;
    }
    return AppTheme.infoColor;
  }

  /// Get photo validation icon
  IconData _getPhotoValidationIcon() {
    if (_selectedStatus == 'selesai') {
      if (_beforePhotos.isEmpty || _afterPhotos.isEmpty) {
        return Icons.error_outline;
      }
      return Icons.check_circle_outline;
    } else if (_selectedStatus == 'ongoing') {
      if (_progressPhotos.isEmpty && _progress > 10) {
        return Icons.warning_outlined;
      }
      return Icons.info_outline;
    }
    return Icons.info_outline;
  }

  /// Get photo validation message
  String _getPhotoValidationMessage() {
    if (_selectedStatus == 'selesai') {
      final missing = <String>[];
      if (_beforePhotos.isEmpty) missing.add('foto sebelum');
      if (_afterPhotos.isEmpty) missing.add('foto sesudah');
      
      if (missing.isNotEmpty) {
        return 'Diperlukan: ${missing.join(' dan ')} untuk status selesai';
      }
      return 'Dokumentasi foto lengkap ✓';
    } else if (_selectedStatus == 'ongoing') {
      if (_progressPhotos.isEmpty && _progress > 10) {
        return 'Disarankan: tambahkan foto progress untuk dokumentasi yang lebih baik';
      }
      return 'Tambahkan foto sesuai tahapan pekerjaan';
    }
    return 'Dokumentasi foto akan membantu tracking progress perbaikan';
  }
}