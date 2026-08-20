// =============================================================================
// FILE: lib/services/feedback_service.dart
// FUNGSI: Service Pengelola Ulasan & Survei Kepuasan Masyarakat (SKM)
// PATTERN: Singleton Pattern dengan Triple Persistence (Local, SQLite, REST API)
// =============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback_model.dart';
import 'api_service.dart';
import 'user_service.dart';
import 'database_helper.dart';

/// Kelas Service Pengelola Ulasan Feedback Masyarakat
class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // FUNGSI 1: Inisialisasi Service & Memuat Riwayat dari SQLite
  Future<void> init() async {
    await _loadFromDatabase();
  }

  final List<FeedbackModel> _history = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Getter Riwayat Ulasan (Lokal)
  List<FeedbackModel> get history => List.unmodifiable(_history.reversed);

  // FUNGSI UNTUK ADMIN: Mengambil seluruh feedback dari server (Stream Real-Time)
  Stream<List<FeedbackModel>> getFeedbackStream() {
    return _firestore
        .collection('feedback')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FeedbackModel(
          id: doc.id,
          userId: data['user_id'] ?? 'Warga',
          userName: data['user_name'] ?? 'Warga Kota Sukabumi',
          rating: data['rating'] ?? 5,
          factor: data['factor'] ?? 'Umum',
          reason: data['reason'] ?? '',
          date: data['date'] != null 
              ? (data['date'] as Timestamp).toDate() 
              : DateTime.now(),
        );
      }).toList();
    });
  }

  // FUNGSI UNTUK ADMIN: Mengambil seluruh feedback dari server (One-time fetch)
  Future<List<FeedbackModel>> getAllFeedbackFromServer() async {
    try {
      final snapshot = await _firestore
          .collection('feedback')
          .orderBy('date', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FeedbackModel(
          id: doc.id,
          userId: data['user_id'],
          userName: data['user_name'] ?? 'Warga Kota Sukabumi',
          rating: data['rating'] ?? 5,
          factor: data['factor'] ?? 'Umum',
          reason: data['reason'] ?? '',
          date: data['date'] != null 
              ? (data['date'] as Timestamp).toDate() 
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      // Error handling
    }
    return [];
  }

  // FUNGSI 2: Memuat Ulasan Tersimpan dari SQLite
  Future<void> _loadFromDatabase() async {
    final List<Map<String, dynamic>> maps = await _dbHelper.queryAllFeedback();
    _history.clear();
    for (var map in maps) {
      _history.add(FeedbackModel(
        rating: map['rating'],
        factor: map['factor'],
        reason: map['reason'],
        date: DateTime.parse(map['date']),
      ));
    }

    try {
      final response = await ApiService.get('feedback');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          _history.clear();
          for (var item in data) {
            _history.add(FeedbackModel(
              rating: item['rating'] is int ? item['rating'] : int.tryParse('${item['rating']}') ?? 5,
              factor: item['factor'] ?? 'Layanan Publik',
              reason: item['reason'] ?? '',
              date: item['created_at'] != null ? DateTime.tryParse(item['created_at']) ?? DateTime.now() : DateTime.now(),
            ));
          }
        }
      }
    } catch (_) {}
  }

  // FUNGSI 3: Menambahkan Ulasan Baru (Tersimpan ke Memori, SQLite, dan REST API)
  Future<bool> addFeedback(FeedbackModel feedback) async {
    // Step A: Simpan ke Memori Lokal
    _history.add(feedback);

    // Step B: Simpan ke Database Lokal (SQLite)
    await _dbHelper.insert('feedback', {
      'rating': feedback.rating,
      'factor': feedback.factor,
      'reason': feedback.reason,
      'date': feedback.date.toIso8601String(),
    });

    // Step C: Kirim ke Cloud Firestore (Real-Time Sync)
    try {
      final user = UserService().currentUser;
      await _firestore.collection('feedback').add({
        'user_id': user.id,
        'user_name': user.name,
        'rating': feedback.rating,
        'factor': feedback.factor,
        'reason': feedback.reason,
        'date': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore Feedback Sync Error: $e');
    }

    // Step D: Kirim ke Backend REST API Server (MySQL)
    final user = UserService().currentUser;
    final payload = {
      'user_id': user.id,
      'rating': feedback.rating,
      'factor': feedback.factor,
      'reason': feedback.reason,
      'date': feedback.date.toIso8601String(),
    };

    final response = await ApiService.post('feedback', payload);
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
