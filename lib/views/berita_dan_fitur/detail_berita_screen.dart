import 'package:flutter/material.dart';
import 'package:mobile/views/instansi/generic_info_instansi_screen.dart';
import 'package:mobile/services/opd_service.dart';

class DetailBeritaScreen extends StatelessWidget {
  final String judul;
  final String kategori;
  final String tanggal;
  final String gambar;
  final String? isiBerita;

  const DetailBeritaScreen({
    super.key,
    required this.judul,
    required this.kategori,
    required this.tanggal,
    required this.gambar,
    this.isiBerita,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF123457);
    const Color accentColor = Color(0xFFE8A33D);

    final String kontenDefault = isiBerita ??
        '''Sukabumi — Pemerintah Kota Sukabumi melalui Dinas Komunikasi dan Informatika (Diskominfo) terus berkomitmen menyampaikan informasi publik secara cepat, transparan, dan terpercaya kepada seluruh warga.

Dalam upaya memperkuat transparansi publik dan literasi digital masyarakat, berbagai program unggulan dan inovasi kanal pengaduan masyarakat terpadu terus dikembangkan.

Melalui portal informasi resmi Sukabumi One Access, masyarakat dapat memantau perkembangan berita kota terbaru, menyampaikan saran, serta mengakses seluruh berita kegiatan dinas dan instansi di lingkungan Kota Sukabumi.''';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Berita',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tautan berita berhasil disalin!'),
                  backgroundColor: primaryColor,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GAMBAR COVER BERITA
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(gambar),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        kategori,
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // JUDUL BERITA
                  Text(
                    judul,
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // TANGGAL & PENERBIT
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        tanggal,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.verified_rounded, size: 14, color: primaryColor),
                      const SizedBox(width: 4),
                      const Text(
                        'Diskominfo Sukabumi',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(thickness: 1),
                  ),

                  // KONTEN ARTIKEL BERITA
                  Text(
                    kontenDefault,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 13.5,
                      height: 1.6,
                      fontFamily: 'Poppins',
                    ),
                  ),

                  const SizedBox(height: 30),

                  // KARTU INFORMASI DISKOMINFO
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.computer_rounded, color: accentColor, size: 24),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Dinas Komunikasi & Informatika',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Ingin mengetahui program, layanan pengaduan, atau informasi publik Diskominfo lainnya?',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              final diskominfo = OpdService().getInstansiByKode('diskominfo');
                              if (diskominfo != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => GenericInfoInstansiScreen(instansi: diskominfo)),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Lihat Profil & Layanan Diskominfo',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
