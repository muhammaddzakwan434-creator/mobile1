// =============================================================================
// FILE: lib/models/admin_user_model.dart
// FUNGSI: Data Model Pengelola Akun Administrator & Superadmin
// =============================================================================

class AdminUserModel {
  final String id;
  final String nama;
  final String username;
  final String email;
  final String nip;
  final String whatsapp;
  final String instansi; // Misal: "SUPERADMIN", "DISDUKCAPIL", "DISKOMINFO", dll.
  final String role; // "Super Admin" atau "Admin OPD"
  final bool isActive;
  final bool isOnline;
  final DateTime createdAt;
  final DateTime? lastSeen; // Waktu terakhir aktif (Presence System)

  AdminUserModel({
    required this.id,
    required this.nama,
    required this.username,
    required this.email,
    required this.nip,
    this.whatsapp = '',
    required this.instansi,
    required this.role,
    this.isActive = true,
    this.isOnline = false,
    required this.createdAt,
    this.lastSeen,
  });

  String get initials {
    if (nama.isEmpty) return 'AD';
    final parts = nama.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nama.substring(0, nama.length >= 2 ? 2 : 1).toUpperCase();
  }

  String get handleTag {
    if (username.isNotEmpty) {
      return '@${username.toUpperCase()} - ${email.toUpperCase()}';
    }
    return '@${email.toUpperCase()}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'username': username,
      'email': email,
      'nip': nip,
      'whatsapp': whatsapp,
      'instansi': instansi,
      'role': role,
      'isActive': isActive,
      'isOnline': isOnline,
      'createdAt': createdAt.toIso8601String(),
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }

  factory AdminUserModel.fromMap(Map<String, dynamic> map) {
    return AdminUserModel(
      id: map['id'] ?? '',
      nama: map['nama'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      nip: map['nip'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      instansi: map['instansi'] ?? 'DISKOMINFO',
      role: map['role'] ?? 'Super Admin',
      isActive: map['isActive'] ?? true,
      isOnline: map['isOnline'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      lastSeen: map['lastSeen'] != null ? DateTime.tryParse(map['lastSeen']) : null,
    );
  }

  AdminUserModel copyWith({
    String? id,
    String? nama,
    String? username,
    String? email,
    String? nip,
    String? whatsapp,
    String? instansi,
    String? role,
    bool? isActive,
    bool? isOnline,
    DateTime? createdAt,
    DateTime? lastSeen,
  }) {
    return AdminUserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      username: username ?? this.username,
      email: email ?? this.email,
      nip: nip ?? this.nip,
      whatsapp: whatsapp ?? this.whatsapp,
      instansi: instansi ?? this.instansi,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
