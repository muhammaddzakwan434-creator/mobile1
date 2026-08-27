// =============================================================================
// FILE: lib/models/user_model.dart
// FUNGSI: Data Model Profil Akun Pengguna Warga / Admin
// PATTERN: Data Model dengan copyWith() untuk Immutable State Updating
// =============================================================================

/// Kelas Model Representasi Profil Pengguna Aplikasi Sukabumi One Access
class UserModel {
  String id;               // ID Unik Pengguna
  String name;             // Nama Lengkap Pengguna
  String email;            // Alamat Email Resmi
  String username;         // Username / NIK / NIP Pengguna
  String phoneNumber;      // Nomor Telepon / WhatsApp
  String status;           // Status Verifikasi (Terverifikasi SSO, Google, Email)
  String joinedDate;       // Tanggal Bergabung
  String profileImagePath; // Jalur Foto Profil Avatar Pengguna

  UserModel({
    required this.name,
    required this.email,
    required this.username,
    required this.phoneNumber,
    required this.status,
    required this.joinedDate,
    required this.id,
    this.profileImagePath = '',
  });

  // FUNGSI: Salinan Model dengan Parameter Diperbarui (Immutable State Updating)
  UserModel copyWith({
    String? name,
    String? email,
    String? username,
    String? phoneNumber,
    String? status,
    String? joinedDate,
    String? id,
    String? profileImagePath,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      joinedDate: joinedDate ?? this.joinedDate,
      id: id ?? this.id,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
