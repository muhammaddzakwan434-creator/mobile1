// =============================================================================
// FILE: lib/views/informasi/help_center_screen.dart
// FUNGSI: Layanan Pusat Bantuan, Live Chatbot AI SOA, & Handoff Live Agent Admin
// PATTERN: Reactive Real-Time StreamBuilder & Asynchronous Message Processing
// LEVEL KODE: Level 2-3 (Sangat Rapi & Terstruktur Untuk Mahasiswa)
// =============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/chat_message_model.dart';
import '../../services/chat_service.dart';
import '../../services/user_service.dart';

/// ----------------------------------------------------------------------------
/// LAYAR PUSAT BANTUAN & LIVE CHAT WARGA (HELP CENTER SCREEN)
/// ----------------------------------------------------------------------------
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();

  // Thread ID Unik Berdasarkan Nama & Nomor Telepon Warga Terlogin
  String get _threadId => 'CHAT-${_userService.currentUser.name}-${_userService.currentUser.phoneNumber}';

  bool _isTyping = false;
  bool _isLiveAgentMode = false; // Mode Handoff Langsung ke Petugas Admin Manusia

  // Data Jawaban FAQ Otomatis untuk AI Bot SOA
  final Map<String, String> _faqResponses = {
    'Bagaimana cara membuat pengaduan?':
        'Untuk membuat pengaduan, Anda bisa masuk ke menu "Layanan" di navigasi bawah, pilih kategori layanan yang sesuai, lalu isi formulir pengaduan dengan lengkap dan unggah foto pendukung jika diperlukan.',
    'Bagaimana cara melihat status pengaduan saya?':
        'Status pengaduan dapat dipantau melalui menu "Log Aktivitas" di halaman profil Anda. Anda akan mendapatkan notifikasi real-time setiap kali ada perubahan status.',
    'Berapa lama pengaduan diproses?':
        'Proses pengaduan dan permohonan layanan biasanya memakan waktu 1-3 hari kerja tergantung pada tingkat kompleksitas masalah dan instansi yang berwenang menanganinya.',
    'Apa saja layanan yang tersedia?':
        'Saat ini tersedia layanan Pengaduan Infrastruktur, Layanan Dukcapil Digital, Informasi Cuaca, Berita Kota Sukabumi, dan Integrasi SSO IKD.',
    'Di mana lokasi kantor pelayanan?':
        'Kantor Pusat Layanan terpadu berada di Balai Kota Sukabumi, Jl. R. Syamsudin, S.H. No.25.',
    'Mengapa pengaduan saya belum ditindaklanjuti?':
        'Mohon pastikan data yang diinput sudah lengkap. Jika sudah lebih dari 3 hari kerja, Anda bisa menggunakan fitur "Hubungi Admin" di detail pengaduan tersebut.',
  };

  @override
  void initState() {
    super.initState();
    _initInitialGreeting();
  }

  // FUNGSI HELPER: Mendapatkan Nama Sapaan Sopan Pengguna
  String _getFriendlyName() {
    final name = _userService.currentUser.name.trim();
    if (name.isEmpty || name.toLowerCase() == 'wa' || name.toLowerCase() == 'warga' || name.length <= 2) {
      return 'Warga Sukabumi';
    }
    return name;
  }

  // FUNGSI 1: Salam Pembuka Otomatis AI Bot SOA Saat Pertama Dibuka
  void _initInitialGreeting() {
    Future.delayed(const Duration(milliseconds: 200), () async {
      final String displayName = _getFriendlyName();
      await _chatService.sendMessage(
        threadId: _threadId,
        text: 'Halo Kak $displayName! 👋 Selamat datang di Pusat Layanan Publik Sukabumi One Access. Saya AI Bot SOA, asisten digital 24 jam Kota Sukabumi. Silakan pilih pertanyaan FAQ di atas atau ketik pesan Anda!',
        sender: MessageSender.bot,
        userName: displayName,
        topic: 'Umum / Pusat Bantuan',
      );
      _scrollToBottom();
    });
  }

  // FUNGSI 2: Penanganan Pengiriman Pesan (User Message & Auto Response Engine)
  void _handleSendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final String displayName = _getFriendlyName();

    _messageController.clear();
    // FocusScope.of(context).unfocus(); // Biarkan keyboard tetap terbuka agar chat lancar

    // Step A: Kirim Pesan Pengguna ke Service (Instan Cloud Sync)
    await _chatService.sendMessage(
      threadId: _threadId,
      text: trimmed,
      sender: MessageSender.user,
      userId: _userService.currentUser.id,
      userName: displayName,
      topic: 'Pusat Bantuan',
    );

    _scrollToBottom();

    final qLower = trimmed.toLowerCase();

    // Step B: Cek Jika Pengguna Meminta Berbicara Dengan Admin Manusia (Handoff Mode)
    if (_isLiveAgentMode || qLower.contains('petugas admin') || qLower.contains('hubungi admin') || qLower.contains('live agent') || qLower.contains('mengobrol langsung')) {
      if (!_isLiveAgentMode) {
        setState(() {
          _isLiveAgentMode = true;
          _isTyping = true;
        });

        Timer(const Duration(milliseconds: 600), () async {
          if (!mounted) return;
          await _chatService.sendMessage(
            threadId: _threadId,
            text: 'Pesan Anda telah dialihkan ke Inbox Live Agent Admin Sukabumi One Access. Petugas admin sedang memproses antrean Anda. Mohon tunggu balasan langsung dari Admin...',
            sender: MessageSender.bot,
          );
          if (mounted) setState(() => _isTyping = false);
          _scrollToBottom();
        });
      }
      // CATATAN MAHASISWA: Jika sudah dalam Mode Live Agent, AI Bot STOP AUTO-REPLY!
      return;
    }

    // Step C: Respon Otomatis AI Bot SOA (Jika Masih Mode Bot)
    if (mounted) setState(() => _isTyping = true);

    Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;

      String reply = 'Terima kasih atas pertanyaan Anda. Petugas Admin SOA telah menerima pesan Anda dan akan segera merespon secara langsung jika diperlukan.';

      // Prioritas 1: Salam & Sapaan Ramah
      if (qLower.contains('halo') || qLower.contains('hai') || qLower.contains('pagi') || qLower.contains('siang') || qLower.contains('sore') || qLower.contains('malam') || qLower.contains('assalamu')) {
        reply = 'Halo Kak $displayName! 👋 Ada yang bisa AI Bot SOA bantu hari ini mengenai layanan publik Kota Sukabumi?';
      }
      // Prioritas 2: Pencocokan FAQ Tepat
      else {
        bool matchedFaq = false;
        for (var entry in _faqResponses.entries) {
          if (entry.key.toLowerCase().trim() == qLower) {
            reply = entry.value;
            matchedFaq = true;
            break;
          }
        }

        // Prioritas 3: Kata Kunci Intent Layanan Publik
        if (!matchedFaq) {
          if (qLower.contains('berapa lama') || qLower.contains('lama diproses') || qLower.contains('durasi')) {
            reply = 'Proses pengaduan dan permohonan layanan biasanya memakan waktu 1-3 hari kerja tergantung tingkat kompleksitas dan OPD terkait.';
          } else if (qLower.contains('ktp') || qLower.contains('dukcapil') || qLower.contains('kk')) {
            reply = 'Untuk permohonan KTP-el atau KK Digital, Anda dapat mengakses menu "Layanan" -> Kategori "Dukcapil" atau datang ke Kantor Disdukcapil Kota Sukabumi.';
          } else if (qLower.contains('pengaduan') || qLower.contains('lapor')) {
            reply = 'Untuk membuat laporan pengaduan, silakan buka menu "Layanan" di navigasi bawah, pilih jenis pengaduan dan unggah bukti foto pendukung.';
          } else if (qLower.contains('izin') || qLower.contains('pbg') || qLower.contains('usaha')) {
            reply = 'Layanan Perizinan PBG & Usaha dikelola oleh DPMPTSP Kota Sukabumi. Anda dapat mengecek alur perizinan di menu Instansi DPMPTSP.';
          }
        }
      }

      await _chatService.sendMessage(
        threadId: _threadId,
        text: reply,
        sender: MessageSender.bot,
      );

      if (mounted) setState(() => _isTyping = false);
      _scrollToBottom();
    });
  }

  // FUNGSI HELPER: Memutar Gulungan Layar Chat ke Pesan Terbawah
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A1E33);
    const Color accentColor = Color(0xFFE8A33D);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. BAR LOGO ATAS
          _buildLogoBar(primaryColor),

          // 2. HEADER CUACA & PROFIL WARGA
          _buildMainHeader(primaryColor, accentColor),

          // 3. BADGE STATUS LIVE AGENT ADMIN (JIKA TERHUBUNG)
          if (_isLiveAgentMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFE2F7E2),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle, color: Color(0xFF2E7D32), size: 10),
                  SizedBox(width: 8),
                  Text(
                    '🟢 Terhubung dengan Live Agent Admin Sukabumi',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  // 4. BANNER HERO PUSAT BANTUAN
                  _buildHeroSection(accentColor),

                  // 5. NAVBAR JUDUL CHAT
                  _buildChatNavBar(context, primaryColor, accentColor),

                  // 6. AREA FAQ & KONTEN OBROLAN
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Kartu Pertanyaan FAQ Interaktif
                        _buildFAQCard(primaryColor),

                        const SizedBox(height: 30),

                        // ALIRAN STREAM REAL-TIME GELEMBUNG PESAN
                        StreamBuilder<List<ChatMessage>>(
                          stream: _chatService.getMessages(_threadId),
                          builder: (context, snapshot) {
                            final messages = snapshot.data ?? [];

                            if (messages.isEmpty) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F2F5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Lanjutkan chat dengan AI Bot SOA...',
                                    style: TextStyle(color: Colors.black87, fontSize: 13, fontFamily: 'Poppins'),
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                return _buildChatBubble(messages[index], accentColor);
                              },
                            );
                          },
                        ),

                        // Indikator Mengetik
                        if (_isTyping)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F2F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF0A1E33)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isLiveAgentMode ? 'Petugas Admin sedang memproses...' : 'AI Bot SOA sedang mengetik...',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'Poppins'),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 7. INPUT BAR PENGIRIMAN PESAN
          _buildInputBar(primaryColor),
        ],
      ),
    );
  }

  Widget _buildLogoBar(Color primaryColor) {
    return Container(
      color: primaryColor,
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 8),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 28,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text('SUKABUMI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Poppins')),
          const Spacer(),
          const Text('KOTA SUKABUMI', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1, fontFamily: 'Poppins')),
        ],
      ),
    );
  }

  Widget _buildMainHeader(Color primaryColor, Color accentColor) {
    final displayName = _getFriendlyName();

    return Container(
      color: primaryColor,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          const Icon(Icons.wb_cloudy_outlined, color: Colors.white70, size: 28),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('28°C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Poppins')),
              Text('Hujan Ringan', style: TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'Poppins')),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins')),
              Text(_userService.currentUser.status, style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            ],
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFE8A33D),
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(Color accentColor) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F2942),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              children: [
                const TextSpan(text: 'Pusat ', style: TextStyle(color: Colors.white)),
                TextSpan(text: 'Bantuan & Live Agent', style: TextStyle(color: accentColor)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Temukan kemudahan mengakses berbagai layanan informasi dari seluruh Instansi Pemerintah Kota Sukabumi dalam satu pintu.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4, fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatNavBar(BuildContext context, Color primaryColor, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: primaryColor, border: Border(bottom: BorderSide(color: accentColor, width: 2))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.chevron_left, color: accentColor, size: 28)),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                  children: [
                    const TextSpan(text: 'Pusat ', style: TextStyle(color: Colors.white)),
                    TextSpan(text: 'Bantuan', style: TextStyle(color: accentColor)),
                  ],
                ),
              ),
            ],
          ),
          Icon(Icons.more_vert, color: accentColor),
        ],
      ),
    );
  }

  Widget _buildFAQCard(Color primaryColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFFE9EEF3), borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ada yang bisa kami bantu?', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Poppins')),
          const SizedBox(height: 12),
          ..._faqResponses.keys.map((question) => _buildFAQItem(question)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _hubungiAdminDirectly,
              icon: const Icon(Icons.headset_mic_rounded, color: Color(0xFFE8A33D), size: 18),
              label: Text(
                _isLiveAgentMode ? '🟢 Terhubung Dengan Live Agent Admin' : '💬 Hubungi Petugas Admin (Live Agent)',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLiveAgentMode ? const Color(0xFF2E7D32) : const Color(0xFF0A1E33),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _hubungiAdminDirectly() {
    _handleSendMessage('Saya ingin mengobrol langsung dengan Petugas Admin.');
  }

  Widget _buildFAQItem(String text) {
    return InkWell(
      onTap: () => _handleSendMessage(text),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(color: Color(0xFF3B5B80), fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF3B5B80), size: 18),
              ],
            ),
          ),
          const Divider(color: Colors.white, height: 1, thickness: 1.5),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message, Color accentColor) {
    bool isUser = message.sender == MessageSender.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? accentColor : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 13, fontFamily: 'Poppins'),
        ),
      ),
    );
  }

  Widget _buildInputBar(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Icon(
                    _isLiveAgentMode ? Icons.headset_mic_rounded : Icons.chat_bubble_outline_rounded,
                    color: _isLiveAgentMode ? const Color(0xFF2E7D32) : const Color(0xFF0A1E33),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: _handleSendMessage,
                      style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                      decoration: InputDecoration(
                        hintText: _isLiveAgentMode ? 'Kirim pesan langsung ke Petugas Admin...' : 'Tulis pesan atau pertanyaan Anda...',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12.5, fontFamily: 'Poppins'),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _isLiveAgentMode ? const Color(0xFF2E7D32) : const Color(0xFF0A1E33),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: () => _handleSendMessage(_messageController.text),
              tooltip: 'Kirim Pesan',
            ),
          ),
        ],
      ),
    );
  }
}
