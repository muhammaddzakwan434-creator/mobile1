import 'package:flutter/material.dart';
import 'package:mobile/views/layanan/detail_layanan_usaha.dart';
import 'package:mobile/views/informasi/maintenance_screen.dart';
import 'package:mobile/services/opd_service.dart';
import 'package:mobile/models/layanan_model.dart';
import 'package:mobile/models/sektor_model.dart';

class LayananUsahaScreen extends StatelessWidget {
  const LayananUsahaScreen({super.key});

  final List<Map<String, dynamic>> _subLayananUsaha = const [
    {
      'title': 'Perizinan Reklame',
      'subjudul': 'Layanan SAKTI – DPMPTSP',
      'icon': Icons.assignment_turned_in_rounded,
      'deskripsiTentang':
          'PBG adalah biaya yang harus dikeluarkan atas keberadaan tanah dan bangunan yang memberi keuntungan dan nilai ekonomi bagi seseorang atau badan. Besaran tarifnya ditentukan dari keadaan objek bumi/bangunan tersebut.',
      'persyaratan': [
        'Fotokopi KTP Pemohon',
        'Jenis Reklame & Desain/Konstruksi',
        'Nomor Induk Berusaha (NIB)',
        'Surat Kuasa (Jika dikuasakan)',
        'Foto Lokasi Penempatan Reklame',
        'Bukti Pelunasan PBB Terakhir',
        'Dokumen Perjanjian Sewa Lahan',
      ],
      'urlPortal': 'https://dpmptsp.sukabumikota.go.id',
    },
    {
      'title': 'Kesehatan Hewan Ternak',
      'subjudul': 'Layanan DKP3 – Peternakan',
      'icon': Icons.pets_rounded,
      'deskripsiTentang':
          'Layanan pemeriksaan kesehatan, surat keterangan kesehatan hewan (SKKH), serta vaksinasi hewan ternak dan hewan peliharaan di Kota Sukabumi.',
      'persyaratan': [
        'Fotokopi KTP Pemilik Hewan',
        'Buku Catatan Kesehatan Hewan',
        'Surat Pengantar dari Desa/Kelurahan',
        'Bukti Vaksinasi Terakhir',
      ],
      'urlPortal': 'https://dkp3.sukabumikota.go.id',
    },
    {
      'title': 'NIB (OSS RBA)',
      'subjudul': 'Nomor Induk Berusaha Perorangan',
      'icon': Icons.storefront_rounded,
      'deskripsiTentang':
          'Penerbitan NIB untuk usahawan perorangan dan UMKM secara mudah dan instan terintegrasi dengan OSS Nasional.',
      'persyaratan': [
        'KTP Pemohon',
        'NPWP Pemohon',
        'Alamat Email & No HP Aktif',
      ],
      'urlPortal': 'https://oss.go.id',
    },
    {
      'title': 'Sertifikasi Halal',
      'subjudul': 'Fasilitasi Sertifikat Halal UMKM',
      'icon': Icons.verified_rounded,
      'deskripsiTentang':
          'Layanan pendampingan proses produk halal (PPH) bagi pelaku usaha makanan dan minuman skala mikro dan kecil di Kota Sukabumi.',
      'persyaratan': [
        'KTP Pemilik Usaha',
        'NIB Terbitan OSS',
        'Daftar Bahan & Komposisi Produk',
      ],
      'urlPortal': 'https://halal.go.id',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF123457);

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
          'USAHA',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListenableBuilder(
          listenable: OpdService(),
          builder: (context, _) {
            final allLayanan = OpdService().getLayananBySektor('Usaha');
            final instansi = OpdService().getInstansiByKode('dpmptsp');
            final sektor = OpdService().getSektorList().firstWhere(
                  (s) => s.title.toLowerCase().contains('usaha'),
                  orElse: () => SektorModel(id: '', title: '', imagePath: '', desc: '', iconName: ''),
                );

            if (allLayanan.isEmpty) {
              return const Center(child: Text('Belum ada layanan tersedia di sektor ini.'));
            }

            return GridView.builder(
              itemCount: allLayanan.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemBuilder: (context, index) {
                final item = allLayanan[index];
                // CEK 3 LAPIS: Sektor, Instansi, atau Layanan spesifik
                final bool isMaintenance = !sektor.isActive || 
                                           (instansi != null && !instansi.isActive) || 
                                           !item.isActive;

                // Map icon name string to IconData
                IconData displayIcon = Icons.storefront_rounded;
                if (item.iconName == 'store_rounded') displayIcon = Icons.storefront_rounded;
                if (item.iconName == 'assignment_outlined') displayIcon = Icons.assignment_turned_in_rounded;
                if (item.iconName == 'pets_outlined') displayIcon = Icons.pets_rounded;
                if (item.iconName == 'grass_outlined') displayIcon = Icons.grass_rounded;

                return GestureDetector(
                  onTap: () {
                    if (isMaintenance) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MaintenanceScreen(
                            title: item.rawTitle,
                            category: 'Sektor Usaha & DPMPTSP',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailLayananUsahaScreen(
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primaryColor.withOpacity(0.12), width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  displayIcon,
                                  color: primaryColor,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.rawTitle,
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (isMaintenance)
                            Positioned(
                              top: -5,
                              right: -5,
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
      ),
    );
  }
}