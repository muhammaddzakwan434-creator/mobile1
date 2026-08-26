// =============================================================================
// FILE: lib/models/feedback_model.dart
// FUNGSI: Data Model Ulasan Kepuasan Masyarakat (SKM)
// PATTERN: Data Transfer Object (DTO)
// =============================================================================

/// Kelas Model Representasi 1 Butir Ulasan / Feedback Kepuasan Warga
class FeedbackModel {
  final String? id;      // ID dari server
  final String? userId;  // ID Pengguna (SOA-XXXXXX)
  final String? userName; // Nama Asli Pengguna
  final int rating;      // Skor Penilaian Bintang (1 - 5)
  final String factor;   // Faktor Utama (Kecepatan, Kemudahan, Keramahan, dll)
  final String reason;   // Ulasan / Alasan Masukan Warga
  final String? reply;   // Tanggapan Resmi Admin
  final DateTime date;   // Tanggal Ulasan Dikirim

  FeedbackModel({
    this.id,
    this.userId,
    this.userName,
    required this.rating,
    required this.factor,
    required this.reason,
    this.reply,
    required this.date,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id']?.toString(),
      userId: json['user_id'],
      userName: json['user_name'],
      rating: json['rating'] ?? 0,
      factor: json['factor'] ?? '',
      reason: json['reason'] ?? '',
      reply: json['reply'],
      date: DateTime.parse(json['created_at'] ?? json['date'] ?? DateTime.now().toString()),
    );
  }
}
