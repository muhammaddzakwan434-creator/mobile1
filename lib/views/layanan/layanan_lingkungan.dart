import 'package:flutter/material.dart';
import 'package:mobile/views/layanan/detail_layanan_lingkungan.dart';
import 'package:mobile/views/informasi/maintenance_screen.dart';
import 'package:mobile/services/opd_service.dart';
import 'package:mobile/models/layanan_model.dart';
import 'package:mobile/models/sektor_model.dart';

class LayananLingkunganScreen extends StatelessWidget {
  const LayananLingkunganScreen({super.key});

  final List<Map<String, dynamic>> _subLayananLingkungan = const [
    {
      'title': 'Pajak Tanah & Bangunan',
      'desc': 'PBB - Layanan PANTAS BPKPD',
      'icon': Icons.receipt_long_rounded,
      'subjudul': 'Layanan PANTAS – BPKPD',
      'deskripsiTentang':
          'Pajak tahunan yang wajib dibayar oleh pemilik tanah dan/atau bangunan di Kota Sukabumi. Dikenal juga dengan istilah resmi PBB, dikelola melalui sistem SIMPBB.',
      'persyaratan': [
        'Fotocopy KTP Pemilik',
        'Surat Kuasa (apabila bukan dari subjek pajak)',
        'Mengisi formulir SPOP dan LSPOP',
        'Fotocopy Sertifikat Tanah / SKT Tanah',
        'Akta Jual Beli',
        'Surat Penunjukan Kasting',
        'Surat Pengantar dari Kelurahan atau Desa',
        'Fotocopy Izin Mendirikan Bangunan (bila ada bangunan)',
        'Surat Keterangan lainnya sebagai pendukung',
      ],
      'urlPortal': 'https://bpkpd.sukabumikota.go.id',
    },
    {
      'title': 'Pajak Jual-Beli Properti',
      'desc': 'BPHTB - Layanan PANTAS BPKPD',
      'icon': Icons.real_estate_agent_rounded,
      'subjudul': 'Layanan PANTAS – BPKPD',
      'deskripsiTentang':
          'Bea Perolehan Hak atas Tanah dan Bangunan (BPHTB) adalah pajak yang dikenakan atas perolehan hak atas tanah dan/atau bangunan di wilayah Kota Sukabumi.',
      'persyaratan': [
        'Fotocopy KTP Pembeli & Penjual',
        'Fotocopy Sertifikat Tanah',
        'Fotocopy SPPT PBB Tahun Berjalan',
        'Surat Setoran Bukan Pajak (SSBP)',
        'Akta Jual Beli / Hibah / Waris',
      ],
      'urlPortal': 'https://bpkpd.sukabumikota.go.id',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF123457),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'LINGKUNGAN & TEMPAT TINGGAL',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER HERO LINGKUNGAN (SAMA PERSIS DENGAN KELUARGA & USAHA)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              color: const Color(0xFF123457),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFAC33), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.home_work_rounded,
                      color: Color(0xFF123457),
                      size: 38,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LINGKUNGAN & TEMPAT TINGGAL',
                          style: TextStyle(
                            color: Color(0xFFFFAC33),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Pajak PBB, BPHTB, Perizinan Bangunan (PBG), Kebersihan & Lingkungan BPKPD',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Layanan Lingkungan & Tempat Tinggal',
                    style: TextStyle(
                      color: Color(0xFF123457),
                      fontSize: 16.5,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Setiap pengajuan dan cek tagihan pajak diproses secara online terintegrasi PANTAS BPKPD.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 14),

                  // GRID SUB-LAYANAN LINGKUNGAN (DYNAMIC & REAL-TIME)
                  ListenableBuilder(
                    listenable: OpdService(),
                    builder: (context, _) {
                      final allLayanan = OpdService().getLayananBySektor('Lingkungan & Tempat Tinggal');
                      final instansi = OpdService().getInstansiByKode('bpkpd');
                      final sektor = OpdService().getSektorList().firstWhere(
                            (s) => s.title.toLowerCase().contains('lingkungan'),
                            orElse: () => SektorModel(id: '', title: '', imagePath: '', desc: '', iconName: ''),
                          );

                      if (allLayanan.isEmpty) {
                        return const Center(child: Text('Belum ada layanan tersedia di sektor ini.'));
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allLayanan.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.88,
                        ),
                        itemBuilder: (context, index) {
                          final item = allLayanan[index];
                          // CEK 3 LAPIS: Sektor, Instansi, atau Layanan spesifik
                          final bool isMaintenance = !sektor.isActive || 
                                                     (instansi != null && !instansi.isActive) || 
                                                     !item.isActive;

                          // Map icon name string to IconData
                          IconData displayIcon = Icons.home_work_rounded;
                          if (item.iconName == 'receipt_long_outlined') displayIcon = Icons.receipt_long_rounded;
                          if (item.iconName == 'real_estate_agent_outlined') displayIcon = Icons.real_estate_agent_rounded;
                          if (item.iconName == 'home_work_outlined') displayIcon = Icons.home_work_rounded;
                          if (item.iconName == 'print_outlined') displayIcon = Icons.print_rounded;

                          return GestureDetector(
                            onTap: () {
                              if (isMaintenance) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MaintenanceScreen(
                                      title: item.rawTitle,
                                      category: 'Sektor Lingkungan & BPKPD',
                                    ),
                                  ),
                                );
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailLayananLingkunganScreen(
                                    judulLayanan: item.rawTitle,
                                    subjudul: item.subjudul,
                                    deskripsiTentang: item.deskripsi,
                                    persyaratan: item.persyaratan,
                                    urlMitra: item.urlPortal,
                                  ),
                                ),
                              );
                            },
                            child: ColorFiltered(
                              colorFilter: isMaintenance 
                                ? const ColorFilter.mode(Colors.grey, BlendMode.saturation) 
                                : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF123457), width: 1.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x20000000),
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      children: [
                                        // BAGIAN ATAS (NAVY DENGAN IKON EMAS)
                                        Expanded(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF123457),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                              ),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                displayIcon,
                                                color: const Color(0xFFE8A33D),
                                                size: 44,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // BAGIAN BAWAH (ABU-ABU SILVER DENGAN TINGGI PRESISI 64PX)
                                        Container(
                                          width: double.infinity,
                                          height: 64,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFD9D9D9),
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                item.rawTitle,
                                                style: const TextStyle(
                                                  color: Color(0xFF123457),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Poppins',
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item.subjudul,
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 10,
                                                  fontFamily: 'Poppins',
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isMaintenance)
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: Icon(Icons.build_circle_rounded, color: Colors.red.shade700, size: 16),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // CATATAN PENTING CONTAINER
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF123457),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: Color(0xFFE8A33D), size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Setiap tagihan PBB & BPHTB dapat dipantau status pelunasannya secara online.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
