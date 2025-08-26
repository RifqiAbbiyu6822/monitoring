// lib/services/database_service.dart
import 'dart:async';
import 'dart:io';
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
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'monitoring_mbz.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
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
        assigned_to TEXT NOT NULL,
        created_at TEXT NOT NULL,
        created_by TEXT NOT NULL,
        notes TEXT,
        cost REAL,
        FOREIGN KEY (temuan_id) REFERENCES temuan (id) ON DELETE CASCADE
      )
    ''');

    // Table untuk User/Petugas
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        full_name TEXT NOT NULL,
        email TEXT,
        role TEXT NOT NULL DEFAULT 'operator',
        section TEXT,
        phone TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // Table untuk Log Aktivitas
    await db.execute('''
      CREATE TABLE activity_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        action_type TEXT NOT NULL, -- create, update, delete
        target_type TEXT NOT NULL, -- temuan, perbaikan
        target_id TEXT NOT NULL,
        description TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Table untuk Kategori dan Sub-kategori
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        icon_code INTEGER,
        color_code TEXT,
        is_active INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE subcategories (
        id TEXT PRIMARY KEY,
        category_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (category_id) REFERENCES categories (id)
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

    // Indexes untuk optimasi query
    await db.execute('CREATE INDEX idx_temuan_status ON temuan (status)');
    await db.execute('CREATE INDEX idx_temuan_priority ON temuan (priority)');
    await db.execute('CREATE INDEX idx_temuan_section ON temuan (section)');
    await db.execute('CREATE INDEX idx_temuan_created_at ON temuan (created_at)');
    
    await db.execute('CREATE INDEX idx_perbaikan_status ON perbaikan (status)');
    await db.execute('CREATE INDEX idx_perbaikan_temuan_id ON perbaikan (temuan_id)');
    await db.execute('CREATE INDEX idx_perbaikan_created_at ON perbaikan (created_at)');
    
    await db.execute('CREATE INDEX idx_activity_logs_created_at ON activity_logs (created_at)');
    await db.execute('CREATE INDEX idx_activity_logs_user_id ON activity_logs (user_id)');

    // Insert data default
    await _insertDefaultData(db);
  }

  Future<void> _insertDefaultData(Database db) async {
    // Insert default user
    await db.insert('users', {
      'id': 'user_default',
      'username': 'admin',
      'full_name': 'Administrator',
      'email': 'admin@mbz.com',
      'role': 'admin',
      'section': 'All',
      'phone': '081234567890',
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Insert categories
    final categories = [
      {
        'id': 'jalan',
        'name': 'Jalan',
        'description': 'Kerusakan pada permukaan dan struktur jalan',
        'icon_code': 0xe1a5, // Icons.directions_car
        'color_code': '#2563EB',
        'is_active': 1,
      },
      {
        'id': 'jembatan',
        'name': 'Jembatan',
        'description': 'Kerusakan pada struktur dan komponen jembatan',
        'icon_code': 0xe048, // Icons.architecture
        'color_code': '#8B5CF6',
        'is_active': 1,
      },
      {
        'id': 'marka',
        'name': 'Marka Jalan',
        'description': 'Kondisi marka dan penanda jalan',
        'icon_code': 0xe3a6, // Icons.straighten
        'color_code': '#F59E0B',
        'is_active': 1,
      },
      {
        'id': 'rambu',
        'name': 'Rambu Lalu Lintas',
        'description': 'Kondisi rambu dan papan informasi lalu lintas',
        'icon_code': 0xe553, // Icons.traffic
        'color_code': '#EF4444',
        'is_active': 1,
      },
      {
        'id': 'drainase',
        'name': 'Sistem Drainase',
        'description': 'Kondisi sistem drainase dan pengelolaan air',
        'icon_code': 0xe798, // Icons.water_drop
        'color_code': '#14B8A6',
        'is_active': 1,
      },
      {
        'id': 'penerangan',
        'name': 'Penerangan Jalan',
        'description': 'Kondisi sistem penerangan jalan umum',
        'icon_code': 0xe335, // Icons.lightbulb
        'color_code': '#F59E0B',
        'is_active': 1,
      },
    ];

    for (final category in categories) {
      await db.insert('categories', category);
    }

    // Insert subcategories for Jalan
    final jalanSubcategories = [
      'Lubang', 'Retak Memanjang', 'Retak Melintang', 'Retak Kulit Buaya',
      'Aus/Abrasi', 'Amblas', 'Gelombang', 'Bleeding/Berdarah', 'Raveling/Butiran Lepas'
    ];

    for (int i = 0; i < jalanSubcategories.length; i++) {
      await db.insert('subcategories', {
        'id': 'jalan_sub_$i',
        'category_id': 'jalan',
        'name': jalanSubcategories[i],
        'description': 'Kerusakan jalan: ${jalanSubcategories[i]}',
        'is_active': 1,
      });
    }

    // Insert subcategories for other categories (simplified)
    final otherSubcategories = {
      'jembatan': ['Kerusakan Struktur Utama', 'Korosi Baja', 'Retak Beton', 'Kebocoran'],
      'marka': ['Marka Garis Putus Memudar', 'Marka Garis Solid Memudar', 'Marka Panah Tidak Terlihat'],
      'rambu': ['Rambu Rusak/Penyok', 'Rambu Hilang', 'Rambu Terbalik', 'Rambu Tertutup Vegetasi'],
      'drainase': ['Saluran Tersumbat', 'Gorong-gorong Rusak', 'Inlet/Outlet Bocor', 'Tidak Ada Saluran'],
      'penerangan': ['Lampu PJU Mati', 'Lampu Redup/Berkedip', 'Tiang Lampu Rusak', 'Kabel Putus'],
    };

    for (final entry in otherSubcategories.entries) {
      for (int i = 0; i < entry.value.length; i++) {
        await db.insert('subcategories', {
          'id': '${entry.key}_sub_$i',
          'category_id': entry.key,
          'name': entry.value[i],
          'description': 'Sub kategori ${entry.key}: ${entry.value[i]}',
          'is_active': 1,
        });
      }
    }

    // Insert default settings
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

  // ==================== TEMUAN OPERATIONS ====================

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<List<Temuan>> getAllTemuan() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'temuan',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return _mapToTemuan(maps[i]);
    });
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
    final String id = _generateId();

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

    await db.insert('temuan', _temuanToMap(temuan));
    
    // Log activity
    await _logActivity(
      userId: temuanData['createdBy'] ?? 'user_default',
      actionType: 'create',
      targetType: 'temuan',
      targetId: id,
      description: 'Membuat temuan: ${temuan.description}',
    );

    return temuan;
  }

  Future<Temuan> updateTemuan(String id, Map<String, dynamic> updateData) async {
    final db = await database;
    
    // Get existing temuan
    final existingTemuan = await getTemuanById(id);
    if (existingTemuan == null) {
      throw Exception('Temuan not found');
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
      updatedBy: updateData['updatedBy'],
      notes: updateData['notes'] ?? existingTemuan.notes,
    );

    await db.update(
      'temuan',
      _temuanToMap(updatedTemuan),
      where: 'id = ?',
      whereArgs: [id],
    );

    // Log activity
    await _logActivity(
      userId: updateData['updatedBy'] ?? 'user_default',
      actionType: 'update',
      targetType: 'temuan',
      targetId: id,
      description: 'Mengupdate temuan: ${updatedTemuan.description}',
    );

    return updatedTemuan;
  }

  Future<void> deleteTemuan(String id) async {
    final db = await database;
    
    // Get temuan for logging
    final temuan = await getTemuanById(id);
    
    await db.delete(
      'temuan',
      where: 'id = ?',
      whereArgs: [id],
    );

    // Log activity
    await _logActivity(
      userId: 'user_default',
      actionType: 'delete',
      targetType: 'temuan',
      targetId: id,
      description: 'Menghapus temuan: ${temuan?.description ?? id}',
    );
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
      assignedTo: perbaikanData['assignedTo'],
      createdAt: DateTime.now(),
      createdBy: perbaikanData['createdBy'] ?? 'Unknown User',
      notes: perbaikanData['notes'],
      cost: perbaikanData['cost']?.toDouble(),
    );

    await db.insert('perbaikan', _perbaikanToMap(perbaikan));
    
    // Update temuan status to in_progress
    await db.update(
      'temuan',
      {
        'status': 'in_progress',
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': perbaikan.createdBy,
      },
      where: 'id = ?',
      whereArgs: [perbaikan.temuanId],
    );

    // Log activity
    await _logActivity(
      userId: perbaikanData['createdBy'] ?? 'user_default',
      actionType: 'create',
      targetType: 'perbaikan',
      targetId: id,
      description: 'Membuat perbaikan: ${perbaikan.workDescription}',
    );

    return perbaikan;
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

    // Update temuan status if perbaikan is completed
    if (updatedPerbaikan.status == 'selesai' && existingPerbaikan.status != 'selesai') {
      await db.update(
        'temuan',
        {
          'status': 'completed',
          'updated_at': DateTime.now().toIso8601String(),
          'updated_by': 'system',
        },
        where: 'id = ?',
        whereArgs: [updatedPerbaikan.temuanId],
      );
    }

    // Log activity
    await _logActivity(
      userId: 'user_default',
      actionType: 'update',
      targetType: 'perbaikan',
      targetId: id,
      description: 'Mengupdate perbaikan: ${updatedPerbaikan.workDescription}',
    );

    return updatedPerbaikan;
  }

  Future<void> deletePerbaikan(String id) async {
    final db = await database;
    
    // Get perbaikan for logging and temuan update
    final perbaikan = await getPerbaikanById(id);
    
    await db.delete(
      'perbaikan',
      where: 'id = ?',
      whereArgs: [id],
    );

    // Reset temuan status to pending
    if (perbaikan != null) {
      await db.update(
        'temuan',
        {
          'status': 'pending',
          'updated_at': DateTime.now().toIso8601String(),
          'updated_by': 'system',
        },
        where: 'id = ?',
        whereArgs: [perbaikan.temuanId],
      );
    }

    // Log activity
    await _logActivity(
      userId: 'user_default',
      actionType: 'delete',
      targetType: 'perbaikan',
      targetId: id,
      description: 'Menghapus perbaikan: ${perbaikan?.workDescription ?? id}',
    );
  }

  // ==================== STATISTICS ====================

  Future<Map<String, int>> getSummaryStatistics() async {
    final db = await database;

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

  // ==================== ACTIVITY LOGS ====================

  Future<void> _logActivity({
    required String userId,
    required String actionType,
    required String targetType,
    required String targetId,
    required String description,
  }) async {
    final db = await database;
    
    await db.insert('activity_logs', {
      'id': _generateId(),
      'user_id': userId,
      'action_type': actionType,
      'target_type': targetType,
      'target_id': targetId,
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getActivityLogs({
    int limit = 50,
    String? userId,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (userId != null) {
      whereClause = 'WHERE user_id = ?';
      whereArgs = [userId];
    }
    
    final List<Map<String, dynamic>> logs = await db.rawQuery('''
      SELECT al.*, u.full_name as user_name
      FROM activity_logs al
      LEFT JOIN users u ON al.user_id = u.id
      $whereClause
      ORDER BY al.created_at DESC
      LIMIT ?
    ''', [...whereArgs, limit]);

    return logs;
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
      'photos': temuan.photos.join(','), // Convert list to comma-separated string
      'created_at': temuan.createdAt.toIso8601String(),
      'created_by': temuan.createdBy,
      'updated_at': temuan.updatedAt?.toIso8601String(),
      'updated_by': temuan.updatedBy,
      'notes': temuan.notes,
    };
  }

  Temuan _mapToTemuan(Map<String, dynamic> map) {
    return Temuan(
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
      photos: map['photos'] != null && map['photos'].isNotEmpty 
          ? map['photos'].split(',') 
          : <String>[],
      createdAt: DateTime.parse(map['created_at']),
      createdBy: map['created_by'],
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : null,
      updatedBy: map['updated_by'],
      notes: map['notes'],
    );
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
      'before_photos': perbaikan.beforePhotos.join(','),
      'progress_photos': perbaikan.progressPhotos.join(','),
      'after_photos': perbaikan.afterPhotos.join(','),
      'assigned_to': perbaikan.assignedTo,
      'created_at': perbaikan.createdAt.toIso8601String(),
      'created_by': perbaikan.createdBy,
      'notes': perbaikan.notes,
      'cost': perbaikan.cost,
    };
  }

  Perbaikan _mapToPerbaikan(Map<String, dynamic> map) {
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
      beforePhotos: map['before_photos'] != null && map['before_photos'].isNotEmpty 
          ? map['before_photos'].split(',') 
          : <String>[],
      progressPhotos: map['progress_photos'] != null && map['progress_photos'].isNotEmpty 
          ? map['progress_photos'].split(',') 
          : <String>[],
      afterPhotos: map['after_photos'] != null && map['after_photos'].isNotEmpty 
          ? map['after_photos'].split(',') 
          : <String>[],
      assignedTo: map['assigned_to'],
      createdAt: DateTime.parse(map['created_at']),
      createdBy: map['created_by'],
      notes: map['notes'],
      cost: map['cost']?.toDouble(),
    );
  }

  // ==================== SEARCH & FILTER OPERATIONS ====================

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
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (query != null && query.isNotEmpty) {
      whereClause += ' AND (description LIKE ? OR km_point LIKE ? OR notes LIKE ?)';
      whereArgs.addAll(['%$query%', '%$query%', '%$query%']);
    }

    if (category != null) {
      whereClause += ' AND category = ?';
      whereArgs.add(category);
    }

    if (status != null) {
      whereClause += ' AND status = ?';
      whereArgs.add(status);
    }

    if (priority != null) {
      whereClause += ' AND priority = ?';
      whereArgs.add(priority);
    }

    if (section != null) {
      whereClause += ' AND section = ?';
      whereArgs.add(section);
    }

    if (startDate != null) {
      whereClause += ' AND created_at >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClause += ' AND created_at <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'temuan',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return _mapToTemuan(maps[i]);
    });
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
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (query != null && query.isNotEmpty) {
      whereClause += ' AND (work_description LIKE ? OR notes LIKE ?)';
      whereArgs.addAll(['%$query%', '%$query%']);
    }

    if (status != null) {
      whereClause += ' AND status = ?';
      whereArgs.add(status);
    }

    if (contractor != null) {
      whereClause += ' AND contractor LIKE ?';
      whereArgs.add('%$contractor%');
    }

    if (assignedTo != null) {
      whereClause += ' AND assigned_to LIKE ?';
      whereArgs.add('%$assignedTo%');
    }

    if (startDate != null) {
      whereClause += ' AND created_at >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClause += ' AND created_at <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'perbaikan',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return _mapToPerbaikan(maps[i]);
    });
  }

  // ==================== ADVANCED ANALYTICS ====================

  Future<Map<String, dynamic>> getDetailedStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    String dateFilter = '';
    List<dynamic> dateArgs = [];
    
    if (startDate != null && endDate != null) {
      dateFilter = ' WHERE created_at BETWEEN ? AND ?';
      dateArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    } else if (startDate != null) {
      dateFilter = ' WHERE created_at >= ?';
      dateArgs = [startDate.toIso8601String()];
    } else if (endDate != null) {
      dateFilter = ' WHERE created_at <= ?';
      dateArgs = [endDate.toIso8601String()];
    }

    // Temuan statistics by category
    final categoryStats = await db.rawQuery('''
      SELECT category, COUNT(*) as count, 
             SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
             SUM(CASE WHEN status = 'in_progress' THEN 1 ELSE 0 END) as in_progress,
             SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed
      FROM temuan$dateFilter
      GROUP BY category
    ''', dateArgs);

    // Temuan statistics by priority
    final priorityStats = await db.rawQuery('''
      SELECT priority, COUNT(*) as count
      FROM temuan$dateFilter
      GROUP BY priority
    ''', dateArgs);

    // Temuan statistics by section
    final sectionStats = await db.rawQuery('''
      SELECT section, COUNT(*) as count
      FROM temuan$dateFilter
      GROUP BY section
    ''', dateArgs);

    // Perbaikan statistics
    final perbaikanStats = await db.rawQuery('''
      SELECT status, COUNT(*) as count, AVG(progress) as avg_progress
      FROM perbaikan$dateFilter
      GROUP BY status
    ''', dateArgs);

    // Monthly trend (last 12 months)
    final monthlyTrend = await db.rawQuery('''
      SELECT strftime('%Y-%m', created_at) as month,
             COUNT(*) as temuan_count
      FROM temuan
      WHERE created_at >= date('now', '-12 months')
      GROUP BY strftime('%Y-%m', created_at)
      ORDER BY month
    ''');

    // Top contractors by work count
    final contractorStats = await db.rawQuery('''
      SELECT contractor, COUNT(*) as work_count,
             AVG(progress) as avg_progress,
             SUM(CASE WHEN status = 'selesai' THEN 1 ELSE 0 END) as completed_count
      FROM perbaikan$dateFilter
      GROUP BY contractor
      ORDER BY work_count DESC
      LIMIT 10
    ''', dateArgs);

    return {
      'categoryStats': categoryStats,
      'priorityStats': priorityStats,
      'sectionStats': sectionStats,
      'perbaikanStats': perbaikanStats,
      'monthlyTrend': monthlyTrend,
      'contractorStats': contractorStats,
    };
  }

  // ==================== BACKUP & RESTORE ====================

  Future<Map<String, dynamic>> exportData() async {
    final db = await database;
    
    final temuan = await db.query('temuan');
    final perbaikan = await db.query('perbaikan');
    final activityLogs = await db.query('activity_logs');
    final users = await db.query('users');
    final categories = await db.query('categories');
    final subcategories = await db.query('subcategories');
    final settings = await db.query('settings');

    return {
      'export_date': DateTime.now().toIso8601String(),
      'version': '1.0',
      'data': {
        'temuan': temuan,
        'perbaikan': perbaikan,
        'activity_logs': activityLogs,
        'users': users,
        'categories': categories,
        'subcategories': subcategories,
        'settings': settings,
      },
    };
  }

  Future<void> importData(Map<String, dynamic> backupData) async {
    final db = await database;
    
    await db.transaction((txn) async {
      // Clear existing data
      await txn.delete('temuan');
      await txn.delete('perbaikan');
      await txn.delete('activity_logs');
      await txn.delete('users');
      await txn.delete('categories');
      await txn.delete('subcategories');
      await txn.delete('settings');

      final data = backupData['data'];
      
      // Import data
      for (final temuan in data['temuan'] ?? []) {
        await txn.insert('temuan', temuan);
      }
      
      for (final perbaikan in data['perbaikan'] ?? []) {
        await txn.insert('perbaikan', perbaikan);
      }
      
      for (final log in data['activity_logs'] ?? []) {
        await txn.insert('activity_logs', log);
      }
      
      for (final user in data['users'] ?? []) {
        await txn.insert('users', user);
      }
      
      for (final category in data['categories'] ?? []) {
        await txn.insert('categories', category);
      }
      
      for (final subcategory in data['subcategories'] ?? []) {
        await txn.insert('subcategories', subcategory);
      }
      
      for (final setting in data['settings'] ?? []) {
        await txn.insert('settings', setting);
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

  Future<void> cleanupOldLogs({int daysToKeep = 90}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    
    await db.delete(
      'activity_logs',
      where: 'created_at < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await database;
    
    final temuanCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM temuan')
    ) ?? 0;
    
    final perbaikanCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM perbaikan')
    ) ?? 0;
    
    final logsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM activity_logs')
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
        'activity_logs_count': logsCount,
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
      await txn.delete('activity_logs');
      // Keep users, categories, subcategories, and settings
    });
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