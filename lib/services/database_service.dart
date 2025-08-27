// lib/services/database_service.dart - Fixed Implementation
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../model/temuan.dart';
import '../model/perbaikan.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'monitoring_mbz.db');
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDatabase,
        onOpen: (db) async {
          // Verify database integrity
          try {
            await db.execute('PRAGMA integrity_check');
            print('Database integrity check passed');
          } catch (e) {
            print('Database integrity check failed: $e');
          }
        },
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    try {
      // Table untuk Temuan
      await db.execute('''
        CREATE TABLE temuan (
          id TEXT PRIMARY KEY,
          category TEXT NOT NULL,
          subcategory TEXT NOT NULL,
          section TEXT NOT NULL,
          km_point TEXT NOT NULL,
          lane TEXT NOT NULL,
          description TEXT NOT NULL,
          priority TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending',
          latitude REAL DEFAULT 0.0,
          longitude REAL DEFAULT 0.0,
          photos TEXT, -- JSON array string
          created_at TEXT NOT NULL,
          created_by TEXT NOT NULL,
          updated_at TEXT,
          updated_by TEXT,
          notes TEXT
        )
      ''');

      // Table untuk Perbaikan
      await db.execute('''
        CREATE TABLE perbaikan (
          id TEXT PRIMARY KEY,
          temuan_id TEXT NOT NULL,
          category TEXT NOT NULL,
          subcategory TEXT NOT NULL,
          section TEXT NOT NULL,
          km_point TEXT NOT NULL,
          lane TEXT NOT NULL,
          work_description TEXT NOT NULL,
          contractor TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending',
          start_date TEXT NOT NULL,
          end_date TEXT,
          progress REAL DEFAULT 0.0,
          before_photos TEXT, -- JSON array string
          progress_photos TEXT, -- JSON array string
          after_photos TEXT, -- JSON array string
          documentation_photos TEXT, -- JSON array string for updates
          assigned_to TEXT NOT NULL,
          created_at TEXT NOT NULL,
          created_by TEXT NOT NULL,
          notes TEXT,
          cost REAL,
          FOREIGN KEY (temuan_id) REFERENCES temuan (id) ON DELETE CASCADE
        )
      ''');

      // Table untuk Settings
      await db.execute('''
        CREATE TABLE settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          description TEXT,
          updated_at TEXT NOT NULL
        )
      ''');

      // Table untuk Activity Logs
      await db.execute('''
        CREATE TABLE activity_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT,
          action TEXT NOT NULL,
          entity_type TEXT NOT NULL,
          entity_id TEXT,
          details TEXT,
          timestamp TEXT NOT NULL
        )
      ''');

      // Indexes untuk optimasi query
      await db.execute('CREATE INDEX idx_temuan_status ON temuan (status)');
      await db.execute('CREATE INDEX idx_temuan_priority ON temuan (priority)');
      await db.execute('CREATE INDEX idx_temuan_created_at ON temuan (created_at)');
      await db.execute('CREATE INDEX idx_perbaikan_status ON perbaikan (status)');
      await db.execute('CREATE INDEX idx_perbaikan_temuan_id ON perbaikan (temuan_id)');
      await db.execute('CREATE INDEX idx_activity_logs_timestamp ON activity_logs (timestamp)');
      await db.execute('CREATE INDEX idx_activity_logs_user_id ON activity_logs (user_id)');

      // Insert default settings
      await _insertDefaultSettings(db);
    } catch (e) {
      print('Error creating database: $e');
      rethrow;
    }
  }

  Future<void> _insertDefaultSettings(Database db) async {
    final defaultSettings = [
      {'key': 'app_version', 'value': '1.0.0', 'description': 'Versi aplikasi'},
      {'key': 'default_section', 'value': 'A', 'description': 'Seksi default'},
      {'key': 'auto_backup', 'value': 'true', 'description': 'Auto backup data'},
      {'key': 'backup_interval', 'value': '7', 'description': 'Interval backup (hari)'},
    ];

    for (final setting in defaultSettings) {
      await db.insert('settings', {
        ...setting,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // ==================== ID GENERATION ====================

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // ==================== TEMUAN OPERATIONS ====================

  Future<List<Temuan>> getAllTemuan() async {
    final db = await database;
    print('Querying temuan table...');
    
    final List<Map<String, dynamic>> maps = await db.query(
      'temuan',
      orderBy: 'created_at DESC',
    );

    print('Found ${maps.length} temuan records');
    
    final temuanList = List.generate(maps.length, (i) {
      return _mapToTemuan(maps[i]);
    });
    
    print('Converted ${temuanList.length} temuan objects');
    return temuanList;
  }

  Future<Temuan?> getTemuanById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'temuan',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToTemuan(maps.first);
    }
    return null;
  }

  Future<Temuan> addTemuan(Map<String, dynamic> temuanData) async {
    final db = await database;
    
    return await db.transaction((txn) async {
      try {
        final String id = _generateId();

        // Validate required fields
        if (temuanData['category'] == null || temuanData['category'].toString().isEmpty) {
          throw ArgumentError('Kategori tidak boleh kosong');
        }
        if (temuanData['description'] == null || temuanData['description'].toString().isEmpty) {
          throw ArgumentError('Deskripsi tidak boleh kosong');
        }
        if (temuanData['priority'] == null || temuanData['priority'].toString().isEmpty) {
          throw ArgumentError('Prioritas tidak boleh kosong');
        }

        final temuan = Temuan(
          id: id,
          category: temuanData['category'],
          subcategory: temuanData['subcategory'],
          section: temuanData['section'],
          kmPoint: temuanData['kmPoint'],
          lane: temuanData['lane'],
          description: temuanData['description'],
          priority: temuanData['priority'],
          status: 'pending',
          latitude: temuanData['latitude'] ?? 0.0,
          longitude: temuanData['longitude'] ?? 0.0,
          photos: List<String>.from(temuanData['photos'] ?? []),
          createdAt: DateTime.now(),
          createdBy: temuanData['createdBy'] ?? 'Unknown User',
          notes: temuanData['notes'],
        );

        await txn.insert('temuan', _temuanToMap(temuan));
        
        // Add activity log
        await txn.insert('activity_logs', {
          'user_id': temuan.createdBy,
          'action': 'created',
          'entity_type': 'temuan',
          'entity_id': temuan.id,
          'details': 'Temuan baru: ${temuan.category} - ${temuan.description}',
          'timestamp': DateTime.now().toIso8601String(),
        });
        
        return temuan;
      } catch (e) {
        print('Error adding temuan: $e');
        rethrow;
      }
    });
  }

  Future<Temuan> updateTemuan(String id, Map<String, dynamic> updateData) async {
    final db = await database;
    
    return await db.transaction((txn) async {
      try {
        // Get existing temuan
        final existingMaps = await txn.query(
          'temuan',
          where: 'id = ?',
          whereArgs: [id],
        );
        
        if (existingMaps.isEmpty) {
          throw Exception('Temuan dengan ID $id tidak ditemukan');
        }
        
        final existingTemuan = _mapToTemuan(existingMaps.first);

        // Validate update data
        if (updateData['description'] != null && updateData['description'].toString().isEmpty) {
          throw ArgumentError('Deskripsi tidak boleh kosong');
        }

        final updatedTemuan = Temuan(
          id: existingTemuan.id,
          category: updateData['category'] ?? existingTemuan.category,
          subcategory: updateData['subcategory'] ?? existingTemuan.subcategory,
          section: updateData['section'] ?? existingTemuan.section,
          kmPoint: updateData['kmPoint'] ?? existingTemuan.kmPoint,
          lane: updateData['lane'] ?? existingTemuan.lane,
          description: updateData['description'] ?? existingTemuan.description,
          priority: updateData['priority'] ?? existingTemuan.priority,
          status: updateData['status'] ?? existingTemuan.status,
          latitude: updateData['latitude'] ?? existingTemuan.latitude,
          longitude: updateData['longitude'] ?? existingTemuan.longitude,
          photos: updateData['photos'] != null 
              ? List<String>.from(updateData['photos']) 
              : existingTemuan.photos,
          createdAt: existingTemuan.createdAt,
          createdBy: existingTemuan.createdBy,
          updatedAt: DateTime.now(),
          updatedBy: updateData['updatedBy'] ?? 'Unknown User',
          notes: updateData['notes'] ?? existingTemuan.notes,
        );

        final affectedRows = await txn.update(
          'temuan',
          _temuanToMap(updatedTemuan),
          where: 'id = ?',
          whereArgs: [id],
        );

        if (affectedRows == 0) {
          throw Exception('Gagal memperbarui temuan');
        }

        // Add activity log
        await txn.insert('activity_logs', {
          'user_id': updatedTemuan.updatedBy,
          'action': 'updated',
          'entity_type': 'temuan',
          'entity_id': updatedTemuan.id,
          'details': 'Temuan diperbarui: ${updatedTemuan.description}',
          'timestamp': DateTime.now().toIso8601String(),
        });

        return updatedTemuan;
      } catch (e) {
        print('Error updating temuan: $e');
        rethrow;
      }
    });
  }

  Future<void> deleteTemuan(String id) async {
    final db = await database;
    
    return await db.transaction((txn) async {
      try {
        // Get temuan details before deletion for logging
        final temuanMaps = await txn.query(
          'temuan',
          where: 'id = ?',
          whereArgs: [id],
        );
        
        if (temuanMaps.isEmpty) {
          throw Exception('Temuan dengan ID $id tidak ditemukan');
        }
        
        final temuan = _mapToTemuan(temuanMaps.first);
        
        // Check if temuan has related perbaikan
        final relatedPerbaikan = await txn.query(
          'perbaikan',
          where: 'temuan_id = ?',
          whereArgs: [id],
        );
        
        if (relatedPerbaikan.isNotEmpty) {
          throw Exception('Tidak dapat menghapus temuan yang memiliki ${relatedPerbaikan.length} perbaikan terkait. Hapus perbaikan terlebih dahulu.');
        }
        
        final affectedRows = await txn.delete(
          'temuan',
          where: 'id = ?',
          whereArgs: [id],
        );
        
        if (affectedRows == 0) {
          throw Exception('Gagal menghapus temuan');
        }
        
        // Add activity log
        await txn.insert('activity_logs', {
          'user_id': 'system',
          'action': 'deleted',
          'entity_type': 'temuan',
          'entity_id': id,
          'details': 'Temuan dihapus: ${temuan.description}',
          'timestamp': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        print('Error deleting temuan: $e');
        rethrow;
      }
    });
  }

  // ==================== PERBAIKAN OPERATIONS ====================

  Future<List<Perbaikan>> getAllPerbaikan() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'perbaikan',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return _mapToPerbaikan(maps[i]);
    });
  }

  Future<Perbaikan?> getPerbaikanById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'perbaikan',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToPerbaikan(maps.first);
    }
    return null;
  }

  Future<Perbaikan> addPerbaikan(Map<String, dynamic> perbaikanData) async {
    final db = await database;
    
    return await db.transaction((txn) async {
      final String id = _generateId();

      final perbaikan = Perbaikan(
        id: id,
        temuanId: perbaikanData['temuanId'],
        category: perbaikanData['category'],
        subcategory: perbaikanData['subcategory'],
        section: perbaikanData['section'],
        kmPoint: perbaikanData['kmPoint'],
        lane: perbaikanData['lane'],
        workDescription: perbaikanData['workDescription'],
        contractor: perbaikanData['contractor'],
        status: perbaikanData['status'] ?? 'pending',
        startDate: perbaikanData['startDate'] != null 
            ? DateTime.parse(perbaikanData['startDate']) 
            : DateTime.now(),
        endDate: perbaikanData['endDate'] != null 
            ? DateTime.parse(perbaikanData['endDate']) 
            : null,
        progress: perbaikanData['progress']?.toDouble() ?? 0.0,
        beforePhotos: List<String>.from(perbaikanData['beforePhotos'] ?? []),
        progressPhotos: List<String>.from(perbaikanData['progressPhotos'] ?? []),
        afterPhotos: List<String>.from(perbaikanData['afterPhotos'] ?? []),
        documentationPhotos: perbaikanData['documentationPhotos'] != null
            ? List<String>.from(perbaikanData['documentationPhotos'])
            : null,
        assignedTo: perbaikanData['assignedTo'],
        createdAt: DateTime.now(),
        createdBy: perbaikanData['createdBy'] ?? 'Unknown User',
        notes: perbaikanData['notes'],
        cost: perbaikanData['cost']?.toDouble(),
      );

      await txn.insert('perbaikan', _perbaikanToMap(perbaikan));
      
      // Update temuan status to in_progress
      await txn.update(
        'temuan',
        {
          'status': 'in_progress',
          'updated_at': DateTime.now().toIso8601String(),
          'updated_by': perbaikan.createdBy,
        },
        where: 'id = ?',
        whereArgs: [perbaikan.temuanId],
      );

      // Add activity log
      await addActivityLog(
        action: 'created',
        entityType: 'perbaikan',
        entityId: perbaikan.id,
        userId: perbaikan.createdBy,
        details: 'Perbaikan baru: ${perbaikan.workDescription}',
      );

      return perbaikan;
    });
  }

  Future<Perbaikan> updatePerbaikan(String id, Map<String, dynamic> updateData) async {
    final db = await database;
    
    // Get existing perbaikan
    final existingPerbaikan = await getPerbaikanById(id);
    if (existingPerbaikan == null) {
      throw Exception('Perbaikan not found');
    }

    final updatedPerbaikan = Perbaikan(
      id: existingPerbaikan.id,
      temuanId: existingPerbaikan.temuanId,
      category: existingPerbaikan.category,
      subcategory: existingPerbaikan.subcategory,
      section: existingPerbaikan.section,
      kmPoint: existingPerbaikan.kmPoint,
      lane: existingPerbaikan.lane,
      workDescription: updateData['workDescription'] ?? existingPerbaikan.workDescription,
      contractor: updateData['contractor'] ?? existingPerbaikan.contractor,
      status: updateData['status'] ?? existingPerbaikan.status,
      startDate: updateData['startDate'] != null 
          ? DateTime.parse(updateData['startDate']) 
          : existingPerbaikan.startDate,
      endDate: updateData['endDate'] != null 
          ? DateTime.parse(updateData['endDate']) 
          : existingPerbaikan.endDate,
      progress: updateData['progress']?.toDouble() ?? existingPerbaikan.progress,
      beforePhotos: updateData['beforePhotos'] != null 
          ? List<String>.from(updateData['beforePhotos']) 
          : existingPerbaikan.beforePhotos,
      progressPhotos: updateData['progressPhotos'] != null 
          ? List<String>.from(updateData['progressPhotos']) 
          : existingPerbaikan.progressPhotos,
      afterPhotos: updateData['afterPhotos'] != null 
          ? List<String>.from(updateData['afterPhotos']) 
          : existingPerbaikan.afterPhotos,
      documentationPhotos: updateData['documentationPhotos'] != null
          ? List<String>.from(updateData['documentationPhotos'])
          : existingPerbaikan.documentationPhotos,
      assignedTo: updateData['assignedTo'] ?? existingPerbaikan.assignedTo,
      createdAt: existingPerbaikan.createdAt,
      createdBy: existingPerbaikan.createdBy,
      notes: updateData['notes'] ?? existingPerbaikan.notes,
      cost: updateData['cost']?.toDouble() ?? existingPerbaikan.cost,
    );

    await db.update(
      'perbaikan',
      _perbaikanToMap(updatedPerbaikan),
      where: 'id = ?',
      whereArgs: [id],
    );

    // Update temuan status based on perbaikan status
    String newTemuanStatus = 'pending';
    if (updatedPerbaikan.status == 'ongoing') {
      newTemuanStatus = 'in_progress';
    } else if (updatedPerbaikan.status == 'selesai') {
      newTemuanStatus = 'completed';
    } else if (updatedPerbaikan.status == 'cancelled') {
      newTemuanStatus = 'pending'; // Reset to pending if cancelled
    }
    
    // Only update if status actually changed
    if (existingPerbaikan.status != updatedPerbaikan.status) {
      await db.update(
        'temuan',
        {
          'status': newTemuanStatus,
          'updated_at': DateTime.now().toIso8601String(),
          'updated_by': 'system',
        },
        where: 'id = ?',
        whereArgs: [updatedPerbaikan.temuanId],
      );
    }

    return updatedPerbaikan;
  }

  Future<void> deletePerbaikan(String id) async {
    final db = await database;
    
    await db.transaction((txn) async {
      // Get perbaikan for temuan update
      final perbaikan = await getPerbaikanById(id);
      if (perbaikan == null) {
        throw Exception('Perbaikan tidak ditemukan');
      }
      
      await txn.delete(
        'perbaikan',
        where: 'id = ?',
        whereArgs: [id],
      );

      // Reset temuan status to pending
      await txn.update(
        'temuan',
        {
          'status': 'pending',
          'updated_at': DateTime.now().toIso8601String(),
          'updated_by': 'system',
        },
        where: 'id = ?',
        whereArgs: [perbaikan.temuanId],
      );

      // Add activity log
      await addActivityLog(
        action: 'deleted',
        entityType: 'perbaikan',
        entityId: id,
        userId: 'system',
        details: 'Perbaikan dihapus: ${perbaikan.workDescription}',
      );
    });
  }

  // ==================== STATISTICS ====================

  Future<Map<String, int>> getSummaryStatistics() async {
    final db = await database;

    try {
      final temuanCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM temuan')
      ) ?? 0;

      final temuanPending = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM temuan WHERE status = 'pending'")
      ) ?? 0;

      final temuanInProgress = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM temuan WHERE status = 'in_progress'")
      ) ?? 0;

      final temuanCompleted = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM temuan WHERE status = 'completed'")
      ) ?? 0;

      final perbaikanCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM perbaikan')
      ) ?? 0;

      final perbaikanPending = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM perbaikan WHERE status = 'pending'")
      ) ?? 0;

      final perbaikanOngoing = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM perbaikan WHERE status = 'ongoing'")
      ) ?? 0;

      final perbaikanCompleted = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM perbaikan WHERE status = 'selesai'")
      ) ?? 0;

      return {
        'totalTemuan': temuanCount,
        'temuanPending': temuanPending,
        'temuanInProgress': temuanInProgress,
        'temuanCompleted': temuanCompleted,
        'totalPerbaikan': perbaikanCount,
        'perbaikanPending': perbaikanPending,
        'perbaikanOngoing': perbaikanOngoing,
        'perbaikanCompleted': perbaikanCompleted,
      };
    } catch (e) {
      print('Error getting summary statistics: $e');
      return {
        'totalTemuan': 0,
        'temuanPending': 0,
        'temuanInProgress': 0,
        'temuanCompleted': 0,
        'totalPerbaikan': 0,
        'perbaikanPending': 0,
        'perbaikanOngoing': 0,
        'perbaikanCompleted': 0,
      };
    }
  }

  Future<Map<String, int>> getCategoryStatistics() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT category, COUNT(*) as count 
      FROM temuan 
      GROUP BY category
    ''');

    Map<String, int> categoryStats = {};
    for (final result in results) {
      categoryStats[result['category']] = result['count'];
    }
    
    return categoryStats;
  }

  Future<Map<String, int>> getPriorityStatistics() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT priority, COUNT(*) as count 
      FROM temuan 
      GROUP BY priority
    ''');

    Map<String, int> priorityStats = {};
    for (final result in results) {
      priorityStats[result['priority']] = result['count'];
    }
    
    return priorityStats;
  }

  // ==================== BACKUP & RESTORE ====================

  Future<Map<String, dynamic>> exportData() async {
    final db = await database;
    
    final temuan = await db.query('temuan');
    final perbaikan = await db.query('perbaikan');
    final settings = await db.query('settings');

    return {
      'export_date': DateTime.now().toIso8601String(),
      'version': '1.0',
      'data': {
        'temuan': temuan,
        'perbaikan': perbaikan,
        'settings': settings,
      },
    };
  }

  Future<void> importData(Map<String, dynamic> backupData) async {
    final db = await database;
    
    // Validate backup data structure
    if (backupData['data'] == null) {
      throw Exception('Data backup tidak valid: struktur data tidak ditemukan');
    }
    
    final data = backupData['data'] as Map<String, dynamic>;
    
    await db.transaction((txn) async {
      // Clear existing data
      await txn.delete('temuan');
      await txn.delete('perbaikan');
      await txn.delete('settings');

      // Import temuan with validation
      if (data['temuan'] != null) {
        final temuanList = data['temuan'] as List;
        for (final temuan in temuanList) {
          if (temuan is Map<String, dynamic>) {
            // Validate required fields
            if (temuan['id'] == null || temuan['category'] == null || temuan['description'] == null) {
              print('Warning: Skipping invalid temuan data: missing required fields');
              continue;
            }
            await txn.insert('temuan', temuan);
          }
        }
      }
      
      // Import perbaikan with validation
      if (data['perbaikan'] != null) {
        final perbaikanList = data['perbaikan'] as List;
        for (final perbaikan in perbaikanList) {
          if (perbaikan is Map<String, dynamic>) {
            // Validate required fields
            if (perbaikan['id'] == null || perbaikan['temuan_id'] == null || perbaikan['work_description'] == null) {
              print('Warning: Skipping invalid perbaikan data: missing required fields');
              continue;
            }
            await txn.insert('perbaikan', perbaikan);
          }
        }
      }
      
      // Import settings with validation
      if (data['settings'] != null) {
        final settingsList = data['settings'] as List;
        for (final setting in settingsList) {
          if (setting is Map<String, dynamic>) {
            // Validate required fields
            if (setting['key'] == null || setting['value'] == null) {
              print('Warning: Skipping invalid setting data: missing required fields');
              continue;
            }
            await txn.insert('settings', setting);
          }
        }
      }
    });
  }

  // ==================== SETTINGS ====================

  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isNotEmpty) {
      return result.first['value'];
    }
    return null;
  }

  Future<void> setSetting(String key, String value, {String? description}) async {
    final db = await database;
    
    await db.insert(
      'settings',
      {
        'key': key,
        'value': value,
        'description': description,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, String>> getAllSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('settings');
    
    Map<String, String> settings = {};
    for (final result in results) {
      settings[result['key']] = result['value'];
    }
    
    return settings;
  }

  // ==================== MAINTENANCE ====================

  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await database;
    
    final temuanCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM temuan')
    ) ?? 0;
    
    final perbaikanCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM perbaikan')
    ) ?? 0;

    final dbPath = await getDatabasesPath();
    final dbFile = File(join(dbPath, 'monitoring_mbz.db'));
    final dbSize = await dbFile.exists() ? await dbFile.length() : 0;

    return {
      'database_path': dbFile.path,
      'database_size': dbSize,
      'database_size_mb': (dbSize / (1024 * 1024)).toStringAsFixed(2),
      'tables': {
        'temuan_count': temuanCount,
        'perbaikan_count': perbaikanCount,
      },
      'last_backup': await getSetting('last_backup_date'),
      'version': await getSetting('app_version') ?? '1.0.0',
    };
  }

  Future<void> vacuum() async {
    final db = await database;
    await db.execute('VACUUM');
  }

  Future<void> clearAllData() async {
    final db = await database;
    
    await db.transaction((txn) async {
      await txn.delete('temuan');
      await txn.delete('perbaikan');
      // Keep settings
    });
  }

  Future<void> cleanupOldLogs({int daysToKeep = 90}) async {
    try {
      final db = await database;
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      
      // Clean up old activity logs if table exists
      await db.execute('''
        DELETE FROM activity_logs 
        WHERE timestamp < ?
      ''', [cutoffDate.toIso8601String()]);
      
      print('Cleaned up logs older than $daysToKeep days');
    } catch (e) {
      print('Error cleaning up old logs: $e');
      // Table might not exist, which is fine
    }
  }

  // ==================== HELPER METHODS ====================

  Map<String, dynamic> _temuanToMap(Temuan temuan) {
    return {
      'id': temuan.id,
      'category': temuan.category,
      'subcategory': temuan.subcategory,
      'section': temuan.section,
      'km_point': temuan.kmPoint,
      'lane': temuan.lane,
      'description': temuan.description,
      'priority': temuan.priority,
      'status': temuan.status,
      'latitude': temuan.latitude,
      'longitude': temuan.longitude,
      'photos': jsonEncode(temuan.photos),
      'created_at': temuan.createdAt.toIso8601String(),
      'created_by': temuan.createdBy,
      'updated_at': temuan.updatedAt?.toIso8601String(),
      'updated_by': temuan.updatedBy,
      'notes': temuan.notes,
    };
  }

  Temuan _mapToTemuan(Map<String, dynamic> map) {
    try {
      List<String> photos = [];
      if (map['photos'] != null && map['photos'].isNotEmpty) {
        try {
          final photosData = jsonDecode(map['photos']);
          if (photosData is List) {
            photos = photosData.cast<String>();
          }
        } catch (e) {
          // Fallback for old comma-separated format
          if (map['photos'] is String) {
            photos = map['photos'].split(',').where((p) => p.isNotEmpty).toList();
          } else if (map['photos'] is List) {
            photos = map['photos'].cast<String>();
          }
        }
      }

      final temuan = Temuan(
        id: map['id'],
        category: map['category'],
        subcategory: map['subcategory'],
        section: map['section'],
        kmPoint: map['km_point'],
        lane: map['lane'],
        description: map['description'],
        priority: map['priority'],
        status: map['status'],
        latitude: map['latitude'] ?? 0.0,
        longitude: map['longitude'] ?? 0.0,
        photos: photos,
        createdAt: DateTime.parse(map['created_at']),
        createdBy: map['created_by'],
        updatedAt: map['updated_at'] != null 
            ? DateTime.parse(map['updated_at']) 
            : null,
        updatedBy: map['updated_by'],
        notes: map['notes'],
      );
      
      print('Mapped temuan: ${temuan.id} - ${temuan.description}');
      return temuan;
    } catch (e) {
      print('Error mapping temuan: $e');
      print('Map data: $map');
      rethrow;
    }
  }

  Map<String, dynamic> _perbaikanToMap(Perbaikan perbaikan) {
    return {
      'id': perbaikan.id,
      'temuan_id': perbaikan.temuanId,
      'category': perbaikan.category,
      'subcategory': perbaikan.subcategory,
      'section': perbaikan.section,
      'km_point': perbaikan.kmPoint,
      'lane': perbaikan.lane,
      'work_description': perbaikan.workDescription,
      'contractor': perbaikan.contractor,
      'status': perbaikan.status,
      'start_date': perbaikan.startDate.toIso8601String(),
      'end_date': perbaikan.endDate?.toIso8601String(),
      'progress': perbaikan.progress,
      'before_photos': jsonEncode(perbaikan.beforePhotos),
      'progress_photos': jsonEncode(perbaikan.progressPhotos),
      'after_photos': jsonEncode(perbaikan.afterPhotos),
      'documentation_photos': perbaikan.documentationPhotos != null
          ? jsonEncode(perbaikan.documentationPhotos!)
          : null,
      'assigned_to': perbaikan.assignedTo,
      'created_at': perbaikan.createdAt.toIso8601String(),
      'created_by': perbaikan.createdBy,
      'notes': perbaikan.notes,
      'cost': perbaikan.cost,
    };
  }

  Perbaikan _mapToPerbaikan(Map<String, dynamic> map) {
    List<String> beforePhotos = [];
    List<String> progressPhotos = [];
    List<String> afterPhotos = [];
    List<String>? documentationPhotos;

    // Parse JSON photo arrays
    try {
      if (map['before_photos'] != null && map['before_photos'].isNotEmpty) {
        final beforeData = jsonDecode(map['before_photos']);
        if (beforeData is List) {
          beforePhotos = beforeData.cast<String>();
        }
      }
      
      if (map['progress_photos'] != null && map['progress_photos'].isNotEmpty) {
        final progressData = jsonDecode(map['progress_photos']);
        if (progressData is List) {
          progressPhotos = progressData.cast<String>();
        }
      }
      
      if (map['after_photos'] != null && map['after_photos'].isNotEmpty) {
        final afterData = jsonDecode(map['after_photos']);
        if (afterData is List) {
          afterPhotos = afterData.cast<String>();
        }
      }

      if (map['documentation_photos'] != null && map['documentation_photos'].isNotEmpty) {
        final docData = jsonDecode(map['documentation_photos']);
        if (docData is List) {
          documentationPhotos = docData.cast<String>();
        }
      }
    } catch (e) {
      // Fallback for old comma-separated format
      if (map['before_photos'] != null) {
        if (map['before_photos'] is String) {
          beforePhotos = map['before_photos'].split(',').where((p) => p.isNotEmpty).toList();
        } else if (map['before_photos'] is List) {
          beforePhotos = map['before_photos'].cast<String>();
        }
      }
      if (map['progress_photos'] != null) {
        if (map['progress_photos'] is String) {
          progressPhotos = map['progress_photos'].split(',').where((p) => p.isNotEmpty).toList();
        } else if (map['progress_photos'] is List) {
          progressPhotos = map['progress_photos'].cast<String>();
        }
      }
      if (map['after_photos'] != null) {
        if (map['after_photos'] is String) {
          afterPhotos = map['after_photos'].split(',').where((p) => p.isNotEmpty).toList();
        } else if (map['after_photos'] is List) {
          afterPhotos = map['after_photos'].cast<String>();
        }
      }
    }

    return Perbaikan(
      id: map['id'],
      temuanId: map['temuan_id'],
      category: map['category'],
      subcategory: map['subcategory'],
      section: map['section'],
      kmPoint: map['km_point'],
      lane: map['lane'],
      workDescription: map['work_description'],
      contractor: map['contractor'],
      status: map['status'],
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null 
          ? DateTime.parse(map['end_date']) 
          : null,
      progress: map['progress']?.toDouble() ?? 0.0,
      beforePhotos: beforePhotos,
      progressPhotos: progressPhotos,
      afterPhotos: afterPhotos,
      documentationPhotos: documentationPhotos,
      assignedTo: map['assigned_to'],
      createdAt: DateTime.parse(map['created_at']),
      createdBy: map['created_by'],
      notes: map['notes'],
      cost: map['cost']?.toDouble(),
    );
  }

  // ==================== SEARCH METHODS ====================

  Future<List<Temuan>> searchTemuan({
    String? query,
    String? category,
    String? status,
    String? priority,
    String? section,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    final conditions = <String>[];
    final args = <dynamic>[];
    
    if (query != null && query.isNotEmpty) {
      conditions.add('(description LIKE ? OR category LIKE ? OR subcategory LIKE ?)');
      args.addAll(['%$query%', '%$query%', '%$query%']);
    }
    
    if (category != null && category.isNotEmpty) {
      conditions.add('category = ?');
      args.add(category);
    }
    
    if (status != null && status.isNotEmpty) {
      conditions.add('status = ?');
      args.add(status);
    }
    
    if (priority != null && priority.isNotEmpty) {
      conditions.add('priority = ?');
      args.add(priority);
    }
    
    if (section != null && section.isNotEmpty) {
      conditions.add('section = ?');
      args.add(section);
    }
    
    if (startDate != null) {
      conditions.add('created_at >= ?');
      args.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      conditions.add('created_at <= ?');
      args.add(endDate.toIso8601String());
    }
    
    final whereClause = conditions.isNotEmpty ? conditions.join(' AND ') : null;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'temuan',
      where: whereClause,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => _mapToTemuan(maps[i]));
  }

  Future<List<Perbaikan>> searchPerbaikan({
    String? query,
    String? status,
    String? contractor,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    final conditions = <String>[];
    final args = <dynamic>[];
    
    if (query != null && query.isNotEmpty) {
      conditions.add('(work_description LIKE ? OR category LIKE ? OR subcategory LIKE ?)');
      args.addAll(['%$query%', '%$query%', '%$query%']);
    }
    
    if (status != null && status.isNotEmpty) {
      conditions.add('status = ?');
      args.add(status);
    }
    
    if (contractor != null && contractor.isNotEmpty) {
      conditions.add('contractor = ?');
      args.add(contractor);
    }
    
    if (assignedTo != null && assignedTo.isNotEmpty) {
      conditions.add('assigned_to = ?');
      args.add(assignedTo);
    }
    
    if (startDate != null) {
      conditions.add('start_date >= ?');
      args.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      conditions.add('end_date <= ?');
      args.add(endDate.toIso8601String());
    }
    
    final whereClause = conditions.isNotEmpty ? conditions.join(' AND ') : null;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'perbaikan',
      where: whereClause,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => _mapToPerbaikan(maps[i]));
  }

  // Helper methods removed as they are no longer needed after search logic improvements

  // ==================== STATISTICS METHODS ====================

  Future<Map<String, dynamic>> getDetailedStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    // Get temuan statistics
    final temuanStats = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_temuan,
        SUM(CASE WHEN status = 'Open' THEN 1 ELSE 0 END) as open_temuan,
        SUM(CASE WHEN status = 'Closed' THEN 1 ELSE 0 END) as closed_temuan,
        SUM(CASE WHEN priority = 'High' THEN 1 ELSE 0 END) as high_priority,
        SUM(CASE WHEN priority = 'Medium' THEN 1 ELSE 0 END) as medium_priority,
        SUM(CASE WHEN priority = 'Low' THEN 1 ELSE 0 END) as low_priority
      FROM temuan
      WHERE 1=1
      ${startDate != null ? "AND created_at >= '${startDate.toIso8601String()}'" : ''}
      ${endDate != null ? "AND created_at <= '${endDate.toIso8601String()}'" : ''}
    ''');

    // Get perbaikan statistics
    final perbaikanStats = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_perbaikan,
        SUM(CASE WHEN status = 'In Progress' THEN 1 ELSE 0 END) as in_progress,
        SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) as completed,
        SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) as pending,
        AVG(progress) as avg_progress
      FROM perbaikan
      WHERE 1=1
      ${startDate != null ? "AND created_at >= '${startDate.toIso8601String()}'" : ''}
      ${endDate != null ? "AND created_at <= '${endDate.toIso8601String()}'" : ''}
    ''');

    return {
      'temuan': temuanStats.first,
      'perbaikan': perbaikanStats.first,
    };
  }

  // ==================== ACTIVITY LOGS ====================

  Future<void> addActivityLog({
    required String action,
    required String entityType,
    String? entityId,
    String? userId,
    String? details,
  }) async {
    try {
      // Validate required parameters
      if (action.isEmpty) {
        print('Warning: Activity log action is empty');
        return;
      }
      if (entityType.isEmpty) {
        print('Warning: Activity log entity type is empty');
        return;
      }

      final db = await database;
      await db.insert('activity_logs', {
        'user_id': userId ?? 'system',
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding activity log: $e');
      // Don't throw error for activity logs as they're not critical
      // But log the error for debugging
    }
  }

  Future<List<Map<String, dynamic>>> getActivityLogs({
    int limit = 50,
    String? userId,
  }) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'activity_logs',
        where: userId != null ? 'user_id = ?' : null,
        whereArgs: userId != null ? [userId] : null,
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      return maps;
    } catch (e) {
      print('Error getting activity logs: $e');
      return [];
    }
  }

  // ==================== CLOSE DATABASE ====================

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}