import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/models/user_model.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  
  factory UserService() {
    return _instance;
  }

  UserService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  UserModel _currentUser = UserModel(
    name: 'Tamu Sukabumi',
    email: 'guest@sukabumi.go.id',
    username: 'Guest',
    phoneNumber: '-',
    status: 'Mode Tamu (Belum Login)',
    joinedDate: '-',
    id: 'GUEST-001',
    profileImagePath: '',
  );

  UserModel get currentUser => _currentUser;

  // Daftar akun terdaftar (Database User Real)
  final List<Map<String, String>> _registeredUsers = [];

  /// --------------------------------------------------------------------------
  /// FUNGSI 1: Sinkronisasi Profil Warga ke Cloud Firestore
  /// --------------------------------------------------------------------------
  Future<void> _syncUserToCloud(UserModel user) async {
    try {
      await _db.collection('warga').doc(user.id).set({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'username': user.username,
        'phone': user.phoneNumber,
        'status': user.status,
        'joinedDate': user.joinedDate,
        'profileImagePath': user.profileImagePath,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore User Sync Error: $e');
    }
  }

  /// --------------------------------------------------------------------------
  /// FUNGSI 2: Aliran Data Warga Real-Time untuk Admin
  /// --------------------------------------------------------------------------
  Stream<List<Map<String, String>>> getWargaStream() {
    return _db.collection('warga').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': data['id']?.toString() ?? doc.id,
          'nama': data['name']?.toString() ?? 'Warga',
          'email': data['email']?.toString() ?? '-',
          'phone': data['phone']?.toString() ?? '-',
          'status': data['status']?.toString() ?? 'ACTIVE',
          'joined_date': data['joinedDate']?.toString() ?? '18 Agt 2026',
        };
      }).toList();
    });
  }

  Future<void> init() async {
    await _loadFromLocal();
    await fetchWargaFromApi();
    await cleanupDuplicateUsers();
  }

  Future<void> fetchWargaFromApi() async {
    try {
      final response = await ApiService.get('warga');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          _registeredUsers.clear();
          for (var item in data) {
            _registeredUsers.add({
              'id': 'SOA-${item['id'] ?? 1000}',
              'nama': item['name'] ?? item['nama'] ?? 'Warga',
              'name': item['name'] ?? item['nama'] ?? 'Warga',
              'email': item['email'] ?? '-',
              'phone': item['phone'] ?? '-',
              'nik': item['nik'] ?? '-',
              'status': item['status'] ?? 'ACTIVE',
              'kecamatan': item['kecamatan'] ?? 'Cikole',
              'joined_date': item['created_at'] != null ? item['created_at'].toString().split('T').first : '18 Agt 2026',
            });
          }
          await _saveRegisteredUsersToLocal();
        }
      }
    } catch (e) {
      // Safe fallback ke storage lokal
    }
  }

  // Load data dari Shared Preferences saat aplikasi dibuka
  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    // Load registered users jika ada
    final String? regUsersJson = prefs.getString('registered_users_db');
    if (regUsersJson != null) {
      final List<dynamic> list = jsonDecode(regUsersJson);
      _registeredUsers.clear();
      for (var item in list) {
        _registeredUsers.add(Map<String, String>.from(item));
      }
    }

    final String? userJson = prefs.getString('user_profile');
    if (userJson != null && _isLoggedIn) {
      final Map<String, dynamic> data = jsonDecode(userJson);
      _currentUser = UserModel(
        name: data['name'] ?? 'Warga Sukabumi',
        email: data['email'] ?? '-',
        username: data['username'] ?? 'User',
        phoneNumber: data['phone'] ?? '-',
        status: data['status'] ?? 'Terverifikasi Akun Warga',
        joinedDate: data['joined_date'] ?? '-',
        id: data['user_id'] ?? _generateConsistentId(data['email'] ?? '-'),
        profileImagePath: data['profile_photo'] ?? data['profile_image_path'] ?? '',
      );
    } else {
      _setGuestMode();
    }
  }

  void _setGuestMode() {
    _isLoggedIn = false;
    _currentUser = UserModel(
      name: 'Tamu Sukabumi',
      email: 'guest@sukabumi.go.id',
      username: 'Guest',
      phoneNumber: '-',
      status: 'Mode Tamu (Belum Login)',
      joinedDate: 'Hari ini',
      id: 'GUEST-001',
      profileImagePath: '',
    );
  }

  // AUTENTIKASI USER: Memeriksa apakah username/email dan password terdaftar
  Future<bool> authenticateAccount(String usernameOrEmail, String password) async {
    final input = usernameOrEmail.trim().toLowerCase();
    final pass = password.trim();

    final found = _registeredUsers.firstWhere(
      (user) {
        final uname = user['usernameOrEmail'] ?? '';
        final email = user['email'] ?? '';
        final nikPhone = user['nikOrPhone'] ?? '';
        return (uname.toLowerCase() == input ||
                email.toLowerCase() == input ||
                nikPhone == input) &&
               user['password'] == pass;
      },
      orElse: () => {},
    );

    if (found.isNotEmpty) {
      _isLoggedIn = true;
      final now = DateTime.now();
      final String dateStr = "${now.day} ${_getBulan(now.month)} ${now.year}";

      _currentUser = UserModel(
        name: found['name'] ?? 'Warga Terdaftar',
        email: found['email'] ?? input,
        username: found['nikOrPhone'] ?? input,
        phoneNumber: found['nikOrPhone'] ?? '-',
        status: 'Terverifikasi (Akun Warga)',
        joinedDate: dateStr,
        id: _generateConsistentId(found['email'] ?? input),
        profileImagePath: '',
      );

      await _saveToLocal(_currentUser);
      return true;
    }

    return false;
  }

  // TAHAP 1: KIRIM OTP UNTUK PENDAFTARAN (TANPA BUAT AKUN DULU)
  Future<bool> sendRegistrationOtp(String email) async {
    try {
      final response = await ApiService.post('auth/otp/email/send', {
        'email': email,
        'type': 'registration',
      });
      return response.statusCode == 200;
    } catch (e) {
      print("Send OTP error: $e");
      return false;
    }
  }

  // TAHAP 2: REGISTRASI USER BARU (REAL FIREBASE) SETELAH OTP SUKSES
  Future<bool> registerAccount({
    required String name,
    required String email,
    required String password,
    String? nikOrPhone,
  }) async {
    try {
      // 1. Create account in Firebase
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // Update display name in Firebase
        await firebaseUser.updateDisplayName(name);

        final now = DateTime.now();
        final String dateStr = "${now.day} ${_getBulan(now.month)} ${now.year}";

        _currentUser = UserModel(
          name: name.trim(),
          email: email.trim().toLowerCase(),
          username: (nikOrPhone ?? email).split('@').first,
          phoneNumber: nikOrPhone ?? '-',
          status: 'Terverifikasi Akun Warga',
          joinedDate: dateStr,
          id: _generateConsistentId(email.trim().toLowerCase()),
          profileImagePath: '',
        );

        await _saveToLocal(_currentUser);
        
        return true;
      }
    } catch (e) {
      print("Registration error: $e");
      rethrow;
    }
    return false;
  }

  // LOGIN USER (REAL FIREBASE)
  Future<bool> loginWithEmailPassword(String email, String password) async {
    try {
      // 1. Sign in with Firebase
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final now = DateTime.now();
        final String dateStr = "${now.day} ${_getBulan(now.month)} ${now.year}";

        _currentUser = UserModel(
          name: firebaseUser.displayName ?? 'Warga Sukabumi',
          email: firebaseUser.email ?? email,
          username: (firebaseUser.email ?? email).split('@').first,
          phoneNumber: '-',
          status: 'Menunggu Verifikasi OTP',
          joinedDate: dateStr,
          id: _generateConsistentId(firebaseUser.email ?? email),
          profileImagePath: firebaseUser.photoURL ?? '',
        );

        await _saveToLocal(_currentUser);

        // 2. Trigger OTP sending via Laravel
        await ApiService.post('auth/otp/email/send', {'email': email});
        
        return true;
      }
    } catch (e) {
      print("Login error: $e");
      rethrow;
    }
    return false;
  }

  // FINALIZE LOGIN AFTER OTP
  Future<void> finalizeLogin() async {
    _isLoggedIn = true;
    _currentUser = _currentUser.copyWith(status: 'Terverifikasi (Email + OTP)');
    await _saveToLocal(_currentUser);
  }

  // LOGIN VIA GOOGLE OAUTH (REAL FIREBASE INTEGRATION)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // Web flow: Use popup to avoid native dependency issues
        userCredential = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        // Mobile flow: Use google_sign_in plugin with Explicit Server Client ID (Fixes Code 10)
        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: '709678945324-h7aogudlfhcotkja62g0uihao5fv6dpd.apps.googleusercontent.com',
        );
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null; // User cancelled the sign-in

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }

      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        _isLoggedIn = true;
        final now = DateTime.now();
        final String dateStr = "${now.day} ${_getBulan(now.month)} ${now.year}";

        _currentUser = UserModel(
          name: firebaseUser.displayName ?? 'User Google',
          email: firebaseUser.email ?? '-',
          username: (firebaseUser.email ?? 'user').split('@').first,
          phoneNumber: firebaseUser.phoneNumber ?? '-',
          status: 'Terverifikasi (Google Auth Resmi)',
          joinedDate: dateStr,
          id: _generateConsistentId(firebaseUser.email ?? '-'),
          profileImagePath: firebaseUser.photoURL ?? '',
        );

        await _saveToLocal(_currentUser);
      }

      return userCredential;
    } catch (e) {
      print("Error during Google Sign-In: $e");
      rethrow;
    }
  }

  // LOGIN VIA GOOGLE OAUTH (OLD SIMULATION)
  Future<void> loginWithGoogleAccount(String googleName, String googleEmail) async {
    _isLoggedIn = true;
    final now = DateTime.now();
    final String dateStr = "${now.day} ${_getBulan(now.month)} ${now.year}";

    _currentUser = UserModel(
      name: googleName,
      email: googleEmail,
      username: googleEmail.split('@').first,
      phoneNumber: '-',
      status: 'Terverifikasi (Google OAuth API)',
      joinedDate: dateStr,
      id: _generateConsistentId(googleEmail),
      profileImagePath: '',
    );

    await _saveToLocal(_currentUser);
  }

  // LOGIN DENGAN SSO
  Future<void> loginWithSSO(String ssoUsername) async {
    _isLoggedIn = true;
    final now = DateTime.now();
    final String dateStr = "${now.day} ${_getBulan(now.month)} ${now.year}";

    _currentUser = UserModel(
      name: '$ssoUsername (SSO)',
      email: '$ssoUsername@sukabumikota.go.id',
      username: ssoUsername,
      phoneNumber: '-',
      status: 'Terverifikasi (SSO Identity Provider)',
      joinedDate: dateStr,
      id: _generateConsistentId('$ssoUsername@sukabumikota.go.id'),
      profileImagePath: '',
    );

    await _saveToLocal(_currentUser);
  }

  // MASUK DALAM MODE TAMU
  Future<void> loginAsGuest() async {
    _setGuestMode();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
  }

  // LOGOUT
  Future<void> logout() async {
    _setGuestMode();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
  }

  // FORGOT PASSWORD
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  String _generateConsistentId(String email) {
    if (email == '-' || email.isEmpty) return 'SOA-UNKNOWN';
    
    // Hash sederhana dari email untuk menghasilkan angka 6 digit yang tetap
    int hash = 0;
    for (var i = 0; i < email.length; i++) {
      hash = email.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final int code = 100000 + (hash.abs() % 900000);
    return 'SOA-$code';
  }

  String _getBulan(int mon) {
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return bulan[mon - 1];
  }

  /// --------------------------------------------------------------------------
  /// FUNGSI 3: Pembersihan Data Ganda di Firestore
  /// --------------------------------------------------------------------------
  Future<void> cleanupDuplicateUsers() async {
    try {
      final snapshot = await _db.collection('warga').get();
      final Map<String, List<String>> emailToIds = {};

      for (var doc in snapshot.docs) {
        final email = doc.data()['email']?.toString();
        if (email != null && email != '-') {
          emailToIds.putIfAbsent(email, () => []).add(doc.id);
        }
      }

      for (var entry in emailToIds.entries) {
        final email = entry.key;
        final ids = entry.value;

        if (ids.length > 1) {
          final correctId = _generateConsistentId(email);
          for (var id in ids) {
            if (id != correctId) {
              await _db.collection('warga').doc(id).delete();
              debugPrint('Deleted duplicate user: $id ($email)');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Cleanup Error: $e');
    }
  }

  // Simpan data ke Shared Preferences
  Future<void> _saveToLocal(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', _isLoggedIn);
    final data = {
      'name': user.name,
      'email': user.email,
      'username': user.username,
      'phone': user.phoneNumber,
      'status': user.status,
      'joined_date': user.joinedDate,
      'user_id': user.id,
      'profile_image_path': user.profileImagePath,
    };
    await prefs.setString('user_profile', jsonEncode(data));
    
    // SINKRONISASI KE CLOUD SETIAP KALI SIMPAN LOKAL
    if (_isLoggedIn && user.id != 'GUEST-001') {
      await _syncUserToCloud(user);
    }
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    _currentUser = updatedUser;
    await _saveToLocal(updatedUser);
    return true;
  }

  Future<void> removeProfileImage() async {
    _currentUser = _currentUser.copyWith(profileImagePath: '');
    await _saveToLocal(_currentUser);
  }

  Future<void> _saveRegisteredUsersToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('registered_users_db', jsonEncode(_registeredUsers));
    notifyListeners();
  }

  // Master List Warga Terdaftar (Data Pengguna App)
  List<Map<String, String>> getRegisteredWarga() {
    final List<Map<String, String>> list = [];
    for (int i = 0; i < _registeredUsers.length; i++) {
      final u = _registeredUsers[i];
      list.add({
        'id': u['id'] ?? 'SOA-${1001 + i}',
        'nama': u['name'] ?? u['nama'] ?? 'Warga',
        'email': u['email'] ?? u['usernameOrEmail'] ?? '-',
        'phone': u['phone'] ?? u['nikOrPhone'] ?? '-',
        'status': u['status'] ?? 'ACTIVE',
        'nik': u['nik'] ?? u['nikOrPhone'] ?? '-',
        'kecamatan': u['kecamatan'] ?? 'Cikole',
        'joined_date': u['joined_date'] ?? '18 Agt 2026',
      });
    }
    return list;
  }

  Future<void> addWarga(Map<String, String> data) async {
    final String id = data['id'] ?? 'SOA-${1000 + _registeredUsers.length + 1}';
    final newUser = {
      'id': id,
      'name': data['nama'] ?? data['name'] ?? 'Warga Baru',
      'nama': data['nama'] ?? data['name'] ?? 'Warga Baru',
      'email': data['email'] ?? '',
      'phone': data['phone'] ?? data['nikOrPhone'] ?? '-',
      'nik': data['nik'] ?? data['nikOrPhone'] ?? '-',
      'usernameOrEmail': data['email'] ?? '',
      'nikOrPhone': data['phone'] ?? data['nik'] ?? '-',
      'password': data['password'] ?? 'password123',
      'status': data['status'] ?? 'ACTIVE',
      'kecamatan': data['kecamatan'] ?? 'Cikole',
      'joined_date': data['joined_date'] ?? '18 Agt 2026',
    };
    _registeredUsers.add(newUser);
    await _saveRegisteredUsersToLocal();

    try {
      await ApiService.post('warga', {
        'name': newUser['nama'],
        'email': newUser['email'],
        'phone': newUser['phone'],
      });
    } catch (_) {}
  }

  Future<void> updateWarga(String id, Map<String, String> updatedData) async {
    final index = _registeredUsers.indexWhere((u) => u['id'] == id || u['email'] == id);
    if (index != -1) {
      final current = Map<String, String>.from(_registeredUsers[index]);
      if (updatedData.containsKey('nama')) {
        current['nama'] = updatedData['nama']!;
        current['name'] = updatedData['nama']!;
      }
      if (updatedData.containsKey('name')) {
        current['name'] = updatedData['name']!;
        current['nama'] = updatedData['name']!;
      }
      if (updatedData.containsKey('email')) {
        current['email'] = updatedData['email']!;
        current['usernameOrEmail'] = updatedData['email']!;
      }
      if (updatedData.containsKey('phone')) {
        current['phone'] = updatedData['phone']!;
        current['nikOrPhone'] = updatedData['phone']!;
      }
      if (updatedData.containsKey('nik')) {
        current['nik'] = updatedData['nik']!;
      }
      if (updatedData.containsKey('status')) {
        current['status'] = updatedData['status']!;
      }
      if (updatedData.containsKey('kecamatan')) {
        current['kecamatan'] = updatedData['kecamatan']!;
      }
      
      _registeredUsers[index] = current;
      await _saveRegisteredUsersToLocal();
    }
  }

  Future<void> toggleSuspendWarga(String id) async {
    final index = _registeredUsers.indexWhere((u) => u['id'] == id || u['email'] == id);
    if (index != -1) {
      final currentStatus = _registeredUsers[index]['status'] ?? 'ACTIVE';
      final isCurrentlyActive = (currentStatus == 'ACTIVE' || currentStatus.contains('SSO') || currentStatus == 'TERVERIFIKASI');
      final newStatus = isCurrentlyActive ? 'DITANGGUHKAN' : 'ACTIVE';
      
      _registeredUsers[index]['status'] = newStatus;
      await _saveRegisteredUsersToLocal();

      // 1. SINKRONISASI KE FIRESTORE (Untuk UI Real-time)
      try {
        await _db.collection('warga').doc(id).update({
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Firestore Suspend Sync Error: $e');
      }

      // 2. SINKRONISASI KE BACKEND API (MySQL)
      try {
        await ApiService.patch('warga/$id/toggle-status', {});
      } catch (e) {
        debugPrint('Backend Suspend Sync Error: $e');
      }
    }
  }

  Future<void> deleteWarga(String id) async {
    final target = _registeredUsers.firstWhere(
      (u) => u['id'] == id || u['email'] == id,
      orElse: () => {},
    );
    final targetId = target['id'] ?? id;
    _registeredUsers.removeWhere((u) => u['id'] == id || u['email'] == id);
    await _saveRegisteredUsersToLocal();

    try {
      await ApiService.delete('warga/$targetId');
    } catch (_) {}
  }
}

