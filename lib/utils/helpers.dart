import 'package:flutter/material.dart';

class Helpers {
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.yellow.shade700;
      case 'high':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
      case 'ongoing':
        return Colors.blue;
      case 'completed':
      case 'selesai':
        return Colors.green;
      case 'cancelled':
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'jalan':
        return Icons.directions_car;
      case 'jembatan':
        return Icons.architecture;
      case 'marka':
        return Icons.straighten;
      case 'rambu':
        return Icons.traffic;
      case 'drainase':
        return Icons.water_drop;
      case 'penerangan':
        return Icons.lightbulb;
      case 'rest_area':
        return Icons.local_parking;
      case 'tol_gate':
        return Icons.account_balance;
      default:
        return Icons.construction;
    }
  }

  static String getPriorityText(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return 'Rendah';
      case 'medium':
        return 'Sedang';
      case 'high':
        return 'Tinggi';
      case 'critical':
        return 'Kritis';
      default:
        return 'Tidak Diketahui';
    }
  }

  static String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'in_progress':
      case 'ongoing':
        return 'Sedang Berlangsung';
      case 'completed':
      case 'selesai':
        return 'Selesai';
      case 'cancelled':
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return 'Tidak Diketahui';
    }
  }
} 