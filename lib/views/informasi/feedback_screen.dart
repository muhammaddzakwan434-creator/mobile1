import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/feedback_model.dart';
import 'package:mobile/models/notification_model.dart';
import 'package:mobile/services/feedback_service.dart';
import 'package:mobile/services/notification_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  
  // State untuk form
  int? _selectedRating;
  String? _selectedFactor;
  final TextEditingController _reasonController = TextEditingController();

  final List<String> _factors = [
    'Kecepatan Layanan',
    'Kemudahan Penggunaan',
    'Kelengkapan Fitur',
    'Desain Antarmuka',
    'Kestabilan Aplikasi'
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submitFeedback() async {
    const Color primaryColor = Color(0xFF0A1E33);
    if (_selectedRating == null || _selectedFactor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua bidang bertanda *'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Simpan ke service
    final newFeedback = FeedbackModel(
      rating: _selectedRating!,
      factor: _selectedFactor!,
      reason: _reasonController.text,
      date: DateTime.now(),
    );

    await _feedbackService.addFeedback(newFeedback);

    // Tambah Notifikasi
    NotificationService().addNotification(
      title: 'Terima kasih telah mengisi kritik dan saran!',
      description: 'Masukan Anda sangat berharga bagi kami untuk terus meningkatkan kualitas layanan Sukabumi One Access.',
      category: NotificationCategory.feedback,
    );

    // Tampilkan Dialog Sukses
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Berhasil!', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Terima kasih! Kritik dan saran Anda telah kami terima.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup Dialog
                // Pindah ke tab riwayat (Tab Index 1) setelah klik OK
                DefaultTabController.of(this.context).animateTo(1);
              },
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
            ),
          ],
        );
      },
    );

    // Reset Form
    setState(() {
      _selectedRating = null;
      _selectedFactor = null;
      _reasonController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A1E33);
    const Color accentColor = Color(0xFFE8A33D);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F8FB),
        appBar: AppBar(
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: accentColor, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
          title: RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: 'Kritik ', style: TextStyle(color: Colors.white)),
                TextSpan(text: 'dan Saran', style: TextStyle(color: accentColor)),
              ],
            ),
          ),
          bottom: const TabBar(
            indicatorColor: accentColor,
            labelColor: accentColor,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Formulir'),
              Tab(text: 'Riwayat'),
            ],
          ),
          elevation: 0,
        ),
        body: TabBarView(
          children: [
            _buildFormTab(primaryColor, accentColor),
            _buildHistoryTab(primaryColor, accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildFormTab(Color primaryColor, Color accentColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Feedback Section
          _buildSectionCard(
            title: 'Feedback Layanan',
            primaryColor: primaryColor,
            accentColor: accentColor,
            children: [
              _buildQuestionText('1. Bagaimana penilaian Anda terhadap aplikasi Sukabumi City One Access? *'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRatingBoxWithLabel(1, 'Sangat Tidak Puas', accentColor),
                  _buildRatingBoxWithLabel(2, 'Tidak Puas', accentColor),
                  _buildRatingBoxWithLabel(3, 'Biasa Aja', accentColor),
                  _buildRatingBoxWithLabel(4, 'Puas', accentColor),
                  _buildRatingBoxWithLabel(5, 'Sangat Puas', accentColor),
                ],
              ),
              const SizedBox(height: 20),
              _buildQuestionText('2. Faktor apa saja yang perlu ditingkatkan? *'),
              const SizedBox(height: 8),
              _buildDropdown(
                hint: 'Pilih faktor yang relevan',
                items: _factors,
                value: _selectedFactor,
                onChanged: (val) => setState(() => _selectedFactor = val),
              ),
              const SizedBox(height: 20),
              _buildQuestionText('3. Mengapa hal tersebut perlu ditingkatkan? (Opsional)'),
              const SizedBox(height: 8),
              _buildTextArea('Masukkan alasan Anda di sini...', _reasonController),
            ],
          ),
          const SizedBox(height: 30),
          
          // Submit Button
          GestureDetector(
            onTap: _submitFeedback,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Kirim Masukan',
                  style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Color primaryColor,
    required Color accentColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(width: 8),
              const Expanded(child: Divider(thickness: 1)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildQuestionText(String text) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
        children: [
          TextSpan(text: text.replaceAll('*', '')),
          if (text.contains('*'))
            const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildRatingBoxWithLabel(int value, String label, Color accentColor) {
    bool isSelected = (_selectedRating ?? 0) >= value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRating = value),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: isSelected ? accentColor : Colors.black12),
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? accentColor.withOpacity(0.1) : Colors.transparent,
              ),
              child: isSelected 
                ? Icon(Icons.star, color: accentColor) 
                : Text('$value', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? accentColor : Colors.grey, 
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint, 
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: const TextStyle(fontSize: 13)),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
      ),
    );
  }

  Widget _buildTextArea(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
      ),
    );
  }

  Widget _buildHistoryTab(Color primaryColor, Color accentColor) {
    final history = _feedbackService.history;

    if (history.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada riwayat masukan.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final String formattedDate = DateFormat('dd MMMM yyyy').format(item.date);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Terkirim',
                      style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Feedback: ${item.factor}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                item.reason.isEmpty ? '(Tanpa alasan detail)' : item.reason,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Rating: ${item.rating}/5',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),

              // TAMPILAN BALASAN ADMIN (JIKA ADA)
              if (item.reply != null && item.reply!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF0A1E33).withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF0A1E33), size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Tanggapan Admin Sukabumi One Access:',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A1E33),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.reply!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontFamily: 'Poppins',
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
