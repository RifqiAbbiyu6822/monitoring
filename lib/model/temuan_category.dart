import 'package:flutter/material.dart';

class TemuanCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<String> subcategories;

  TemuanCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.subcategories,
  });
}

// models/summary_data.dart
class SummaryData {
  final int totalTemuan;
  final int temuanPending;
  final int temuanSelesai;
  final int totalPerbaikan;
  final int perbaikanOngoing;
  final int perbaikanSelesai;

  SummaryData({
    required this.totalTemuan,
    required this.temuanPending,
    required this.temuanSelesai,
    required this.totalPerbaikan,
    required this.perbaikanOngoing,
    required this.perbaikanSelesai,
  });
}