import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/temuan.dart';
import '../model/perbaikan.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = AppConstants.baseUrl;

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // Add authorization header if needed
    // 'Authorization': 'Bearer $token',
  };

  // Generic GET request
  Future<Map<String, dynamic>> _get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> _put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic DELETE request
  Future<void> _delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Temuan API methods
  Future<List<Temuan>> getTemuanList() async {
    try {
      final response = await _get(AppConstants.temuanEndpoint);
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Temuan.fromJson(json)).toList();
    } catch (e) {
      // Return mock data for development
      return _getMockTemuanData();
    }
  }

  Future<Temuan> getTemuanById(String id) async {
    try {
      final response = await _get('${AppConstants.temuanEndpoint}/$id');
      return Temuan.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to get temuan: $e');
    }
  }

  Future<Temuan> createTemuan(Map<String, dynamic> temuanData) async {
    try {
      final response = await _post(AppConstants.temuanEndpoint, temuanData);
      return Temuan.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to create temuan: $e');
    }
  }

  Future<Temuan> updateTemuan(String id, Map<String, dynamic> temuanData) async {
    try {
      final response = await _put('${AppConstants.temuanEndpoint}/$id', temuanData);
      return Temuan.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to update temuan: $e');
    }
  }

  Future<void> deleteTemuan(String id) async {
    try {
      await _delete('${AppConstants.temuanEndpoint}/$id');
    } catch (e) {
      throw Exception('Failed to delete temuan: $e');
    }
  }

  // Perbaikan API methods
  Future<List<Perbaikan>> getPerbaikanList() async {
    try {
      final response = await _get(AppConstants.perbaikanEndpoint);
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Perbaikan.fromJson(json)).toList();
    } catch (e) {
      // Return mock data for development
      return _getMockPerbaikanData();
    }
  }

  Future<Perbaikan> getPerbaikanById(String id) async {
    try {
      final response = await _get('${AppConstants.perbaikanEndpoint}/$id');
      return Perbaikan.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to get perbaikan: $e');
    }
  }

  Future<Perbaikan> createPerbaikan(Map<String, dynamic> perbaikanData) async {
    try {
      final response = await _post(AppConstants.perbaikanEndpoint, perbaikanData);
      return Perbaikan.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to create perbaikan: $e');
    }
  }

  Future<Perbaikan> updatePerbaikan(String id, Map<String, dynamic> perbaikanData) async {
    try {
      final response = await _put('${AppConstants.perbaikanEndpoint}/$id', perbaikanData);
      return Perbaikan.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to update perbaikan: $e');
    }
  }

  Future<void> deletePerbaikan(String id) async {
    try {
      await _delete('${AppConstants.perbaikanEndpoint}/$id');
    } catch (e) {
      throw Exception('Failed to delete perbaikan: $e');
    }
  }

  // Mock data for development
  List<Temuan> _getMockTemuanData() {
    return [
      Temuan(
        id: 'T001',
        category: 'jalan',
        subcategory: 'lubang',
        section: 'A',
        kmPoint: '12+300',
        lane: 'Lajur 1',
        description: 'Lubang di jalan tol',
        priority: 'high',
        status: 'pending',
        latitude: -6.2088,
        longitude: 106.8456,
        photos: [],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        createdBy: 'Petugas A',
        notes: 'Lubang cukup dalam',
      ),
      Temuan(
        id: 'T002',
        category: 'jembatan',
        subcategory: 'kerusakan',
        section: 'B',
        kmPoint: '15+500',
        lane: 'Lajur 2',
        description: 'Kerusakan pada jembatan',
        priority: 'critical',
        status: 'in_progress',
        latitude: -6.2088,
        longitude: 106.8456,
        photos: [],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        createdBy: 'Petugas B',
        notes: 'Perlu perbaikan segera',
      ),
    ];
  }

  List<Perbaikan> _getMockPerbaikanData() {
    return [
      Perbaikan(
        id: '1',
        temuanId: 'T001',
        category: 'jalan',
        subcategory: 'lubang',
        section: 'A',
        kmPoint: '12+300',
        lane: 'Lajur 1',
        workDescription: 'Perbaikan lubang di jalan tol',
        contractor: 'PT Jaya Konstruksi',
        status: 'in_progress',
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: null,
        progress: 60.0,
        beforePhotos: [],
        progressPhotos: [],
        afterPhotos: [],
        assignedTo: 'Tim Perbaikan A',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        createdBy: 'admin',
        notes: 'Pengerjaan sedang berlangsung',
        cost: 5000000.0,
      ),
      Perbaikan(
        id: '2',
        temuanId: 'T002',
        category: 'jembatan',
        subcategory: 'kerusakan',
        section: 'B',
        kmPoint: '15+500',
        lane: 'Lajur 2',
        workDescription: 'Perbaikan kerusakan pada jembatan',
        contractor: 'PT Bangun Jaya',
        status: 'pending',
        startDate: DateTime.now(),
        endDate: null,
        progress: 0.0,
        beforePhotos: [],
        progressPhotos: [],
        afterPhotos: [],
        assignedTo: 'Tim Perbaikan B',
        createdAt: DateTime.now(),
        createdBy: 'admin',
        notes: 'Menunggu persetujuan',
        cost: 15000000.0,
      ),
    ];
  }
} 