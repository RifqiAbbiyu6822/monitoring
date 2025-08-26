// lib/screens/database_management_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../services/local_storage_service.dart';
import '../utils/theme.dart';
import '../widgets/enhanced_card.dart';

class DatabaseManagementScreen extends StatefulWidget {
  const DatabaseManagementScreen({super.key});

  @override
  State<DatabaseManagementScreen> createState() => _DatabaseManagementScreenState();
}

class _DatabaseManagementScreenState extends State<DatabaseManagementScreen> {
  final LocalStorageService _storageService = LocalStorageService();
  bool _isLoading = false;
  Map<String, dynamic>? _databaseInfo;

  @override
  void initState() {
    super.initState();
    _loadDatabaseInfo();
  }

  Future<void> _loadDatabaseInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final info = await _storageService.getDatabaseInfo();
      setState(() {
        _databaseInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Gagal memuat informasi database');
    }
  }

  Future<void> _exportDatabase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        _showErrorSnackBar('Izin akses penyimpanan diperlukan');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Export data
      final exportData = await _storageService.exportData();
      
      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      // Get Downloads directory
      final directory = await getExternalStorageDirectory();
      final downloadsDir = Directory('${directory?.path}/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      
      // Create filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'monitoring_backup_$timestamp.json';
      final file = File('${downloadsDir.path}/$fileName');
      
      // Write file
      await file.writeAsString(jsonString);
      
      // Update last backup setting
      await _storageService.setSetting(
        'last_backup_date',
        DateTime.now().toIso8601String(),
        description: 'Tanggal backup terakhir',
      );

      setState(() {
        _isLoading = false;
      });

      _showSuccessSnackBar('Backup berhasil disimpan: $fileName');
      _loadDatabaseInfo();
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Gagal membuat backup: $e');
    }
  }

  Future<void> _importDatabase() async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        setState(() {
          _isLoading = true;
        });

        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final backupData = json.decode(jsonString);

        // Validate backup data
        if (!_isValidBackupData(backupData)) {
          throw Exception('Format backup tidak valid');
        }

        // Show confirmation dialog
        final confirm = await _showConfirmationDialog(
          'Import Database',
          'Import akan menghapus semua data yang ada dan menggantinya dengan data dari backup. '
          'Pastikan Anda sudah membuat backup terlebih dahulu.\n\n'
          'Lanjutkan import?',
        );

        if (confirm == true) {
          await _storageService.importData(backupData);
          _showSuccessSnackBar('Database berhasil diimport');
          _loadDatabaseInfo();
        }

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Gagal mengimport database: $e');
    }
  }

  bool _isValidBackupData(dynamic data) {
    if (data is! Map<String, dynamic>) return false;
    if (!data.containsKey('data')) return false;
    if (!data.containsKey('export_date')) return false;
    if (!data.containsKey('version')) return false;
    
    final dataContent = data['data'];
    if (dataContent is! Map<String, dynamic>) return false;
    
    return dataContent.containsKey('temuan') && dataContent.containsKey('perbaikan');
  }

  Future<void> _vacuumDatabase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _storageService.vacuum();
      _showSuccessSnackBar('Database berhasil dioptimalkan');
      _loadDatabaseInfo();
    } catch (e) {
      _showErrorSnackBar('Gagal mengoptimalkan database: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanupOldLogs() async {
    final confirm = await _showConfirmationDialog(
      'Bersihkan Log Lama',
      'Hapus log aktivitas yang lebih dari 90 hari?',
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _storageService.cleanupOldLogs(daysToKeep: 90);
        _showSuccessSnackBar('Log lama berhasil dibersihkan');
        _loadDatabaseInfo();
      } catch (e) {
        _showErrorSnackBar('Gagal membersihkan log: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirm = await _showConfirmationDialog(
      'Hapus Semua Data',
      'PERINGATAN: Ini akan menghapus semua data temuan dan perbaikan secara permanen. '
      'Data pengguna dan pengaturan akan tetap tersimpan.\n\n'
      'Pastikan Anda sudah membuat backup sebelum melanjutkan.\n\n'
      'Lanjutkan penghapusan?',
    );

    if (confirm == true) {
      // Double confirmation
      final doubleConfirm = await _showConfirmationDialog(
        'Konfirmasi Terakhir',
        'Apakah Anda YAKIN ingin menghapus semua data?',
      );

      if (doubleConfirm == true) {
        setState(() {
          _isLoading = true;
        });

        try {
          await _storageService.clearAllData();
          _showSuccessSnackBar('Semua data berhasil dihapus');
          _loadDatabaseInfo();
        } catch (e) {
          _showErrorSnackBar('Gagal menghapus data: $e');
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<bool?> _showConfirmationDialog(String title, String content) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
              ),
              child: const Text('Ya, Lanjutkan'),
            ),
          ],
        );
      },
    );
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
        title: const Text('Manajemen Database'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.surfaceColor,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppTheme.spacing20),
                  Text('Memproses...'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadDatabaseInfo,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTheme.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Database Info Section
                    _buildDatabaseInfoSection(),
                    const SizedBox(height: AppTheme.spacing24),

                    // Backup & Restore Section
                    _buildBackupRestoreSection(),
                    const SizedBox(height: AppTheme.spacing24),

                    // Maintenance Section
                    _buildMaintenanceSection(),
                    const SizedBox(height: AppTheme.spacing24),

                    // Danger Zone
                    _buildDangerZoneSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDatabaseInfoSection() {
    if (_databaseInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final tables = _databaseInfo!['tables'] as Map<String, dynamic>;
    final lastBackup = _databaseInfo!['last_backup'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Database',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        
        EnhancedCard(
          child: Column(
            children: [
              _buildInfoRow('Ukuran Database', '${_databaseInfo!['database_size_mb']} MB'),
              const Divider(),
              _buildInfoRow('Total Temuan', '${tables['temuan_count']}'),
              const Divider(),
              _buildInfoRow('Total Perbaikan', '${tables['perbaikan_count']}'),
              const Divider(),
              _buildInfoRow('Log Aktivitas', '${tables['activity_logs_count']}'),
              const Divider(),
              _buildInfoRow('Versi Database', _databaseInfo!['version']),
              const Divider(),
              _buildInfoRow(
                'Backup Terakhir', 
                lastBackup != null 
                    ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(lastBackup))
                    : 'Belum pernah backup',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupRestoreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Backup & Restore',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        
        EnhancedCard(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radius8),
                  ),
                  child: Icon(
                    Icons.backup,
                    color: AppTheme.successColor,
                  ),
                ),
                title: const Text('Export Database'),
                subtitle: const Text('Simpan semua data ke file backup'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _exportDatabase,
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radius8),
                  ),
                  child: Icon(
                    Icons.restore,
                    color: AppTheme.warningColor,
                  ),
                ),
                title: const Text('Import Database'),
                subtitle: const Text('Pulihkan data dari file backup'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _importDatabase,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Perawatan Database',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        
        EnhancedCard(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radius8),
                  ),
                  child: Icon(
                    Icons.tune,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: const Text('Optimasi Database'),
                subtitle: const Text('Perbaiki dan kompres database'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _vacuumDatabase,
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radius8),
                  ),
                  child: Icon(
                    Icons.cleaning_services,
                    color: AppTheme.infoColor,
                  ),
                ),
                title: const Text('Bersihkan Log Lama'),
                subtitle: const Text('Hapus log aktivitas > 90 hari'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _cleanupOldLogs,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZoneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zona Berbahaya',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.errorColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        
        EnhancedCard(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(AppTheme.radius12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppTheme.spacing8),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radius8),
                ),
                child: Icon(
                  Icons.warning,
                  color: AppTheme.errorColor,
                ),
              ),
              title: Text(
                'Hapus Semua Data',
                style: TextStyle(color: AppTheme.errorColor),
              ),
              subtitle: const Text('Hapus permanen semua temuan dan perbaikan'),
              trailing: Icon(Icons.chevron_right, color: AppTheme.errorColor),
              onTap: _clearAllData,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),
        
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radius12),
            border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.errorColor,
                size: 20,
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Text(
                  'Tindakan di zona ini tidak dapat dibatalkan. '
                  'Pastikan Anda sudah membuat backup sebelum melanjutkan.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}