// lib/utils/status_validator.dart
class StatusValidator {
  static const Map<String, List<String>> _allowedTransitions = {
    'pending': ['in_progress', 'cancelled'],
    'in_progress': ['completed', 'pending', 'cancelled'],
    'completed': [], // Once completed, no transitions allowed
    'cancelled': ['pending'], // Can reopen cancelled items
  };

  static const Map<String, String> _statusDisplayNames = {
    'pending': 'Pending',
    'in_progress': 'In Progress',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
  };

  /// Validate if status transition is allowed
  static bool isValidTransition(String fromStatus, String toStatus) {
    if (fromStatus == toStatus) return true;
    
    final allowedStatuses = _allowedTransitions[fromStatus];
    return allowedStatuses?.contains(toStatus) ?? false;
  }

  /// Get allowed next statuses for current status
  static List<String> getAllowedNextStatuses(String currentStatus) {
    return _allowedTransitions[currentStatus] ?? [];
  }

  /// Get status display name
  static String getStatusDisplayName(String status) {
    return _statusDisplayNames[status] ?? status;
  }

  /// Validate temuan status can be changed based on existing perbaikan
  static String? validateTemuanStatusChange(
    String currentStatus, 
    String newStatus,
    {bool hasPerbaikan = false, String? perbaikanStatus}
  ) {
    // Check basic transition validity
    if (!isValidTransition(currentStatus, newStatus)) {
      return 'Perubahan status dari ${getStatusDisplayName(currentStatus)} ke ${getStatusDisplayName(newStatus)} tidak diizinkan';
    }

    // If temuan has perbaikan, check consistency
    if (hasPerbaikan && perbaikanStatus != null) {
      if (newStatus == 'completed' && perbaikanStatus != 'selesai') {
        return 'Temuan tidak bisa diselesaikan jika perbaikan belum selesai';
      }
      
      if (newStatus == 'cancelled' && perbaikanStatus == 'ongoing') {
        return 'Temuan tidak bisa dibatalkan jika perbaikan sedang berlangsung';
      }
    }

    return null; // Valid transition
  }

  /// Validate perbaikan status change based on temuan status
  static String? validatePerbaikanStatusChange(
    String currentStatus,
    String newStatus,
    String temuanStatus,
    {double? progress}
  ) {
    // Map perbaikan status to standard status for validation
    String mappedCurrentStatus = _mapPerbaikanToStandardStatus(currentStatus);
    String mappedNewStatus = _mapPerbaikanToStandardStatus(newStatus);

    // Check basic transition validity
    if (!isValidTransition(mappedCurrentStatus, mappedNewStatus)) {
      return 'Perubahan status perbaikan tidak valid';
    }

    // Check consistency with temuan status
    if (temuanStatus == 'completed' && newStatus != 'selesai') {
      return 'Perbaikan harus selesai jika temuan sudah diselesaikan';
    }

    if (temuanStatus == 'cancelled' && newStatus == 'ongoing') {
      return 'Perbaikan tidak bisa berjalan jika temuan dibatalkan';
    }

    // Validate progress consistency
    if (progress != null) {
      if (newStatus == 'selesai' && progress < 100) {
        return 'Progress harus 100% untuk status selesai';
      }
      
      if (newStatus == 'pending' && progress > 0) {
        return 'Progress harus 0% untuk status pending';
      }
      
      if (newStatus == 'ongoing' && progress == 0) {
        return 'Progress harus lebih dari 0% untuk status ongoing';
      }
    }

    return null; // Valid transition
  }

  /// Map perbaikan specific status to standard status for validation
  static String _mapPerbaikanToStandardStatus(String perbaikanStatus) {
    switch (perbaikanStatus) {
      case 'pending':
        return 'pending';
      case 'ongoing':
        return 'in_progress';
      case 'selesai':
        return 'completed';
      case 'cancelled':
        return 'cancelled';
      default:
        return perbaikanStatus;
    }
  }

  /// Auto-suggest next logical status based on current state
  static String? suggestNextStatus(String currentStatus, {double? progress}) {
    if (progress != null) {
      if (currentStatus == 'pending' && progress > 0) {
        return 'ongoing';
      }
      if (currentStatus == 'ongoing' && progress >= 100) {
        return 'selesai';
      }
    }
    
    return null;
  }

  /// Check if status requires specific conditions
  static Map<String, dynamic> getStatusRequirements(String status) {
    switch (status) {
      case 'completed':
      case 'selesai':
        return {
          'requiresProgress': 100.0,
          'requiresEndDate': true,
          'requiresPhotos': true,
        };
      case 'ongoing':
        return {
          'requiresProgress': '>0',
          'requiresStartDate': true,
        };
      case 'cancelled':
        return {
          'requiresNotes': true,
        };
      default:
        return {};
    }
  }
}