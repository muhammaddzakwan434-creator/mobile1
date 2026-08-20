// =============================================================================
// FILE: lib/services/admin_management_service.dart
// FUNGSI: Service Master Pengelola Data Administrator (SuperAdmin & Admin OPD)
// PATTERN: Singleton Pattern & Reactive State Management (Cloud Firestore Engine)
// =============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_user_model.dart';
import 'api_service.dart';

class AdminManagementService extends ChangeNotifier {
  static final AdminManagementService _instance = AdminManagementService._internal();
  factory AdminManagementService() => _instance;

  AdminManagementService._internal() {
    _listenToAdminChanges();
    _seedSakalangitIfEmpty();
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<AdminUserModel> _adminList = [];

  List<AdminUserModel> get adminList => List.unmodifiable(_adminList);

  /// --------------------------------------------------------------------------
  /// FUNGSI 0: Registrasi Sakalangit (Safety Protocol)
  /// --------------------------------------------------------------------------
  Future<void> _seedSakalangitIfEmpty() async {
    try {
      // Pastikan Sakalangit selalu terdaftar sebagai akses darurat
      final sakalangit = AdminUserModel(
        id: 'adm-saka',
        nama: 'Sakalangit Super Admin',
        username: 'superadmin',
        email: 'sakalangit112@gmail.com',
        nip: '19950810 202203 1 001',
        whatsapp: '081234567891',
        instansi: 'SUPERADMIN',
        role: 'Super Admin',
        isActive: true,
        isOnline: false,
        createdAt: DateTime(2026, 8, 20),
      );
      
      // Update atau buat baru (Upsert)
      await _db.collection('admin_users').doc(sakalangit.id).set(
        sakalangit.toMap(), 
        SetOptions(merge: true)
      );
    } catch (e) {
      debugPrint('Safety Seeding error: $e');
    }
  }

  /// --------------------------------------------------------------------------
  /// FUNGSI 1: Sensor Real-Time Firestore (Single Source of Truth)
  /// --------------------------------------------------------------------------
  void _listenToAdminChanges() {
    _db.collection('admin_users').snapshots().listen((snapshot) {
      _adminList.clear();
      for (var doc in snapshot.docs) {
        _adminList.add(AdminUserModel.fromMap(doc.data()));
      }
      // Urutkan berdasarkan waktu pembuatan
      _adminList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      notifyListeners();
    }, onError: (e) {
      debugPrint('Firestore Admin Listener Error: $e');
    });
  }

  /// --------------------------------------------------------------------------
  /// FUNGSI 2: Update Sinyal Kehadiran (Presence Heartbeat)
  /// --------------------------------------------------------------------------
  Future<void> updateAdminHeartbeat(String adminId) async {
    try {
      await _db.collection('admin_users').doc(adminId).update({
        'lastSeen': DateTime.now().toIso8601String(),
        'isOnline': true,
      });
    } catch (e) {
      debugPrint('Heartbeat update error: $e');
    }
  }

  /// --------------------------------------------------------------------------
  /// FUNGSI 3: Paksa Status Offline (Saat Logout)
  /// --------------------------------------------------------------------------
  Future<void> setAdminOffline(String adminId) async {
    try {
      await _db.collection('admin_users').doc(adminId).update({
        'isOnline': false,
      });
    } catch (e) {
      debugPrint('Set offline error: $e');
    }
  }

  /// --------------------------------------------------------------------------
  /// FUNGSI 4: Operasi CRUD Admin (Semua Sinkron ke Cloud)
  /// --------------------------------------------------------------------------
  Future<void> addAdmin(AdminUserModel newAdmin) async {
    try {
      await _db.collection('admin_users').doc(newAdmin.id).set(newAdmin.toMap());
    } catch (e) {
      debugPrint('Add admin cloud error: $e');
    }
  }

  Future<void> updateAdmin(AdminUserModel updated) async {
    try {
      await _db.collection('admin_users').doc(updated.id).update(updated.toMap());
    } catch (e) {
      debugPrint('Update admin cloud error: $e');
    }
  }

  Future<void> deleteAdmin(String id) async {
    try {
      // 1. Dapatkan data admin sebelum dihapus (untuk ambil email)
      final doc = await _db.collection('admin_users').doc(id).get();
      final String targetEmail = doc.data()?['email'] ?? '';

      // 2. Hapus dari Firestore
      await _db.collection('admin_users').doc(id).delete();

      // 3. SINKRONISASI: Hapus dari Database MySQL (Laptop) via API Laravel
      if (targetEmail.isNotEmpty) {
        await ApiService.delete('admin/delete?email=$targetEmail');
      }
    } catch (e) {
      debugPrint('Delete admin cloud error: $e');
    }
  }

  Future<void> toggleAdminStatus(String id) async {
    try {
      final doc = await _db.collection('admin_users').doc(id).get();
      if (doc.exists) {
        final bool currentStatus = doc.data()?['isActive'] ?? true;
        await _db.collection('admin_users').doc(id).update({
          'isActive': !currentStatus,
        });
      }
    } catch (e) {
      debugPrint('Toggle admin status error: $e');
    }
  }
}
