// lib/services/location_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      accuracy: json['accuracy']?.toDouble(),
      altitude: json['altitude']?.toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  @override
  String toString() {
    return '$latitude, $longitude';
  }

  String toDetailedString() {
    return 'Lat: $latitude\nLng: $longitude\nAkurasi: ${accuracy?.toStringAsFixed(1) ?? 'N/A'}m';
  }
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionStreamSubscription;
  LocationData? _lastKnownLocation;

  // Mendapatkan lokasi saat ini
  Future<LocationData?> getCurrentLocation({
    bool showLoading = true,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceDisabledException(
          'Layanan GPS tidak aktif. Silakan aktifkan GPS terlebih dahulu.'
        );
      }

      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationPermissionDeniedException(
            'Izin akses lokasi ditolak. Silakan berikan izin akses lokasi.'
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationPermissionDeniedException(
          'Izin akses lokasi ditolak secara permanen. Silakan aktifkan di pengaturan aplikasi.'
        );
      }

      // Get current position with high accuracy
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(timeout);

      final locationData = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        timestamp: DateTime.now(),
      );

      _lastKnownLocation = locationData;
      return locationData;

    } on LocationServiceDisabledException catch (e) {
      print('Location service disabled: $e');
      rethrow;
    } on LocationPermissionDeniedException catch (e) {
      print('Location permission denied: $e');
      rethrow;
    } on TimeoutException {
      throw Exception('Timeout: Tidak dapat mendapatkan lokasi dalam waktu yang ditentukan');
    } catch (e) {
      print('Error getting current location: $e');
      throw Exception('Gagal mendapatkan lokasi: $e');
    }
  }

  // Mendapatkan last known location
  LocationData? getLastKnownLocation() {
    return _lastKnownLocation;
  }

  // Start listening to location changes
  Stream<LocationData> getLocationStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
    Duration? timeInterval,
  }) {
    final StreamController<LocationData> controller = StreamController<LocationData>();

    _positionStreamSubscription = Geolocator.getPositionStream().listen(
      (Position position) {
        final locationData = LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          altitude: position.altitude,
          timestamp: DateTime.now(),
        );
        
        _lastKnownLocation = locationData;
        controller.add(locationData);
      },
      onError: (error) {
        controller.addError(error);
      },
    );

    return controller.stream;
  }

  // Stop listening to location changes
  void stopLocationStream() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  // Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      print('Error opening location settings: $e');
    }
  }

  // Open app settings
  Future<void> openAppSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (e) {
      print('Error opening app settings: $e');
    }
  }

  // Calculate distance between two coordinates
  double calculateDistance(LocationData from, LocationData to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  // Validate coordinates
  bool isValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 && 
           latitude <= 90 && 
           longitude >= -180 && 
           longitude <= 180 &&
           latitude != 0.0 &&
           longitude != 0.0;
  }

  // Format coordinates for display
  String formatCoordinates(LocationData location, {int decimals = 6}) {
    return '${location.latitude.toStringAsFixed(decimals)}, ${location.longitude.toStringAsFixed(decimals)}';
  }

  // Get accuracy description
  String getAccuracyDescription(double? accuracy) {
    if (accuracy == null) return 'Tidak diketahui';
    
    if (accuracy <= 5) return 'Sangat Akurat';
    if (accuracy <= 10) return 'Akurat';
    if (accuracy <= 20) return 'Cukup Akurat';
    if (accuracy <= 50) return 'Kurang Akurat';
    return 'Tidak Akurat';
  }

  // Show location dialog
  Future<LocationData?> showLocationDialog(BuildContext context) async {
    LocationData? selectedLocation;
    bool isLoading = false;
    String? errorMessage;

    return await showDialog<LocationData>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.my_location, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('Ambil Lokasi GPS'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading) ...[
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Mencari lokasi GPS...'),
                      SizedBox(height: 8),
                      Text(
                        'Pastikan GPS aktif dan Anda berada di area terbuka',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else if (errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (selectedLocation != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            'Lokasi berhasil didapatkan',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Latitude: ${selectedLocation!.latitude.toStringAsFixed(6)}'),
                      Text('Longitude: ${selectedLocation!.longitude.toStringAsFixed(6)}'),
                      if (selectedLocation!.accuracy != null)
                        Text('Akurasi: ±${selectedLocation!.accuracy!.toStringAsFixed(1)}m'),
                    ],
                  ),
                ),
              ] else ...[
                const Text(
                  'Tekan tombol di bawah untuk mengambil koordinat GPS saat ini.',
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pastikan GPS aktif dan Anda berada di lokasi yang ingin dicatat',
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            if (!isLoading && errorMessage != null)
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  
                  try {
                    final location = await getCurrentLocation();
                    setState(() {
                      selectedLocation = location;
                      isLoading = false;
                    });
                  } catch (e) {
                    setState(() {
                      errorMessage = e.toString();
                      isLoading = false;
                    });
                  }
                },
                child: const Text('Coba Lagi'),
              )
            else if (!isLoading && selectedLocation == null)
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  
                  try {
                    final location = await getCurrentLocation();
                    setState(() {
                      selectedLocation = location;
                      isLoading = false;
                    });
                  } catch (e) {
                    setState(() {
                      errorMessage = e.toString();
                      isLoading = false;
                    });
                  }
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.gps_fixed, size: 16),
                    SizedBox(width: 4),
                    Text('Ambil Lokasi'),
                  ],
                ),
              )
            else if (selectedLocation != null)
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selectedLocation),
                child: const Text('Gunakan Lokasi'),
              ),
          ],
        ),
      ),
    );
  }

  // Clean up resources
  void dispose() {
    stopLocationStream();
  }
}

// Custom exceptions
class LocationServiceDisabledException implements Exception {
  final String message;
  LocationServiceDisabledException(this.message);
  
  @override
  String toString() => message;
}

class LocationPermissionDeniedException implements Exception {
  final String message;
  LocationPermissionDeniedException(this.message);
  
  @override
  String toString() => message;
}