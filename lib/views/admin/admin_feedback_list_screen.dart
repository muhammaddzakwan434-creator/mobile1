// =============================================================================
// FILE: lib/views/admin/admin_feedback_list_screen.dart
// FUNGSI: Panel Kelola Kritik & Saran Khusus Administrator (Data Lintas User)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/feedback_model.dart';
import 'package:mobile/services/feedback_service.dart';

class AdminFeedbackListScreen extends StatefulWidget {
  final bool isEmbedded;
  const AdminFeedbackListScreen({super.key, this.isEmbedded = false});

  @override
  State<AdminFeedbackListScreen> createState() => _AdminFeedbackListScreenState();
}

class _AdminFeedbackListScreenState extends State<AdminFeedbackListScreen> {
  final FeedbackService _feedbackService = FeedbackService();

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A1E33);
    const Color accentColor = Color(0xFFE8A33D);

    if (widget.isEmbedded) {
      return _buildMainContent(primaryColor, accentColor);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.rate_review_rounded, color: accentColor, size: 22),
            SizedBox(width: 10),
            Text(
              'Kelola Kritik & Saran',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
      body: _buildMainContent(primaryColor, accentColor),
    );
  }

  Widget _buildMainContent(Color primaryColor, Color accentColor) {
    return StreamBuilder<List<FeedbackModel>>(
      stream: _feedbackService.getFeedbackStream(),
      builder: (context, snapshot) {
        final feedbackList = snapshot.data ?? [];

        return Column(
          children: [
            // HEADER SUMMARY
            Container(
              padding: const EdgeInsets.all(16),
              color: primaryColor,
              child: Row(
                children: [
                  _buildStatBox('Total Masukan', '${feedbackList.length}', Icons.forum_rounded, accentColor),
                  const SizedBox(width: 10),
                  _buildStatBox(
                    'Rating Rata-rata', 
                    _calculateAverageRating(feedbackList), 
                    Icons.star_rounded, 
                    Colors.amber,
                  ),
                ],
              ),
            ),

            // LIST FEEDBACK DARI SELURUH USER
            Expanded(
              child: snapshot.connectionState == ConnectionState.waiting && feedbackList.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : feedbackList.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: feedbackList.length,
                          itemBuilder: (context, index) {
                            final item = feedbackList[index];
                            return _buildFeedbackCard(item, primaryColor, accentColor);
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  String _calculateAverageRating(List<FeedbackModel> list) {
    if (list.isEmpty) return '0.0';
    double sum = 0;
    for (var f in list) {
      sum += f.rating;
    }
    return (sum / list.length).toStringAsFixed(1);
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins'),
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'Poppins'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(FeedbackModel item, Color primaryColor, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundColor: Color(0xFFF4F7FC),
                    child: Icon(Icons.person, size: 14, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.userId ?? 'Guest User',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(item.date),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < item.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: Colors.amber,
                  size: 18,
                );
              }),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.factor,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.reason.isEmpty ? '(Warga tidak menyertakan alasan detail)' : item.reason,
            style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4, fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Belum ada kritik dan saran yang masuk.', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}
