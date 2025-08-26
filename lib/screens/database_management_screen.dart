// lib/screens/database_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
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
      // Request storage permission for Android
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          _showErrorSnackBar('Izin akses penyimpanan diperlukan');
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Export data
      final exportData = await _storageService.exportData();
      
      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      
      // Create filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'monitoring_backup_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      
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

      _showSuccessSnackBar('Backup berhasil disimpan');
      _loadDatabaseInfo();
      
      // Show share options
      _showShareBackupDialog(file.path, fileName);
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Gagal membuat backup: $e');
    }
  }

  void _showShareBackupDialog(String filePath, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Berhasil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File backup telah disimpan di:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Text(
                filePath,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Anda dapat membagikan file ini atau menyalinnya ke lokasi lain.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _copyPathToClipboard(filePath);
            },
            child: const Text('Salin Path'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _shareBackupFile(filePath, fileName);
            },
            child: const Text('Bagikan'),
          ),
        ],
      ),
    );
  }

  Future<void> _copyPathToClipboard(String path) async {
    await Clipboard.setData(ClipboardData(text: path));
    _showSuccessSnackBar('Path berhasil disalin ke clipboard');
  }

  Future<void> _shareBackupFile(String filePath, String fileName) async {
    try {
      final file = XFile(filePath);
      await Share.shareXFiles(
        [file],
        text: 'Backup database MBZ Monitoring - $fileName',
        subject: 'Database Backup',
      );
    } catch (e) {
      _showErrorSnackBar('Gagal membagikan file: $e');
    }
  }

  Future<void> _importDatabase() async {
    // Show manual import instructions
    _showManualImportDialog();
  }

  void _showManualImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Database'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Untuk mengimport database, silakan:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              const Text('1. Pastikan file backup (.json) tersedia di perangkat'),
              const SizedBox(height: 8),
              const Text('2. Salin file ke folder aplikasi:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Text(
                  '/storage/emulated/0/Android/data/com.example.monitoring/files/',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('3. Tekan "Cari File Backup" di bawah'),
              const SizedBox(height: 16),
              const Text(
                'PERINGATAN: Import akan mengganti semua data yang ada!',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _scanForBackupFiles();
            },
            child: const Text('Cari File Backup'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanForBackupFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync()
          .where((file) => file.path.endsWith('.json') && file.path.contains('monitoring_backup'))
          .cast<File>()
          .toList();

      setState(() {
        _isLoading = false;
      });

      if (files.isEmpty) {
        _showErrorSnackBar('Tidak ditemukan file backup');
        return;
      }

      _showBackupFilesDialog(files);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Gagal mencari file backup: $e');
    }
  }

  void _showBackupFilesDialog(List<File> files) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih File Backup'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              final fileName = file.path.split('/').last;
              final stat = file.statSync();
              final size = (stat.size / 1024).toStringAsFixed(1);
              
              return ListTile(
                leading: const Icon(Icons.backup),
                title: Text(fileName),
                subtitle: Text(
                  'Ukuran: ${size} KB\n'
                  'Dimodifikasi: ${DateFormat('dd/MM/yyyy HH:mm').format(stat.modified)}',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmImport(file);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmImport(File file) async {
    final confirm = await _showConfirmationDialog(
      'Konfirmasi Import',
      'Import akan menghapus semua data yang ada dan menggantinya dengan data dari backup.\n\n'
      'File: ${file.path.split('/').last}\n\n'
      'Lanjutkan import?',
    );

    if (confirm == true) {
      await _performImport(file);
    }
  }

  Future<void> _performImport(File file) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final jsonString = await file.readAsString();
      final backupData = json.decode(jsonString);

      // Validate backup data
      if (!_isValidBackupData(backupData)) {
        throw Exception('Format backup tidak valid');
      }

      await _storageService.importData(backupData);
      _showSuccessSnackBar('Database berhasil diimport');
      _loadDatabaseInfo();
    } catch (e) {
      _showErrorSnackBar('Gagal mengimport database: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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