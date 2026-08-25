import 'package:flutter/material.dart';
import 'package:mobile/views/layanan/generic_layanan_sektor_screen.dart';
import 'package:mobile/views/layanan/form_pengajuan_screen.dart';
import 'package:mobile/services/opd_service.dart';
import 'package:mobile/widgets/smart_image.dart';
import 'package:mobile/widgets/guest_gatekeeper.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final List<Map<String, dynamic>> _faseKehidupan = const [
    {
      'title': 'Keluarga',
      'imagePath': 'assets/icon/keluarga.png',
      'fallbackIcon': Icons.family_restroom_rounded,
      'desc': 'Administrasi Kependudukan, Pernikahan, KK & Akta',
    },
    {
      'title': 'Pendidikan',
      'imagePath': 'assets/icon/pendidikan.png',
      'fallbackIcon': Icons.school_rounded,
      'desc': 'Beasiswa, PPDB, Pendaftaran Sekolah',
    },
    {
      'title': 'Usaha',
      'imagePath': 'assets/icon/usaha.png',
      'fallbackIcon': Icons.store_rounded,
      'desc': 'Izin Usaha, NIB, UMKM Kota Sukabumi',
    },
    {
      'title': 'Lingkungan &\nTempat Tinggal',
      'imagePath': 'assets/icon/lingkungan.png',
      'fallbackIcon': Icons.home_work_rounded,
      'desc': 'PBB, Kebersihan, Izin Bangunan (PBG)',
    },
    {
      'title': 'Kendaraan',
      'imagePath': 'assets/icon/kendaraan.png',
      'fallbackIcon': Icons.directions_car_rounded,
      'desc': 'Pajak Kendaraan, SIM, Uji KIR',
    },
    {
      'title': 'Tanggap\nDarurat',
      'imagePath': 'assets/icon/tanggapdarurat.png',
      'fallbackIcon': Icons.warning_amber_rounded,
      'desc': 'BPBD, Pemadam Kebakaran, Ambulans 112',
    },
    {
      'title': 'Karier',
      'imagePath': 'assets/icon/karier.png',
      'fallbackIcon': Icons.work_rounded,
      'desc': 'Lowongan Kerja, Pelatihan Disnaker',
    },
    {
      'title': 'Kesehatan',
      'imagePath': 'assets/icon/kesehatan.png',
      'fallbackIcon': Icons.local_hospital_rounded,
      'desc': 'BPJS, Puskesmas, Antrean RSUD',
    },
    {
      'title': 'Sosial &\nHukum',
      'imagePath': 'assets/icon/sosialhukum.png',
      'fallbackIcon': Icons.gavel_rounded,
      'desc': 'Bantuan Sosial, Konsultasi Hukum Warga',
    },
    {
      'title': 'Rekreasi',
      'imagePath': 'assets/icon/rekreasi.png',
      'fallbackIcon': Icons.camera_alt_rounded,
      'desc': 'Wisata Kota, Fasilitas Olahraga & Taman',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1E33),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Fase',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ' Kehidupan',
                style: TextStyle(
                  color: Color(0xFFE8A33D),
                  fontSize: 19,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _faseKehidupan.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 14,
            childAspectRatio: 0.80,
          ),
          itemBuilder: (context, index) {
            final item = _faseKehidupan[index];
            final titleStr = (item['title'] as String).replaceAll('\n', ' ');

            return GestureDetector(
              onTap: () {
                GuestGatekeeper.checkAccess(
                  context,
                  onGranted: () {
                    final allSektor = OpdService().getSektorList();
                    final sektor = allSektor.firstWhere(
                      (s) => s.title.toLowerCase().contains(titleStr.toLowerCase().split(' ')[0]),
                      orElse: () => allSektor[index < allSektor.length ? index : 0],
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenericLayananSektorScreen(sektor: sektor),
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1E33),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x30000000),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // KOTAK IKON PUTIH DENGAN OUTLINE EMAS (GOLD BORDER)
                    Container(
                      height: 68,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8A33D), width: 2),
                      ),
                      child: Center(
                        child: SmartImage(
                          imagePath: (item['imagePath'] as String?) ?? '',
                          width: 42,
                          height: 42,
                          fit: BoxFit.contain,
                          fallbackIcon: (item['fallbackIcon'] as IconData?) ?? Icons.category_rounded,
                          fallbackColor: const Color(0xFF0A1E33),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // JUDUL FASE KEHIDUPAN (TEKS PUTIH PRESISI)
                    Expanded(
                      child: Center(
                        child: Text(
                          item['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}