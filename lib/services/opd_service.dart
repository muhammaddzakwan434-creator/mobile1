// =============================================================================
// FILE: lib/services/opd_service.dart
// FUNGSI: Service Master Pengelola Data OPD (Instansi, Layanan Publik, & Sektor)
// PATTERN: Singleton Pattern & Reactive State Management (ChangeNotifier)
// =============================================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/instansi_model.dart';
import '../models/layanan_model.dart';
import '../models/custom_field_config.dart';
import '../models/sektor_model.dart';
import '../models/global_search_model.dart';

/// Kelas Service Master Pengelola Katalog Instansi OPD, Layanan Publik, & Sektor
class OpdService extends ChangeNotifier {
  static final OpdService _instance = OpdService._internal();
  factory OpdService() => _instance;

  static const String _rtdbBaseUrl = 'https://sukabumi-one-access-app-c7f15-default-rtdb.firebaseio.com/opd_status';

  OpdService._internal() {
    _initDefaultData();
    _loadSavedStatusLocal();
    _fetchRealtimeDatabaseStatus();
    _listenToCloudStatus();

    // Polling Realtime Database setiap 3 detik agar sync instan tanpa billing
    Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchRealtimeDatabaseStatus();
    });
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> _fetchRealtimeDatabaseStatus() async {
    try {
      final res = await http.get(Uri.parse('$_rtdbBaseUrl.json'));
      if (res.statusCode == 200 && res.body != 'null') {
        final dynamic decoded = json.decode(res.body);
        if (decoded is Map) {
          decoded.forEach((key, val) {
            if (val is Map) {
              final String id = val['id']?.toString() ?? '';
              final String type = val['type']?.toString() ?? '';
              final bool isActive = val['isActive'] == true;

              if (id.isNotEmpty) {
                if (type == 'instansi') {
                  int idx = _instansiList.indexWhere((e) => e.id == id || e.kodeInstansi.toLowerCase() == id.toLowerCase());
                  if (idx != -1 && _instansiList[idx].isActive != isActive) {
                    _instansiList[idx] = _instansiList[idx].copyWith(isActive: isActive);
                  }
                } else if (type == 'layanan') {
                  int idx = _layananList.indexWhere((e) => e.id == id);
                  if (idx != -1 && _layananList[idx].isActive != isActive) {
                    _layananList[idx] = _layananList[idx].copyWith(isActive: isActive);
                  }
                } else if (type == 'sektor') {
                  int idx = _sektorList.indexWhere((e) => e.id == id);
                  if (idx != -1 && _sektorList[idx].isActive != isActive) {
                    _sektorList[idx] = _sektorList[idx].copyWith(isActive: isActive);
                  }
                }
              }
            }
          });
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('RTDB fetch status error: $e');
    }
  }

  void _syncToRtdb(String docId, Map<String, dynamic> data) async {
    try {
      final url = '$_rtdbBaseUrl/$docId.json';
      await http.put(Uri.parse(url), body: json.encode(data));
    } catch (e) {
      debugPrint('RTDB sync error: $e');
    }
  }

  Future<void> _loadSavedStatusLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (int i = 0; i < _instansiList.length; i++) {
        final key = 'status_instansi_${_instansiList[i].id}';
        if (prefs.containsKey(key)) {
          final bool val = prefs.getBool(key) ?? true;
          _instansiList[i] = _instansiList[i].copyWith(isActive: val);
        }
      }
      for (int i = 0; i < _layananList.length; i++) {
        final key = 'status_layanan_${_layananList[i].id}';
        if (prefs.containsKey(key)) {
          final bool val = prefs.getBool(key) ?? true;
          _layananList[i] = _layananList[i].copyWith(isActive: val);
        }
      }
      for (int i = 0; i < _sektorList.length; i++) {
        final key = 'status_sektor_${_sektorList[i].id}';
        if (prefs.containsKey(key)) {
          final bool val = prefs.getBool(key) ?? true;
          _sektorList[i] = _sektorList[i].copyWith(isActive: val);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading local status: $e');
    }
  }

  void _listenToCloudStatus() {
    try {
      _db.collection('opd_status').snapshots().listen((snapshot) {
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final String id = data['id']?.toString() ?? '';
          final String type = data['type']?.toString() ?? '';
          final bool isActive = data['isActive'] == true;

          if (id.isEmpty) continue;

          if (type == 'instansi') {
            int idx = _instansiList.indexWhere((e) => e.id == id || e.kodeInstansi.toLowerCase() == id.toLowerCase());
            if (idx != -1) {
              _instansiList[idx] = _instansiList[idx].copyWith(isActive: isActive);
            }
          } else if (type == 'layanan') {
            int idx = _layananList.indexWhere((e) => e.id == id);
            if (idx != -1) {
              _layananList[idx] = _layananList[idx].copyWith(isActive: isActive);
            }
          } else if (type == 'sektor') {
            int idx = _sektorList.indexWhere((e) => e.id == id);
            if (idx != -1) {
              _sektorList[idx] = _sektorList[idx].copyWith(isActive: isActive);
            }
          }
        }
        notifyListeners();
      }, onError: (e) {
        debugPrint('Firestore opd_status listen error: $e');
      });
    } catch (e) {
      debugPrint('Firestore opd_status init error: $e');
    }
  }

  final List<InstansiModel> _instansiList = [];
  final List<LayananModel> _layananList = [];
  final List<SektorModel> _sektorList = [];

  // Getter Unmodifiable List untuk Mencegah Mutasi Tidak Sengaja dari Luar Service
  List<InstansiModel> get instansiList => List.unmodifiable(_instansiList);
  List<LayananModel> get layananList => List.unmodifiable(_layananList);
  List<SektorModel> get sektorList => List.unmodifiable(_sektorList);

  // Data FAQ Terpadu untuk Pencarian & Bot
  final Map<String, String> faqData = {
    'Bagaimana cara membuat pengaduan?':
        'Untuk membuat pengaduan, Anda bisa masuk ke menu "Layanan" di navigasi bawah, pilih kategori layanan yang sesuai, lalu isi formulir pengaduan dengan lengkap.',
    'Bagaimana cara melihat status pengaduan saya?':
        'Status pengaduan dapat dipantau melalui menu "Log Aktivitas" di halaman profil Anda. Anda akan mendapatkan notifikasi real-time.',
    'Berapa lama pengaduan diproses?':
        'Proses pengaduan dan permohonan layanan biasanya memakan waktu 1-3 hari kerja tergantung pada tingkat kompleksitas masalah.',
    'Apa saja layanan yang tersedia?':
        'Saat ini tersedia layanan Pengaduan Infrastruktur, Layanan Dukcapil Digital, Informasi Cuaca, Berita Kota Sukabumi, dan Integrasi SSO IKD.',
    'Di mana lokasi kantor pelayanan?':
        'Kantor Pusat Layanan terpadu berada di Balai Kota Sukabumi, Jl. R. Syamsudin, S.H. No.25.',
    'Mengapa pengaduan saya belum ditindaklanjuti?':
        'Mohon pastikan data yang diinput sudah lengkap. Jika sudah lebih dari 3 hari kerja, Anda bisa menggunakan fitur "Hubungi Admin".',
  };

  /// --------------------------------------------------------------------------
  /// FUNGSI PENCARIAN GLOBAL (UNIVERSAL SEARCH ENGINE)
  /// --------------------------------------------------------------------------
  List<GlobalSearchResult> performGlobalSearch(BuildContext context, String query) {
    final List<GlobalSearchResult> results = [];
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return results;

    // 1. CARI DI INSTANSI
    for (var item in _instansiList) {
      if (item.namaSingkat.toLowerCase().contains(q) || item.namaLengkap.toLowerCase().contains(q)) {
        results.add(GlobalSearchResult(
          title: item.namaSingkat,
          subtitle: item.namaLengkap,
          type: SearchResultType.instansi,
          icon: Icons.account_balance_rounded,
          onTap: () {
            // Logika navigasi ditangani di delegate untuk kemudahan build context
          },
        ));
      }
    }

    // 2. CARI DI LAYANAN
    for (var item in _layananList) {
      if (item.judulLayanan.toLowerCase().contains(q) || item.deskripsi.toLowerCase().contains(q)) {
        results.add(GlobalSearchResult(
          title: item.judulLayanan,
          subtitle: 'Layanan di ${item.sektor}',
          type: SearchResultType.layanan,
          icon: Icons.assignment_rounded,
          onTap: () {},
        ));
      }
    }

    // 3. CARI DI SEKTOR
    for (var item in _sektorList) {
      if (item.title.toLowerCase().contains(q) || item.desc.toLowerCase().contains(q)) {
        results.add(GlobalSearchResult(
          title: 'Sektor ${item.title}',
          subtitle: item.desc,
          type: SearchResultType.sektor,
          icon: Icons.grid_view_rounded,
          onTap: () {},
        ));
      }
    }

    // 4. CARI DI PUSAT BANTUAN (FAQ)
    faqData.forEach((question, answer) {
      if (question.toLowerCase().contains(q) || answer.toLowerCase().contains(q)) {
        results.add(GlobalSearchResult(
          title: question,
          subtitle: 'Pusat Bantuan / FAQ',
          type: SearchResultType.bantuan,
          icon: Icons.help_outline_rounded,
          onTap: () {},
        ));
      }
    });

    // 5. CARI DI INFORMASI APLIKASI (TENTANG)
    const aboutKeywords = ['pengembang', 'developer', 'versi', 'tentang', 'deskripsi', 'tujuan', 'sukabumi city one access'];
    for (var kw in aboutKeywords) {
      if (kw.contains(q)) {
        results.add(GlobalSearchResult(
          title: 'Tentang Aplikasi',
          subtitle: 'Informasi pengembang dan tujuan aplikasi',
          type: SearchResultType.tentang,
          icon: Icons.info_outline_rounded,
          onTap: () {},
        ));
        break;
      }
    }

    return results;
  }

  /// --------------------------------------------------------------------------
  /// FUNGSI INSIALISASI SEED DATA AWAL (SEKTOR, INSTANSI, & LAYANAN PUBLIK)
  /// --------------------------------------------------------------------------
  void _initDefaultData() {
    if (_instansiList.isNotEmpty) return;

    // 1. Seed 10 Sektor Kategori Utama (Fase Kehidupan)
    _sektorList.addAll([
      SektorModel(
        id: 's1',
        title: 'Keluarga',
        imagePath: 'assets/icon/keluarga.png',
        desc: 'Administrasi Kependudukan, Pernikahan, KK & Akta',
        iconName: 'family_restroom_rounded',
      ),
      SektorModel(
        id: 's2',
        title: 'Pendidikan',
        imagePath: 'assets/icon/pendidikan.png',
        desc: 'Beasiswa, PPDB, Pendaftaran Sekolah',
        iconName: 'school_rounded',
      ),
      SektorModel(
        id: 's3',
        title: 'Usaha',
        imagePath: 'assets/icon/usaha.png',
        desc: 'Izin Usaha, NIB, UMKM Kota Sukabumi',
        iconName: 'store_rounded',
      ),
      SektorModel(
        id: 's4',
        title: 'Lingkungan & Tempat Tinggal',
        imagePath: 'assets/icon/lingkungan.png',
        desc: 'PBB, Kebersihan, Izin Bangunan (PBG)',
        iconName: 'home_work_rounded',
      ),
      SektorModel(
        id: 's5',
        title: 'Kendaraan',
        imagePath: 'assets/icon/kendaraan.png',
        desc: 'Pajak Kendaraan, SIM, Uji KIR',
        iconName: 'directions_car_rounded',
      ),
      SektorModel(
        id: 's6',
        title: 'Kesehatan',
        imagePath: 'assets/icon/kesehatan.png',
        desc: 'BPJS, Puskesmas, Antrean RSUD',
        iconName: 'local_hospital_rounded',
      ),
      SektorModel(
        id: 's7',
        title: 'Tanggap Darurat',
        imagePath: 'assets/icon/tanggapdarurat.png',
        desc: 'BPBD, Pemadam Kebakaran, Ambulans 112',
        iconName: 'warning_amber_rounded',
      ),
      SektorModel(
        id: 's8',
        title: 'Karier',
        imagePath: 'assets/icon/karier.png',
        desc: 'Lowongan Kerja, Pelatihan Disnaker',
        iconName: 'work_rounded',
      ),
      SektorModel(
        id: 's9',
        title: 'Rekreasi',
        imagePath: 'assets/icon/rekreasi.png',
        desc: 'Wisata Kota, Fasilitas Olahraga & Taman',
        iconName: 'sports_soccer_rounded',
      ),
      SektorModel(
        id: 's10',
        title: 'Sosial & Hukum',
        imagePath: 'assets/icon/sosialhukum.png',
        desc: 'Bantuan Sosial, Konsultasi Hukum Warga',
        iconName: 'gavel_rounded',
      ),
    ]);

    // 2. Seed 10 Instansi Utama Pemkot Sukabumi (Lengkap dengan iFrame Webview Portal)
    _instansiList.addAll([
      InstansiModel(
        id: '1',
        kodeInstansi: 'disdukcapil',
        namaSingkat: 'DISDUKCAPIL',
        namaLengkap: 'Dinas Kependudukan dan Pencatatan Sipil',
        alamat: 'Jl. Bhayangkara No. 202, Kota Sukabumi, Jawa Barat 43121',
        jamOperasional: 'Senin - Jumat | 08.00 - 15.30 WIB',
        kontak: '(0266) 221122 / WA: 0811-2233-4455',
        logoPath: 'assets/images/disduk.png',
        iframeUrl: 'https://disdukcapil.sukabumikota.go.id',
        deskripsi:
            'Dinas Kependudukan dan Pencatatan Sipil Kota Sukabumi bertanggung jawab dalam menyelenggarakan urusan pemerintahan bidang kependudukan dan pencatatan sipil secara tertib, efisien, transparan, dan berbasis teknologi digital.',
        mapsQuery: 'Disdukcapil Kota Sukabumi',
        tugasFungsi: [
          'Penerbitan dokumen kependudukan (KTP-el, KK, KIA).',
          'Pencatatan peristiwa penting (Akta Kelahiran, Kematian, Perkawinan).',
          'Pengelolaan data kependudukan skala daerah.',
          'Pelayanan pendaftaran penduduk dan verifikasi identitas warga.',
        ],
      ),
      InstansiModel(
        id: '2',
        kodeInstansi: 'diskominfo',
        namaSingkat: 'DISKOMINFO',
        namaLengkap: 'Dinas Komunikasi dan Informatika',
        alamat: 'Jl. Syamsudin S.H. No. 25, Cikole, Kota Sukabumi, Jawa Barat 43111',
        jamOperasional: 'Senin - Jumat | 08.00 - 16.00 WIB',
        kontak: '(0266) 221888 / diskominfo@sukabumikota.go.id',
        logoPath: 'assets/images/diskominfo.png',
        iframeUrl: 'https://diskominfo.sukabumikota.go.id',
        deskripsi:
            'Dinas Komunikasi dan Informatika Kota Sukabumi mengelola infrastruktur teknologi informasi, komunikasi publik, sistem pemerintahan berbasis elektronik (SPBE), serta pusat tanggap darurat dan keamanan informasi daerah.',
        mapsQuery: 'Diskominfo Kota Sukabumi',
        tugasFungsi: [
          'Pengembangan dan pengelolaan infrastruktur jaringan & SPBE.',
          'Pengelolaan portal resmi & media komunikasi publik Kota Sukabumi.',
          'Penyelenggaraan layanan tanggap darurat Sukabumi Siaga 112.',
          'Pengamanan informasi dan literasi digital masyarakat.',
        ],
      ),
      InstansiModel(
        id: '3',
        kodeInstansi: 'dpmptsp',
        namaSingkat: 'DPMPTSP',
        namaLengkap: 'Dinas Penanaman Modal dan Pelayanan Terpadu Satu Pintu',
        alamat: 'Jl. Mayjend S. Parman No. 5, Cikole, Kota Sukabumi, Jawa Barat 43114',
        jamOperasional: 'Senin - Jumat | 08.00 - 15.30 WIB',
        kontak: '(0266) 222555 / dpmptsp@sukabumikota.go.id',
        logoPath: 'assets/images/dpmptsp.png',
        iframeUrl: 'https://dpmptsp.sukabumikota.go.id',
        deskripsi:
            'DPMPTSP Kota Sukabumi menyelenggarakan pelayanan perizinan dan non-perizinan secara terpadu satu pintu serta memfasilitasi investasi dan kemudahan berusaha bagi UMKM hingga pelaku usaha besar.',
        mapsQuery: 'DPMPTSP Kota Sukabumi',
        tugasFungsi: [
          'Pelayanan perizinan berusaha terintegrasi secara elektronik (OSS RBA).',
          'Penerbitan Izin Persetujuan Bangunan Gedung (PBG) dan Reklame.',
          'Fasilitasi penanaman modal dan promosi investasi daerah.',
          'Pengawasan dan pengendalian pelaksanaan perizinan usaha.',
        ],
      ),
      InstansiModel(
        id: '4',
        kodeInstansi: 'bpkpd',
        namaSingkat: 'BPKPD',
        namaLengkap: 'Badan Pengelola Keuangan dan Pendapatan Daerah',
        alamat: 'Jl. R. Syamsudin S.H. No. 52, Kota Sukabumi, Jawa Barat 43113',
        jamOperasional: 'Senin - Jumat | 08.00 - 15.30 WIB',
        kontak: '(0266) 211999 / bpkpd@sukabumikota.go.id',
        logoPath: 'assets/images/bpkpd.png',
        iframeUrl: 'https://bpkpd.sukabumikota.go.id',
        deskripsi:
            'BPKPD Kota Sukabumi bertugas mengelola pendapatan daerah, Pajak Bumi dan Bangunan (PBB-P2), BPHTB, serta akuntansi dan perbendaharaan keuangan daerah secara akuntabel.',
        mapsQuery: 'BPKPD Kota Sukabumi',
        tugasFungsi: [
          'Pengelolaan Pajak Bumi dan Bangunan (PBB-P2) dan BPHTB.',
          'Pencekan cetak SPPT dan pembayaran pajak daerah online.',
          'Pengelolaan keuangan dan aset daerah Pemkot Sukabumi.',
          'Perumusan kebijakan pendapatan dan belanja daerah.',
        ],
      ),
      InstansiModel(
        id: '5',
        kodeInstansi: 'dkp3',
        namaSingkat: 'DKP3',
        namaLengkap: 'Dinas Ketahanan Pangan, Pertanian dan Perikanan',
        alamat: 'Jl. Raya Cisaat No. 12, Kota Sukabumi, Jawa Barat 43152',
        jamOperasional: 'Senin - Jumat | 08.00 - 15.30 WIB',
        kontak: '(0266) 234567 / dkp3@sukabumikota.go.id',
        logoPath: 'assets/images/dkp3.png',
        iframeUrl: 'https://dkp3.sukabumikota.go.id',
        deskripsi:
            'DKP3 Kota Sukabumi bertanggung jawab dalam menjaga ketahanan pangan masyarakat, pelayanan kesehatan hewan/vets, bimbingan kelompok tani & pembudidaya ikan daerah.',
        mapsQuery: 'DKP3 Kota Sukabumi',
        tugasFungsi: [
          'Pelayanan kesehatan hewan, imunisasi rabies, dan Puskeswan.',
          'Pemeriksaan keamanan pangan dan pembinaan kelompok tani.',
          'Fasilitasi bantuan bibit pertanian dan perikanan darat.',
          'Pengawasan ketersediaan dan harga pangan strategis.',
        ],
      ),
      InstansiModel(
        id: '6',
        kodeInstansi: 'dinkes',
        namaSingkat: 'DINKES',
        namaLengkap: 'Dinas Kesehatan Kota Sukabumi',
        alamat: 'Jl. Pelabuhan II No. 64, Cikondang, Kota Sukabumi, Jawa Barat 43142',
        jamOperasional: 'Senin - Jumat | 08.00 - 15.30 WIB',
        kontak: '(0266) 225312 / dinkes@sukabumikota.go.id',
        logoPath: 'assets/images/dinkes.png',
        iframeUrl: 'https://dinkes.sukabumikota.go.id',
        deskripsi: 'Dinas Kesehatan Kota Sukabumi mengelola jaminan kesehatan masyarakat, fasilitas kesehatan Puskesmas & RSUD, serta imunisasi anak daerah.',
        mapsQuery: 'Dinas Kesehatan Kota Sukabumi',
        tugasFungsi: [
          'Pengelolaan izin tenaga kesehatan dan apotek.',
          'Fasilitasi BPJS Kesehatan PBI APBD Kota Sukabumi.',
          'Penyelenggaraan pemeriksaan kesehatan & imunisasi berkala.',
        ],
      ),
      InstansiModel(
        id: '7',
        kodeInstansi: 'disdik',
        namaSingkat: 'DISDIK',
        namaLengkap: 'Dinas Pendidikan dan Kebudayaan',
        alamat: 'Jl. Subang Jaya No. 12, Kota Sukabumi, Jawa Barat 43116',
        jamOperasional: 'Senin - Jumat | 08.00 - 15.30 WIB',
        kontak: '(0266) 211234 / disdik@sukabumikota.go.id',
        logoPath: 'assets/images/disdik.png',
        iframeUrl: 'https://disdik.sukabumikota.go.id',
        deskripsi: 'Dinas Pendidikan dan Kebudayaan Kota Sukabumi menyelenggarakan penerimaan peserta didik baru (PPDB), beasiswa daerah, dan pelestarian cagar budaya.',
        mapsQuery: 'Dinas Pendidikan Kota Sukabumi',
        tugasFungsi: [
          'Penyelenggaraan Sistem PPDB Online SD & SMP.',
          'Fasilitasi bantuan beasiswa dan ijazah sekolah.',
          'Pengawasan mutu kurikulum dan fasilitasi guru.',
        ],
      ),
      InstansiModel(
        id: '8',
        kodeInstansi: 'disnaker',
        namaSingkat: 'DISNAKER',
        namaLengkap: 'Dinas Tenaga Kerja Kota Sukabumi',
        alamat: 'Jl. Taman Bahagia No. 2, Kota Sukabumi, Jawa Barat 43132',
        jamOperasional: 'Senin - Jumat | 08.00 - 15.30 WIB',
        kontak: '(0266) 223456 / disnaker@sukabumikota.go.id',
        logoPath: 'assets/images/disnaker.png',
        iframeUrl: 'https://disnaker.sukabumikota.go.id',
        deskripsi: 'Dinas Tenaga Kerja Kota Sukabumi melayani pembuatan Kartu Kuning (AK-1), informasi bursa kerja (Job Fair), serta pelatihan vokasi kerja.',
        mapsQuery: 'Disnaker Kota Sukabumi',
        tugasFungsi: [
          'Penerbitan Kartu Pencari Kerja (AK-1 / Kartu Kuning).',
          'Penyelenggaraan pelatihan keterampilan di BLK.',
          'Penyelesaian perselisihan hubungan industrial.',
        ],
      ),
      InstansiModel(
        id: '9',
        kodeInstansi: 'dishub',
        namaSingkat: 'DISHUB',
        namaLengkap: 'Dinas Perhubungan Kota Sukabumi',
        alamat: 'Jl. Pemuda No. 1, Tiwul, Kota Sukabumi, Jawa Barat 43141',
        jamOperasional: 'Senin - Jumat | 08.00 - 15.30 WIB',
        kontak: '(0266) 224567 / dishub@sukabumikota.go.id',
        logoPath: 'assets/images/dishub.png',
        iframeUrl: 'https://dishub.sukabumikota.go.id',
        deskripsi: 'Dinas Perhubungan Kota Sukabumi melayani pendaftaran Uji Berkala Kendaraan Bermotor (KIR), izin trayek angkutan kota, dan rekayasa lalu lintas.',
        mapsQuery: 'Dishub Kota Sukabumi',
        tugasFungsi: [
          'Pelaksanaan Uji Berkala Kendaraan Bermotor (Uji KIR).',
          'Penerbitan izin operasional trayek angkutan umum.',
          'Pengelolaan fasilitas parkir dan penerangan jalan umum (PJU).',
        ],
      ),
      InstansiModel(
        id: '10',
        kodeInstansi: 'dlh',
        namaSingkat: 'DLH',
        namaLengkap: 'Dinas Lingkungan Hidup Kota Sukabumi',
        alamat: 'Jl. K.H. Ahmad Sanusi No. 4, Kota Sukabumi, Jawa Barat 43131',
        jamOperasional: 'Senin - Jumat | 08.00 - 15.30 WIB',
        kontak: '(0266) 226789 / dlh@sukabumikota.go.id',
        logoPath: 'assets/images/dlh.png',
        iframeUrl: 'https://dlh.sukabumikota.go.id',
        deskripsi: 'Dinas Lingkungan Hidup Kota Sukabumi melayani perizinan lingkungan (AMDAL / UKL-UPL), pengangkutan sampah, serta pengawasan kualitas udara & air.',
        mapsQuery: 'DLH Kota Sukabumi',
        tugasFungsi: [
          'Rekomendasi persetujuan lingkungan AMDAL & UKL-UPL.',
          'Pelayanan pengangkutan dan kebersihan sampah lingkungan.',
          'Pemantauan indeks kualitas lingkungan hidup (IKLH).',
        ],
      ),
    ]);

    // 3. Seed Layanan Publik Utama Resmi Terpadu (Sesuai Seluruh Tampilan User Warga)
    _layananList.addAll([
      // --- DISDUKCAPIL (Sektor Keluarga) ---
      LayananModel(
        id: '101',
        kodeInstansi: 'disdukcapil',
        sektor: 'Keluarga',
        judulLayanan: 'Pelayanan KTP Elektronik (KTP-el)',
        rawTitle: 'KTP Elektronik',
        subjudul: 'Perekaman baru, penggantian KTP rusak/hilang, dan pemutakhiran data KTP.',
        deskripsi:
            'Layanan penerbitan KTP Elektronik bagi warga Kota Sukabumi yang telah berusia 17 tahun atau sudah menikah. Mencakup pendaftaran baru, penggantian fisik KTP rusak/hilang, serta pencetakan ulang.',
        persyaratan: [
          'Fotokopi Kartu Keluarga (KK) terbaru.',
          'KTP lama yang rusak (jika penggantian KTP rusak).',
          'Surat Keterangan Kehilangan dari Kepolisian (jika KTP hilang).',
          'Pasfoto ukuran 3x4 atau foto langsung di lokasi pelayanan.',
        ],
        urlPortal: 'https://mocilegit.sukabumikota.go.id/pengajuan/ktp',
        iconName: 'badge_outlined',
        formFields: [
          CustomFieldConfig(id: 'f1', label: 'NIK Pemohon (16 Digit)', type: FieldType.number, hint: 'Masukkan 16 digit NIK'),
          CustomFieldConfig(id: 'f2', label: 'Nama Lengkap Pemohon', type: FieldType.shortText, hint: 'Sesuai KTP / Akta'),
          CustomFieldConfig(id: 'f3', label: 'Jenis Permohonan KTP', type: FieldType.dropdown, options: ['Perekaman Baru (Pemula 17 Th)', 'Ganti KTP Rusak', 'Ganti KTP Hilang', 'Aktivasi KTP Digital (IKD)']),
          CustomFieldConfig(id: 'f4', label: 'Nomor Kartu Keluarga (KK)', type: FieldType.number, hint: 'Masukkan 16 digit No. KK'),
          CustomFieldConfig(id: 'f5', label: 'Nomor WhatsApp / HP', type: FieldType.number, hint: 'Contoh: 081234567890'),
          CustomFieldConfig(id: 'f6', label: 'Alasan / Keterangan Tambahan', type: FieldType.longText, hint: 'Jelaskan alasan permohonan...'),
          CustomFieldConfig(id: 'f7', label: 'Unggah Lampiran Berkas Syarat', type: FieldType.fileUpload),
        ],
      ),
      LayananModel(
        id: '102',
        kodeInstansi: 'disdukcapil',
        sektor: 'Keluarga',
        judulLayanan: 'Kartu Keluarga (KK)',
        rawTitle: 'Kartu Keluarga (KK)',
        subjudul: 'Penerbitan KK baru, penambahan anggota keluarga, dan perubahan data KK.',
        deskripsi:
            'Layanan pembuatan Kartu Keluarga baru karena pernikahan, kelahiran anak, kepindahan penduduk, maupun perubahan status kependudukan warga Kota Sukabumi.',
        persyaratan: [
          'Buku Nikah / Akta Perkawinan (bagi keluarga baru).',
          'Surat Keterangan Lahir dari Bidan/Rumah Sakit (jika tambah anggota).',
          'Kartu Keluarga asli lama.',
          'Surat Pindah (SKPWNI) jika pindah datang dari luar kota.',
        ],
        urlPortal: 'https://mocilegit.sukabumikota.go.id/pengajuan/kk',
        iconName: 'family_restroom_outlined',
        formFields: [
          CustomFieldConfig(id: 'f10', label: 'NIK Kepala Keluarga', type: FieldType.number, hint: 'Masukkan 16 digit NIK'),
          CustomFieldConfig(id: 'f11', label: 'Nama Lengkap Kepala Keluarga', type: FieldType.shortText, hint: 'Sesuai KTP'),
          CustomFieldConfig(id: 'f12', label: 'Nomor Kartu Keluarga Lama', type: FieldType.number, hint: 'Masukkan 16 digit No. KK lama'),
          CustomFieldConfig(id: 'f13', label: 'Alasan Permohonan KK', type: FieldType.dropdown, options: ['Keluarga Baru (Pernikahan)', 'Penambahan Anggota (Kelahiran)', 'Perubahan Data Alamat/Pekerjaan', 'KK Rusak / Hilang']),
          CustomFieldConfig(id: 'f14', label: 'Alamat Rumah Lengkap', type: FieldType.longText, hint: 'RT/RW, Kelurahan, Kecamatan, Kota Sukabumi'),
          CustomFieldConfig(id: 'f15', label: 'Unggah Berkas Persyaratan (KK/Buku Nikah)', type: FieldType.fileUpload),
        ],
      ),
      LayananModel(
        id: '103',
        kodeInstansi: 'disdukcapil',
        sektor: 'Keluarga',
        judulLayanan: 'Kartu Identitas Anak (KIA)',
        rawTitle: 'Kartu Identitas Anak (KIA)',
        subjudul: 'Identitas resmi anak usia 0 sampai kurang dari 17 tahun.',
        deskripsi: 'Layanan penerbitan KIA (Layanan Kita Cerdas) untuk memenuhi hak kependudukan dan perlindungan anak.',
        persyaratan: [
          'Fotokopi Akta Kelahiran Anak.',
          'Fotokopi Kartu Keluarga (KK) Orang Tua.',
          'Fotokopi KTP Kedua Orang Tua.',
          'Pasfoto Anak ukuran 2x3 (untuk anak usia > 5 tahun).',
        ],
        urlPortal: 'https://mocilegit.sukabumikota.go.id/pengajuan/kia',
        iconName: 'child_care_outlined',
      ),
      LayananModel(
        id: '104',
        kodeInstansi: 'disdukcapil',
        sektor: 'Keluarga',
        judulLayanan: 'Akta Kelahiran',
        rawTitle: 'Akta Kelahiran',
        subjudul: 'Penerbitan akta kelahiran bayi baru lahir & keterlambatan pencatatan.',
        deskripsi: 'Layanan pencatatan kelahiran resmi (Layanan Ananda Sehat) sebagai bukti sah status hukum anak.',
        persyaratan: [
          'Surat Keterangan Lahir dari Bidan / Rumah Sakit.',
          'Fotokopi Buku Nikah / Akta Perkawinan Orang Tua.',
          'Fotokopi Kartu Keluarga (KK).',
          'Fotokopi KTP Orang Tua & 2 Saksi.',
        ],
        urlPortal: 'https://mocilegit.sukabumikota.go.id/pengajuan/kelahiran',
        iconName: 'child_friendly_outlined',
      ),
      LayananModel(
        id: '105',
        kodeInstansi: 'disdukcapil',
        sektor: 'Keluarga',
        judulLayanan: 'Akta Kematian (Kemboja Sari)',
        rawTitle: 'Akta Kematian',
        subjudul: 'Penerbitan akta kematian warga untuk pemutakhiran data kependudukan.',
        deskripsi: 'Layanan Kemboja Sari pencatatan kematian untuk kepengurusan ahli waris, perbankan, & pencoretan dari KK.',
        persyaratan: [
          'Surat Keterangan Kematian dari Dokter / Rumah Sakit / Kelurahan.',
          'Kartu Keluarga (KK) Asli Almarhum/Almarhumah.',
          'KTP-el Asli Almarhum/Almarhumah.',
          'Fotokopi KTP Pelapor & 2 Saksi.',
        ],
        urlPortal: 'https://mocilegit.sukabumikota.go.id/dashboard',
        iconName: 'description_outlined',
      ),
      LayananModel(
        id: '106',
        kodeInstansi: 'disdukcapil',
        sektor: 'Keluarga',
        judulLayanan: 'Surat Pindah Domisili (SKPWNI)',
        rawTitle: 'Pindah Datang (SKPWNI)',
        subjudul: 'Pengurusan surat keterangan pindah domisili antar kelurahan/kota.',
        deskripsi: 'Layanan Patepang Sono untuk kepindahan alamat tempat tinggal warga secara resmi.',
        persyaratan: [
          'Kartu Keluarga (KK) Asli.',
          'KTP-el Asli warga yang berpindah.',
          'Alamat Lengkap Tujuan Pindah (RT/RW, Kelurahan, Kota).',
        ],
        urlPortal: 'https://mocilegit.sukabumikota.go.id/pengajuan/pindah',
        iconName: 'move_to_inbox_outlined',
      ),

      // --- DISKOMINFO (Sektor Tanggap Darurat & Sosial Hukum) ---
      LayananModel(
        id: '201',
        kodeInstansi: 'diskominfo',
        sektor: 'Tanggap Darurat',
        judulLayanan: 'Sukabumi Siaga 112',
        rawTitle: 'Sukabumi Siaga 112',
        subjudul: 'Layanan panggilan darurat bebas pulsa 24 jam Kota Sukabumi.',
        deskripsi: 'Pusat integrasi laporan darurat kebakaran, bencana alam, kecelakaan, ambulans, & gangguan keamanan.',
        persyaratan: [
          'Lokasi kejadian darurat jelas.',
          'Nomor HP pelapor aktif.',
        ],
        urlPortal: 'https://diskominfo.sukabumikota.go.id',
        iconName: 'warning_amber_outlined',
      ),
      LayananModel(
        id: '202',
        kodeInstansi: 'diskominfo',
        sektor: 'Sosial & Hukum',
        judulLayanan: 'Permohonan Informasi Publik (PPID)',
        rawTitle: 'Permohonan Informasi (PPID)',
        subjudul: 'Pelayanan keterbukaan informasi publik Pemkot Sukabumi.',
        deskripsi: 'Layanan permohonan data dan informasi resmi pemerintah daerah bagi warga dan akademisi.',
        persyaratan: [
          'Fotokopi KTP Pemohon / Komunitas.',
          'Surat Permohonan Informasi Resmi.',
        ],
        urlPortal: 'https://ppid.sukabumikota.go.id',
        iconName: 'info_outlined',
      ),
      LayananModel(
        id: '203',
        kodeInstansi: 'diskominfo',
        sektor: 'Sosial & Hukum',
        judulLayanan: 'Pengaduan Warga (E-Lapor)',
        rawTitle: 'Pengaduan Warga (E-Lapor)',
        subjudul: 'Kanal pengaduan sarana publik & pelayanan pemerintah.',
        deskripsi: 'Layanan penyampaian aspirasi dan pengaduan jalan rusak, sampah, dan fasilitas umum Kota Sukabumi.',
        persyaratan: [
          'Foto bukti fasilitas / masalah.',
          'Lokasi alamat jelas.',
        ],
        urlPortal: 'https://lapor.go.id',
        iconName: 'rate_review_outlined',
      ),

      // --- DPMPTSP (Sektor Usaha & Lingkungan) ---
      LayananModel(
        id: '301',
        kodeInstansi: 'dpmptsp',
        sektor: 'Usaha',
        judulLayanan: 'Perizinan Berusaha OSS RBA (NIB)',
        rawTitle: 'NIB & Izin Usaha (OSS RBA)',
        subjudul: 'Penerbitan Nomor Induk Berusaha (NIB) bagi UMKM & usaha besar.',
        deskripsi: 'Layanan pengurusan perizinan berusaha terintegrasi elektronik secara instan dari pemerintah.',
        persyaratan: [
          'KTP / NIK Pelaku Usaha.',
          'Nomor WhatsApp & Email Aktif.',
          'Data Alamat dan KBLI Usaha.',
        ],
        urlPortal: 'https://oss.go.id',
        iconName: 'store_outlined',
      ),
      LayananModel(
        id: '302',
        kodeInstansi: 'dpmptsp',
        sektor: 'Lingkungan & Tempat Tinggal',
        judulLayanan: 'Persetujuan Bangunan Gedung (PBG)',
        rawTitle: 'Persetujuan Bangunan (PBG)',
        subjudul: 'Izin mendirikan & renovasi bangunan gedung / rumah.',
        deskripsi: 'Layanan kelayakan teknis dan legalitas konstruksi bangunan di wilayah Kota Sukabumi.',
        persyaratan: [
          'Fotokopi Sertifikat Tanah.',
          'Gambar Rencana Arsitektur & Teknis Building.',
          'KTP Pemilik Bangunan.',
        ],
        urlPortal: 'https://simbg.pu.go.id',
        iconName: 'home_work_outlined',
      ),
      LayananModel(
        id: '303',
        kodeInstansi: 'dpmptsp',
        sektor: 'Usaha',
        judulLayanan: 'Perizinan Reklame (Layanan SAKTI)',
        rawTitle: 'Perizinan Reklame',
        subjudul: 'Izin pemasangan papan reklame, spanduk, & baliho komersial.',
        deskripsi: 'Layanan perizinan penempatan media promosi dan titik reklame komersial.',
        persyaratan: [
          'KTP Pemohon & NIB Usaha.',
          'Desain & Foto Titik Reklame.',
          'Surat Sewa Lahan / Bukti PBB.',
        ],
        urlPortal: 'https://dpmptsp.sukabumikota.go.id',
        iconName: 'assignment_outlined',
      ),

      // --- BPKPD (Sektor Lingkungan & Tempat Tinggal) ---
      LayananModel(
        id: '401',
        kodeInstansi: 'bpkpd',
        sektor: 'Lingkungan & Tempat Tinggal',
        judulLayanan: 'Pajak Bumi dan Bangunan (PBB-P2)',
        rawTitle: 'Pajak Bumi & Bangunan (PBB)',
        subjudul: 'Pelayanan PANTAS BPKPD untuk pengelolaan SPPT PBB.',
        deskripsi: 'Layanan pendaftaran objek pajak baru, mutasi nama SPPT, & pembetulan SPPT PBB.',
        persyaratan: [
          'Fotokopi KTP Wajib Pajak.',
          'Fotokopi Sertifikat Tanah / AJB.',
          'Surat Pengantar Kelurahan.',
        ],
        urlPortal: 'https://bpkpd.sukabumikota.go.id',
        iconName: 'receipt_long_outlined',
      ),
      LayananModel(
        id: '402',
        kodeInstansi: 'bpkpd',
        sektor: 'Lingkungan & Tempat Tinggal',
        judulLayanan: 'Pajak Jual-Beli Properti (BPHTB)',
        rawTitle: 'Pajak Jual-Beli Properti (BPHTB)',
        subjudul: 'Pengurusan Bea Perolehan Hak atas Tanah dan Bangunan.',
        deskripsi: 'Layanan verifikasi dan setoran pajak transaksi perolehan tanah & bangunan.',
        persyaratan: [
          'Fotokopi KTP Pembeli & Penjual.',
          'Fotokopi Sertifikat & SPPT PBB Lunas.',
          'Draft Akta Jual Beli / Hibah.',
        ],
        urlPortal: 'https://bpkpd.sukabumikota.go.id',
        iconName: 'real_estate_agent_outlined',
      ),
      LayananModel(
        id: '403',
        kodeInstansi: 'bpkpd',
        sektor: 'Lingkungan & Tempat Tinggal',
        judulLayanan: 'Cek & Cetak SPPT PBB Online',
        rawTitle: 'Cek & Cetak SPPT PBB',
        subjudul: 'Pengecekan tagihan PBB & pencetakan e-SPPT mandiri.',
        deskripsi: 'Layanan informasi jumlah tagihan PBB-P2 dan bukti lunas pajak berbasis NOP.',
        persyaratan: [
          'Nomor Objek Pajak (NOP) 18 Digit.',
        ],
        urlPortal: 'https://bpkpd.sukabumikota.go.id',
        iconName: 'print_outlined',
      ),

      // --- DKP3 (Sektor Kesehatan & Usaha) ---
      LayananModel(
        id: '501',
        kodeInstansi: 'dkp3',
        sektor: 'Kesehatan',
        judulLayanan: 'Puskeswan & Kesehatan Hewan',
        rawTitle: 'Puskeswan & Kesehatan Hewan',
        subjudul: 'Pelayanan medis hewan ternak & hewan kesayangan.',
        deskripsi: 'Layanan pemeriksaan kesehatan, pengobatan, & Surat Keterangan Kesehatan Hewan (SKKH).',
        persyaratan: [
          'KTP Pemilik Hewan.',
          'Buku Catatan Medis Hewan.',
        ],
        urlPortal: 'https://dkp3.sukabumikota.go.id',
        iconName: 'pets_outlined',
      ),
      LayananModel(
        id: '502',
        kodeInstansi: 'dkp3',
        sektor: 'Kesehatan',
        judulLayanan: 'Vaksinasi Rabies & Sterilisasi Hewan',
        rawTitle: 'Vaksinasi Rabies & Sterilisasi',
        subjudul: 'Program pencegahan rabies & sterilisasi gratis kucing/anjing.',
        deskripsi: 'Layanan imunisasi hewan penular rabies (HPR) dan pembatasan populasi hewan.',
        persyaratan: [
          'KTP Kota Sukabumi.',
          'Hewan sehat usia > 4 bulan.',
        ],
        urlPortal: 'https://dkp3.sukabumikota.go.id',
        iconName: 'medical_services_outlined',
      ),
      LayananModel(
        id: '503',
        kodeInstansi: 'dkp3',
        sektor: 'Usaha',
        judulLayanan: 'Bantuan Bibit Tani & Ikan',
        rawTitle: 'Bantuan Bibit Tani & Ikan',
        subjudul: 'Fasilitasi bantuan sarana produksi pertanian & perikanan.',
        deskripsi: 'Layanan pembinaan dan penyaluran bibit tanaman, pupuk, & benih ikan bagi kelompok tani.',
        persyaratan: [
          'Surat Keterangan Kelompok Tani / Pembudidaya.',
          'KTP Ketua Kelompok.',
        ],
        urlPortal: 'https://dkp3.sukabumikota.go.id',
        iconName: 'grass_outlined',
      ),

      // --- SEKTOR PENDIDIKAN ---
      LayananModel(
        id: '601',
        kodeInstansi: 'diskominfo',
        sektor: 'Pendidikan',
        judulLayanan: 'PPDB Online Kota Sukabumi',
        rawTitle: 'PPDB Online Sukabumi',
        subjudul: 'Pendaftaran Peserta Didik Baru tingkat SD & SMP.',
        deskripsi: 'Layanan pendaftaran siswa baru secara online untuk jenjang SD dan SMP di Kota Sukabumi.',
        persyaratan: ['Kartu Keluarga (KK).', 'Akta Kelahiran.', 'Ijazah / Surat Keterangan Lulus.'],
        urlPortal: 'https://sukabumikota.go.id',
        iconName: 'school_outlined',
      ),
      LayananModel(
        id: '602',
        kodeInstansi: 'diskominfo',
        sektor: 'Pendidikan',
        judulLayanan: 'Beasiswa Sukabumi Cerdas',
        rawTitle: 'Beasiswa Pendidikan',
        subjudul: 'Program bantuan biaya pendidikan bagi siswa berprestasi & kurang mampu.',
        deskripsi: 'Layanan pendaftaran beasiswa daerah bagi pelajar dan mahasiswa Kota Sukabumi.',
        persyaratan: ['KTP / Kartu Pelajar.', 'Surat Keterangan Tidak Mampu (SKTM) / Prestasi.'],
        urlPortal: 'https://sukabumikota.go.id',
        iconName: 'workspace_premium_outlined',
      ),

      // --- SEKTOR KENDARAAN ---
      LayananModel(
        id: '701',
        kodeInstansi: 'diskominfo',
        sektor: 'Kendaraan',
        judulLayanan: 'Uji Berkala KIR Kendaraan',
        rawTitle: 'Uji KIR Kendaraan',
        subjudul: 'Pelayanan pengujian kelayakan jalan kendaraan angkutan & barang.',
        deskripsi: 'Layanan uji KIR berkala kendaraan bermotor umum dan angkutan barang.',
        persyaratan: ['STNK Kendaraan.', 'Buku Uji KIR Lama.', 'KTP Pemilik / Pengemudi.'],
        urlPortal: 'https://sukabumikota.go.id',
        iconName: 'directions_car_outlined',
      ),
      LayananModel(
        id: '702',
        kodeInstansi: 'bpkpd',
        sektor: 'Kendaraan',
        judulLayanan: 'Cek Pajak Kendaraan (E-Samsat)',
        rawTitle: 'Cek Pajak Kendaraan',
        subjudul: 'Informasi tagihan pajak kendaraan bermotor & pendaftaran E-Samsat.',
        deskripsi: 'Layanan cek nominal tagihan pajak kendaraan bermotor daerah Kota Sukabumi.',
        persyaratan: ['Nomor Polisi (Plat No Kendaraan).', 'NIK Pemilik.'],
        urlPortal: 'https://bpkpd.sukabumikota.go.id',
        iconName: 'directions_bus_outlined',
      ),

      // --- SEKTOR KARIER ---
      LayananModel(
        id: '801',
        kodeInstansi: 'diskominfo',
        sektor: 'Karier',
        judulLayanan: 'Kartu Pencari Kerja (AK-1)',
        rawTitle: 'Kartu Kuning AK-1',
        subjudul: 'Penerbitan kartu tanda bukti pendaftaran pencari kerja (Kartu Kuning).',
        deskripsi: 'Layanan pendaftaran pencari kerja resmi bagi warga Kota Sukabumi yang melamar pekerjaan.',
        persyaratan: ['Fotokopi KTP Kota Sukabumi.', 'Fotokopi Ijazah Terakhir.', 'Pasfoto 3x4 (2 Lembar).'],
        urlPortal: 'https://sukabumikota.go.id',
        iconName: 'work_outlined',
      ),
      LayananModel(
        id: '802',
        kodeInstansi: 'diskominfo',
        sektor: 'Karier',
        judulLayanan: 'Info Lowongan Kerja & Pelatihan Disnaker',
        rawTitle: 'Sukabumi Kerja & Pelatihan',
        subjudul: 'Informasi bursa kerja resmi & pendaftaran pelatihan vokasi.',
        deskripsi: 'Layanan portal informasi lowongan kerja daerah dan pendaftaran pelatihan keahlian gratis.',
        persyaratan: ['KTP Kota Sukabumi.', 'Curriculum Vitae (CV).'],
        urlPortal: 'https://sukabumikota.go.id',
        iconName: 'badge_outlined',
      ),

      // --- SEKTOR REKREASI ---
      LayananModel(
        id: '901',
        kodeInstansi: 'diskominfo',
        sektor: 'Rekreasi',
        judulLayanan: 'Reservasi Lapangan & Taman Olahraga',
        rawTitle: 'Reservasi Fasilitas Olahraga',
        subjudul: 'Izin penggunaan gedung olahraga, stadion, & taman kota.',
        deskripsi: 'Layanan sewa dan reservasi penggunaan fasilitas olahraga dan taman publik Kota Sukabumi.',
        persyaratan: ['KTP Penanggung Jawab.', 'Surat Permohonan Izin Kegiatan.'],
        urlPortal: 'https://sukabumikota.go.id',
        iconName: 'sports_soccer_outlined',
      ),
      LayananModel(
        id: '902',
        kodeInstansi: 'diskominfo',
        sektor: 'Rekreasi',
        judulLayanan: 'Informasi Wisata & Pemandu Kota',
        rawTitle: 'Pemandu Wisata Sukabumi',
        subjudul: 'Informasi destinasi wisata, cagar budaya, & taman rekreasi.',
        deskripsi: 'Layanan informasi resmi objek wisata, kuliner khas, dan event pariwisata Kota Sukabumi.',
        persyaratan: ['Dapat diakses terbuka oleh warga & wisatawan.'],
        urlPortal: 'https://sukabumikota.go.id',
        iconName: 'attractions_outlined',
      ),
    ]);
  }

  // --- FUNGSI OPERASI CRUD SEKTOR ---
  List<SektorModel> getSektorList() => _sektorList;

  SektorModel? getSektorById(String id) {
    try {
      return _sektorList.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  void addSektor(SektorModel item) {
    _sektorList.add(item);
    notifyListeners();
  }

  void updateSektor(SektorModel updated) {
    int idx = _sektorList.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _sektorList[idx] = updated;
      notifyListeners();
    }
  }

  void deleteSektor(String id) {
    _sektorList.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void toggleSektorStatus(String id) async {
    int idx = _sektorList.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final current = _sektorList[idx];
      final newStatus = !current.isActive;
      _sektorList[idx] = current.copyWith(isActive: newStatus);
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('status_sektor_${current.id}', newStatus);
      } catch (_) {}

      _syncToRtdb('sektor_${current.id}', {
        'id': current.id,
        'type': 'sektor',
        'isActive': newStatus,
      });

      try {
        _db.collection('opd_status').doc('sektor_${current.id}').set({
          'id': current.id,
          'type': 'sektor',
          'isActive': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore sektor status sync error: $e');
      }
    }
  }

  // --- FUNGSI OPERASI CRUD INSTANSI ---
  List<InstansiModel> getInstansiList() => _instansiList;

  InstansiModel? getInstansiByKode(String kode) {
    try {
      return _instansiList.firstWhere(
        (e) => e.kodeInstansi.toLowerCase() == kode.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  void addInstansi(InstansiModel item) {
    _instansiList.add(item);
    notifyListeners();
  }

  void updateInstansi(InstansiModel updated) {
    int idx = _instansiList.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _instansiList[idx] = updated;
      notifyListeners();
    }
  }

  void deleteInstansi(String id) {
    _instansiList.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void toggleInstansiStatus(String id) async {
    int idx = _instansiList.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final current = _instansiList[idx];
      final newStatus = !current.isActive;
      _instansiList[idx] = current.copyWith(isActive: newStatus);
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('status_instansi_${current.id}', newStatus);
      } catch (_) {}

      _syncToRtdb('instansi_${current.id}', {
        'id': current.id,
        'kodeInstansi': current.kodeInstansi,
        'type': 'instansi',
        'isActive': newStatus,
      });

      try {
        _db.collection('opd_status').doc('instansi_${current.id}').set({
          'id': current.id,
          'kodeInstansi': current.kodeInstansi,
          'type': 'instansi',
          'isActive': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore instansi status sync error: $e');
      }
    }
  }

  // --- FUNGSI OPERASI CRUD LAYANAN ---
  List<LayananModel> getLayananList() => _layananList;

  List<LayananModel> getLayananByInstansi(String kodeInstansi) {
    return _layananList
        .where((e) => e.kodeInstansi.toLowerCase() == kodeInstansi.toLowerCase())
        .toList();
  }

  List<LayananModel> getLayananBySektor(String sektor) {
    return _layananList
        .where((e) => e.sektor.toLowerCase().contains(sektor.toLowerCase()) ||
            sektor.toLowerCase().contains(e.sektor.toLowerCase()))
        .toList();
  }

  void addLayanan(LayananModel item) {
    _layananList.add(item);
    notifyListeners();
  }

  void updateLayanan(LayananModel updated) {
    int idx = _layananList.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _layananList[idx] = updated;
      notifyListeners();
    }
  }

  void deleteLayanan(String id) {
    _layananList.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void toggleLayananStatus(String id) async {
    int idx = _layananList.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final current = _layananList[idx];
      final newStatus = !current.isActive;
      _layananList[idx] = current.copyWith(isActive: newStatus);
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('status_layanan_${current.id}', newStatus);
      } catch (_) {}

      _syncToRtdb('layanan_${current.id}', {
        'id': current.id,
        'type': 'layanan',
        'isActive': newStatus,
      });

      try {
        _db.collection('opd_status').doc('layanan_${current.id}').set({
          'id': current.id,
          'type': 'layanan',
          'isActive': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore layanan status sync error: $e');
      }
    }
  }
}
