// lib/config/category_config.dart
import 'package:flutter/material.dart';

class CategoryConfig {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> subcategories;
  final bool showKmPoint;
  final bool showLane;
  final bool showSection;
  final String description;
  final List<String> priorityLevels;
  final String helpText;

  CategoryConfig({
    required this.name,
    required this.icon,
    required this.color,
    required this.subcategories,
    this.showKmPoint = true,
    this.showLane = true,
    this.showSection = true,
    required this.description,
    this.priorityLevels = const ['low', 'medium', 'high', 'critical'],
    this.helpText = '',
  });
}

class AppCategoryConfigs {
  static final Map<String, CategoryConfig> configs = {
    'jalan': CategoryConfig(
      name: 'Jalan',
      icon: Icons.directions_car,
      color: Colors.blue,
      subcategories: [
        'Lubang',
        'Retak Memanjang',
        'Retak Melintang',
        'Retak Kulit Buaya',
        'Aus/Abrasi',
        'Amblas',
        'Gelombang',
        'Bleeding/Berdarah',
        'Raveling/Butiran Lepas'
      ],
      showKmPoint: true,
      showLane: true,
      showSection: true,
      description: 'Kerusakan pada permukaan dan struktur jalan',
      helpText: 'Laporkan kondisi kerusakan jalan seperti lubang, retak, aus, atau kerusakan lainnya pada permukaan jalan',
    ),
    
    'jembatan': CategoryConfig(
      name: 'Jembatan',
      icon: Icons.architecture,
      color: Colors.brown,
      subcategories: [
        'Kerusakan Struktur Utama',
        'Korosi Baja',
        'Retak Beton',
        'Kebocoran',
        'Joint Expansion Rusak',
        'Guardrail Rusak',
        'Drainase Jembatan Tersumbat',
        'Bearing Pad Rusak',
        'Abutment Bergeser'
      ],
      showKmPoint: true,
      showLane: false,
      showSection: true,
      description: 'Kerusakan pada struktur dan komponen jembatan',
      helpText: 'Laporkan kerusakan pada struktur jembatan, seperti retak beton, korosi, atau kerusakan komponen lainnya',
    ),
    
    'marka': CategoryConfig(
      name: 'Marka Jalan',
      icon: Icons.straighten,
      color: Colors.orange,
      subcategories: [
        'Marka Garis Putus Memudar',
        'Marka Garis Solid Memudar',
        'Marka Panah Tidak Terlihat',
        'Marka Zebra Cross Rusak',
        'Marka Stop Line Hilang',
        'Cat Thermoplastic Terkelupas',
        'Posisi Marka Salah',
        'Reflektifitas Berkurang'
      ],
      showKmPoint: true,
      showLane: true,
      showSection: true,
      description: 'Kondisi marka dan penanda jalan',
      helpText: 'Laporkan kondisi marka jalan yang memudar, rusak, hilang, atau tidak sesuai standar',
    ),
    
    'rambu': CategoryConfig(
      name: 'Rambu Lalu Lintas',
      icon: Icons.traffic,
      color: Colors.red,
      subcategories: [
        'Rambu Rusak/Penyok',
        'Rambu Hilang',
        'Rambu Terbalik',
        'Rambu Tertutup Vegetasi',
        'Tulisan/Gambar Pudar',
        'Tiang Rambu Miring',
        'Reflektif Tidak Berfungsi',
        'Posisi Rambu Salah'
      ],
      showKmPoint: true,
      showLane: false,
      showSection: true,
      description: 'Kondisi rambu dan papan informasi lalu lintas',
      helpText: 'Laporkan kondisi rambu lalu lintas yang rusak, hilang, atau tidak berfungsi dengan baik',
    ),
    
    'drainase': CategoryConfig(
      name: 'Sistem Drainase',
      icon: Icons.water_drop,
      color: Colors.teal,
      subcategories: [
        'Saluran Tersumbat',
        'Gorong-gorong Rusak',
        'Inlet/Outlet Bocor',
        'Tidak Ada Saluran',
        'Saluran Dangkal',
        'Sedimentasi Berlebih',
        'Tutup Drainase Hilang',
        'Genangan Air'
      ],
      showKmPoint: true,
      showLane: false,
      showSection: true,
      description: 'Kondisi sistem drainase dan pengelolaan air',
      helpText: 'Laporkan masalah pada sistem drainase seperti sumbatan, kerusakan, atau genangan air',
    ),
    
    'penerangan': CategoryConfig(
      name: 'Penerangan Jalan',
      icon: Icons.lightbulb,
      color: Colors.amber.shade700,
      subcategories: [
        'Lampu PJU Mati',
        'Lampu Redup/Berkedip',
        'Tiang Lampu Rusak',
        'Kabel Putus',
        'Panel Listrik Bermasalah',
        'Lampu Hilang',
        'Armature Rusak',
        'Timer Tidak Berfungsi'
      ],
      showKmPoint: true,
      showLane: false,
      showSection: true,
      description: 'Kondisi sistem penerangan jalan umum',
      helpText: 'Laporkan masalah pada sistem penerangan jalan seperti lampu mati, rusak, atau tidak berfungsi',
    ),
    
    'fasilitas': CategoryConfig(
      name: 'Fasilitas Pendukung',
      icon: Icons.store,
      color: Colors.purple,
      subcategories: [
        'Rest Area Rusak',
        'Toilet Tidak Berfungsi',
        'Tempat Sampah Hilang',
        'Bangku Taman Rusak',
        'Pagar Pembatas Roboh',
        'CCTV Tidak Berfungsi',
        'Emergency Phone Rusak',
        'Papan Informasi Rusak'
      ],
      showKmPoint: true,
      showLane: false,
      showSection: true,
      description: 'Kerusakan fasilitas pendukung jalan tol',
      helpText: 'Laporkan kerusakan pada fasilitas pendukung seperti rest area, toilet, atau fasilitas lainnya',
    ),
    
    'keamanan': CategoryConfig(
      name: 'Keamanan & Keselamatan',
      icon: Icons.security,
      color: Colors.deepOrange,
      subcategories: [
        'Guardrail Rusak',
        'Barrier Beton Retak',
        'Kawat Duri Putus',
        'Lubang pada Pagar',
        'Reflektor Jalan Hilang',
        'Delineator Rusak',
        'Cone Pengaman Hilang',
        'Warning Light Mati'
      ],
      showKmPoint: true,
      showLane: false,
      showSection: true,
      description: 'Masalah terkait keamanan dan keselamatan jalan',
      helpText: 'Laporkan masalah keamanan seperti guardrail rusak, barrier rusak, atau fasilitas keselamatan lainnya',
    ),
  };

  // Helper methods
  static CategoryConfig? getConfig(String categoryKey) {
    return configs[categoryKey];
  }

  static List<String> getAllCategoryKeys() {
    return configs.keys.toList();
  }

  static List<CategoryConfig> getAllConfigs() {
    return configs.values.toList();
  }

  static Map<String, List<String>> getSubcategoriesMap() {
    return configs.map((key, config) => MapEntry(key, config.subcategories));
  }

  // Method to get display name
  static String getCategoryDisplayName(String categoryKey) {
    return configs[categoryKey]?.name ?? categoryKey;
  }

  // Method to get category color
  static Color getCategoryColor(String categoryKey) {
    return configs[categoryKey]?.color ?? Colors.grey;
  }

  // Method to get category icon
  static IconData getCategoryIcon(String categoryKey) {
    return configs[categoryKey]?.icon ?? Icons.construction;
  }
}

// Priority configuration
class PriorityConfig {
  static const Map<String, PriorityData> priorities = {
    'low': PriorityData(
      name: 'Rendah',
      color: Colors.green,
      description: 'Tidak mengganggu operasional, dapat diperbaiki sesuai jadwal maintenance rutin',
      icon: Icons.keyboard_arrow_down,
    ),
    'medium': PriorityData(
      name: 'Sedang',
      color: Colors.orange,
      description: 'Perlu perhatian, sebaiknya diperbaiki dalam 1-2 minggu',
      icon: Icons.remove,
    ),
    'high': PriorityData(
      name: 'Tinggi',
      color: Colors.deepOrange,
      description: 'Mengganggu kenyamanan, perlu diperbaiki dalam 1-3 hari',
      icon: Icons.keyboard_arrow_up,
    ),
    'critical': PriorityData(
      name: 'Kritis',
      color: Colors.red,
      description: 'Berbahaya, memerlukan tindakan segera (dalam 24 jam)',
      icon: Icons.warning,
    ),
  };

  static PriorityData? getPriorityData(String priorityKey) {
    return priorities[priorityKey];
  }

  static String getPriorityName(String priorityKey) {
    return priorities[priorityKey]?.name ?? priorityKey;
  }

  static Color getPriorityColor(String priorityKey) {
    return priorities[priorityKey]?.color ?? Colors.grey;
  }

  static IconData getPriorityIcon(String priorityKey) {
    return priorities[priorityKey]?.icon ?? Icons.help;
  }
}

class PriorityData {
  final String name;
  final Color color;
  final String description;
  final IconData icon;

  const PriorityData({
    required this.name,
    required this.color,
    required this.description,
    required this.icon,
  });
}

// Status configuration
class StatusConfig {
  static const Map<String, StatusData> statuses = {
    'pending': StatusData(
      name: 'Menunggu',
      color: Colors.orange,
      description: 'Temuan sedang menunggu untuk diproses',
      icon: Icons.pending,
    ),
    'in_progress': StatusData(
      name: 'Sedang Diproses',
      color: Colors.blue,
      description: 'Temuan sedang dalam proses penanganan',
      icon: Icons.sync,
    ),
    'completed': StatusData(
      name: 'Selesai',
      color: Colors.green,
      description: 'Temuan telah selesai ditangani',
      icon: Icons.check_circle,
    ),
    'cancelled': StatusData(
      name: 'Dibatalkan',
      color: Colors.red,
      description: 'Temuan dibatalkan atau tidak valid',
      icon: Icons.cancel,
    ),
  };

  static StatusData? getStatusData(String statusKey) {
    return statuses[statusKey];
  }

  static String getStatusName(String statusKey) {
    return statuses[statusKey]?.name ?? statusKey;
  }

  static Color getStatusColor(String statusKey) {
    return statuses[statusKey]?.color ?? Colors.grey;
  }

  static IconData getStatusIcon(String statusKey) {
    return statuses[statusKey]?.icon ?? Icons.help;
  }
}

class StatusData {
  final String name;
  final Color color;
  final String description;
  final IconData icon;

  const StatusData({
    required this.name,
    required this.color,
    required this.description,
    required this.icon,
  });
}