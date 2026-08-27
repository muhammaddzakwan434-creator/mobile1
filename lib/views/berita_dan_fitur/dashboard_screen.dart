
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/views/instansi/instansi_screen.dart';
import 'package:mobile/views/instansi/generic_info_instansi_screen.dart';
import 'package:mobile/views/layanan/layanan_screen.dart';
import 'package:mobile/views/layanan/generic_layanan_sektor_screen.dart';
import 'package:mobile/views/berita_dan_fitur/detail_berita_screen.dart';
import 'package:mobile/views/informasi/help_center_screen.dart';
import 'package:mobile/services/opd_service.dart';
import 'package:mobile/services/user_service.dart';
import 'package:mobile/views/informasi/maintenance_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/widgets/guest_gatekeeper.dart';
import 'package:mobile/widgets/global_search_delegate.dart';
import 'package:mobile/widgets/smart_image.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  void _bukaModalPusatBantuan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Expanded(child: HelpCenterScreen()),
            ],
          ),
        ),
      ),
    );
  }

  String _currentDate = "";
  String _temperature = "26°C";
  String _feelsLike = "Terasa seperti 28°C";

  List<dynamic> _daftarBerita = [
    {
      'judul': 'KDM Ajak Orang Tua Batasi Penggunaan Gawai pada Anak Demi Kesehatan',
      'kategori': 'Kesehatan',
      'created_at': 'Kamis 16 Juli 2026',
      'gambar': 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=400',
    },
    {
      'judul': 'Diskominfo Kota Sukabumi Gelar Pelatihan Literasi Digital Warga',
      'kategori': 'Teknologi',
      'created_at': '2 Hari Lalu',
      'gambar': 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400',
    },
    {
      'judul': 'Peningkatan Pelayanan Publik melalui Sistem Pengaduan Online Terpadu',
      'kategori': 'Pelayanan',
      'created_at': '3 Hari Lalu',
      'gambar': 'https://images.unsplash.com/photo-1572949645841-094f3a9c4c94?w=400',
    },
    {
      'judul': 'Kota Sukabumi Raih Penghargaan Transparansi Publik 2026',
      'kategori': 'Prestasi',
      'created_at': '4 Hari Lalu',
      'gambar': 'https://images.unsplash.com/photo-1495020689067-958852a7765e?w=400',
    },
  ];

  int _currentNewsIndex = 0;
  Timer? _newsTimer;
  Timer? _clockTimer;

  // Banner Slideshow State
  final PageController _bannerPageController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;
  final List<String> _bannerImages = [
    'assets/poster/banner_layanan.jpeg',
    'assets/poster/banner_tentang_apk.jpeg',
  ];

  // Daftar ID Sektor yang terakhir kali berinteraksi (Recency Logic)
  List<String> _recentSectorIds = ['keluarga'];

  @override
  void initState() {
    super.initState();
    _startClock();
    _fetchRealtimeWeather();
    _fetchBeritaTerbaru();
    _startNewsAutoSlide();
    _startBannerAutoSlide();
    _loadSectorUsage();
  }

  Future<void> _loadSectorUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Mengambil daftar histori dari storage, defaultnya hanya Keluarga
      final List<String> history = prefs.getStringList('recent_sectors_history') ?? ['keluarga'];
      
      if (mounted) {
        setState(() {
          _recentSectorIds = history;
        });
      }
    } catch (_) {}
  }

  Future<void> _trackSectorUsage(String sectorId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Ambil list lama
      List<String> currentHistory = List.from(_recentSectorIds);
      
      // 2. Hapus jika ID sudah ada (agar tidak duplikat saat dipindah ke depan)
      currentHistory.remove(sectorId.toLowerCase());
      
      // 3. Masukkan ke urutan paling depan (index 0)
      currentHistory.insert(0, sectorId.toLowerCase());
      
      // 4. Batasi maksimal 5 sektor terakhir saja
      if (currentHistory.length > 5) {
        currentHistory = currentHistory.sublist(0, 5);
      }
      
      // 5. Simpan permanen ke SharedPreferences
      await prefs.setStringList('recent_sectors_history', currentHistory);
      
      if (mounted) {
        setState(() {
          _recentSectorIds = currentHistory;
        });
      }
    } catch (_) {}
  }

  List<_SectorItem> _getFavoriteSectors() {
    final allSektor = OpdService().getSektorList();
    final allSectorsMaster = <_SectorItem>[
      _SectorItem(
        id: 'keluarga',
        title: 'Keluarga',
        imagePath: 'assets/icon/keluarga.png',
        icon: Icons.family_restroom_rounded,
        routeBuilder: () => GenericLayananSektorScreen(sektor: allSektor.firstWhere((s) => s.title == 'Keluarga')),
      ),
      _SectorItem(
        id: 'pendidikan',
        title: 'Pendidikan',
        imagePath: 'assets/icon/pendidikan.png',
        icon: Icons.school_rounded,
        routeBuilder: () => GenericLayananSektorScreen(sektor: allSektor.firstWhere((s) => s.title == 'Pendidikan')),
      ),
      _SectorItem(
        id: 'usaha',
        title: 'Usaha',
        imagePath: 'assets/icon/usaha.png',
        icon: Icons.storefront_rounded,
        routeBuilder: () => GenericLayananSektorScreen(sektor: allSektor.firstWhere((s) => s.title == 'Usaha')),
      ),
      _SectorItem(
        id: 'lingkungan',
        title: 'Lingkungan',
        imagePath: 'assets/icon/lingkungan.png',
        icon: Icons.home_work_rounded,
        routeBuilder: () => GenericLayananSektorScreen(sektor: allSektor.firstWhere((s) => s.title.contains('Lingkungan'))),
      ),
      _SectorItem(
        id: 'kendaraan',
        title: 'Kendaraan',
        imagePath: 'assets/icon/kendaraan.png',
        icon: Icons.directions_car_rounded,
        routeBuilder: () => GenericLayananSektorScreen(sektor: allSektor.firstWhere((s) => s.title == 'Kendaraan')),
      ),
      _SectorItem(
        id: 'kesehatan',
        title: 'Kesehatan',
        imagePath: 'assets/icon/kesehatan.png',
        icon: Icons.local_hospital_rounded,
        routeBuilder: () => GenericLayananSektorScreen(sektor: allSektor.firstWhere((s) => s.title == 'Kesehatan')),
      ),
    ];

    // Mengambil item sektor berdasarkan urutan di _recentSectorIds
    List<_SectorItem> favoriteList = [];
    for (String id in _recentSectorIds) {
      final match = allSectorsMaster.where((s) => s.id == id).toList();
      if (match.isNotEmpty) {
        favoriteList.add(match.first);
      }
    }

    // Fallback jika kosong
    if (favoriteList.isEmpty) {
      return [allSectorsMaster.first];
    }
    
    return favoriteList.take(4).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _newsTimer?.cancel();
    _clockTimer?.cancel();
    _bannerTimer?.cancel();
    _bannerPageController.dispose();
    super.dispose();
  }

  void _startClock() {
    _updateFormattedDate();
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateFormattedDate();
    });
  }

  void _updateFormattedDate() {
    final now = DateTime.now();
    final hariMap = {1: 'Senin', 2: 'Selasa', 3: 'Rabu', 4: 'Kamis', 5: 'Jum’at', 6: 'Sabtu', 7: 'Minggu'};
    final bulanMap = {
      1: 'Januari', 2: 'Februari', 3: 'Maret', 4: 'April', 5: 'Mei', 6: 'Juni',
      7: 'Juli', 8: 'Agustus', 9: 'September', 10: 'Oktober', 11: 'November', 12: 'Desember'
    };
    final String hari = hariMap[now.weekday] ?? '';
    final String bulan = bulanMap[now.month] ?? '';
    if (mounted) {
      setState(() {
        _currentDate = "$hari, ${now.day} $bulan ${now.year}";
      });
    }
  }

  Future<void> _fetchRealtimeWeather() async {
    try {
      final response = await ApiService.get('weather'); // Assume endpoint mapped in ApiService or handle specialized logic here
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['current_weather'] != null) {
          final temp = data['current_weather']['temperature'];
          if (mounted) {
            setState(() {
              _temperature = "${temp.round()}°C";
              _feelsLike = "Terasa seperti ${(temp + 2).round()}°C";
            });
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchBeritaTerbaru() async {
    try {
      final response = await ApiService.get('berita');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && (data['data'] as List).isNotEmpty) {
          final list = (data['data'] as List).take(5).map((item) {
            return {
              'judul': item['title'] ?? 'Berita Terbaru Kota Sukabumi',
              'kategori': item['category'] ?? 'Umum',
              'created_at': item['date'] ?? 'Baru Saja',
              'gambar': item['image'] ?? 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=400',
            };
          }).toList();
          if (mounted) {
            setState(() {
              _daftarBerita = list;
            });
          }
        }
      }
    } catch (_) {}
  }

  void _startNewsAutoSlide() {
    _newsTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && _daftarBerita.isNotEmpty) {
        setState(() {
          _currentNewsIndex = (_currentNewsIndex + 1) % _daftarBerita.length;
        });
      }
    });
  }

  void _startBannerAutoSlide() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _bannerImages.isNotEmpty && _bannerPageController.hasClients) {
        final nextIndex = (_currentBannerIndex + 1) % _bannerImages.length;
        _bannerPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _handleRefresh() async {
    await _fetchRealtimeWeather();
    await _fetchBeritaTerbaru();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildBannerSlideshow() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: _bannerPageController,
              onPageChanged: (index) {
                if (mounted) {
                  setState(() {
                    _currentBannerIndex = index;
                  });
                }
              },
              itemCount: _bannerImages.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  _bannerImages[index],
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF0A1E33),
                    child: const Center(
                      child: Text(
                        'Layanan Utama Kota Sukabumi',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_bannerImages.length, (index) {
            final bool isActive = index == _currentBannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFE8A33D) : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: const Color(0xFF0A1E33),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================================================
                // 1. TOP WHITE HEADER (LOGO SUKABUMI & WEATHER BADGE)
                // =========================================================
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // LOGO SUKABUMI ONE ACCESS
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 38,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.account_balance_rounded,
                              color: Color(0xFF0A1E33),
                              size: 32,
                            ),
                          ),
                        ],
                      ),

                      // NAVY BLUE WEATHER PILL BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1E33),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'SUKABUMI',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Text(
                                  _temperature,
                                  style: const TextStyle(
                                    color: Color(0xFFE8A33D),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Text(
                                  _feelsLike,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.5,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.wb_sunny_rounded,
                              color: Color(0xFFE8A33D),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // =========================================================
                // 2. NAVY BANNER (USER GREETING)
                // =========================================================
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: const Color(0xFF0A1E33),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Selamat Datang',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      // GREETING & TANGGAL & FOTO PROFIL (DYNAMIC & REAL-TIME SYNC)
                      ListenableBuilder(
                        listenable: UserService(),
                        builder: (context, _) {
                          final user = UserService().currentUser;
                          
                          return Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _currentDate.isEmpty ? 'Rabu, 29 Juli 2026' : _currentDate,
                                    style: const TextStyle(
                                      color: Color(0xFFE8A33D),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFE8A33D), width: 1.5),
                                  color: Colors.white,
                                ),
                                child: ClipOval(
                                  child: user.profileImagePath.isNotEmpty
                                      ? SmartImage(
                                          imagePath: user.profileImagePath,
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.cover,
                                        )
                                      : Center(
                                          child: Text(
                                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0A1E33),
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // =========================================================
                // 3. HERO IMAGE BANNER & FLOATING SEARCH BAR
                // =========================================================
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    // BACKGROUND HERO IMAGE BANNER
                    Container(
                      width: double.infinity,
                      height: 220,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage("https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF0A1E33).withOpacity(0.85),
                              const Color(0xFF0A1E33).withOpacity(0.92),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'SUKABUMI ONE ACCESS',
                              style: TextStyle(
                                color: Color(0xFFE8A33D),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 6),
                            RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Pusat Layanan ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Kota Sukabumi.',
                                    style: TextStyle(
                                      color: Color(0xFFE8A33D),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Temukan kemudahan mengakses berbagai layanan informasi dari seluruh instansi Pemerintah Kota Sukabumi dalam satu pintu.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11.5,
                                height: 1.4,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                    ),

                    // FLOATING SEARCH BAR (Cari Layanan...)
                    Positioned(
                      bottom: -22,
                      left: 16,
                      right: 16,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE8A33D), width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x20000000),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          readOnly: true,
                          onTap: () {
                            showSearch(
                              context: context,
                              delegate: GlobalSearchDelegate(),
                            );
                          },
                          style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                          decoration: InputDecoration(
                            hintText: 'Cari Layanan, Dinas, atau Bantuan...',
                            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontFamily: 'Poppins'),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            suffixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0A1E33), size: 24),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 38),

                // =========================================================
                // 4. SEKSI LAYANAN FAVORIT (HEADER NAVY & CARD KELUARGA)
                // =========================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: const Color(0xFF0A1E33),
                  child: const Row(
                    children: [
                      Icon(Icons.thumb_up_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Layanan ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text: 'Favorit',
                              style: TextStyle(
                                color: Color(0xFFE8A33D),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
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
                      // KARTU LAYANAN FAVORIT DINAMIS (UPDATED BASED ON USER USAGE)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _getFavoriteSectors().map((sector) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () {
                                  GuestGatekeeper.checkAccess(
                                    context,
                                    onGranted: () {
                                      _trackSectorUsage(sector.id);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => sector.routeBuilder()),
                                      );
                                    },
                                  );
                                },
                                child: Container(
        width: 115,
        height: 110,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFF00A3FF), width: 2),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x1500A3FF),
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        sector.icon,
                                        color: const Color(0xFF0A1E33),
                                        size: 46,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        sector.title,
                                        style: const TextStyle(
                                          color: Color(0xFF0A1E33),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins',
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // BANNER SLIDESHOW LAYANAN UTAMA (AUTOMATIC IMAGE CAROUSEL)
                      _buildBannerSlideshow(),
                    ],
                  ),
                ),

                // =========================================================
                // 5. SEKSI FASE KEHIDUPAN (DARK NAVY BOX WITH 10 SEKTOR & 7 CARDS)
                // =========================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: const Color(0xFF0A1E33),
                  child: const Row(
                    children: [
                      Icon(Icons.assignment_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Fase ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text: 'Kehidupan',
                              style: TextStyle(
                                color: Color(0xFFE8A33D),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
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
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1E33),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BADGE 10 SEKTOR
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8A33D),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Sektor',
                              style: TextStyle(
                                color: Color(0xFF0A1E33),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),

                        // GRID FASE KEHIDUPAN (DYNAMIC & REAL-TIME MAINTENANCE)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: ListenableBuilder(
                            listenable: OpdService(),
                            builder: (context, _) {
                              final allSektor = OpdService().getSektorList();
                              final displaySektor = allSektor.take(6).toList(); // Show first 6

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: displaySektor.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.92,
                                ),
                                itemBuilder: (context, index) {
                                  final sektor = displaySektor[index];
                                  
                                  // Map Icon Name to IconData
                                  IconData displayIcon = Icons.help_outline_rounded;
                                  if (sektor.iconName == 'family_restroom_rounded') displayIcon = Icons.family_restroom_rounded;
                                  if (sektor.iconName == 'school_rounded') displayIcon = Icons.school_rounded;
                                  if (sektor.iconName == 'store_rounded') displayIcon = Icons.storefront_rounded;
                                  if (sektor.iconName == 'home_work_rounded') displayIcon = Icons.home_work_rounded;
                                  if (sektor.iconName == 'directions_car_rounded') displayIcon = Icons.directions_car_rounded;
                                  if (sektor.iconName == 'local_hospital_rounded') displayIcon = Icons.local_hospital_rounded;

                                  return _buildLifePhaseCard(
                                    context: context,
                                    title: sektor.title,
                                    imagePath: sektor.imagePath,
                                    fallbackIcon: displayIcon,
                                    isMaintenance: !sektor.isActive,
                                    onTap: () {
                                      GuestGatekeeper.checkAccess(
                                        context,
                                        onGranted: () {
                                          _trackSectorUsage(sektor.title.toLowerCase());
                                          
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => GenericLayananSektorScreen(sektor: sektor),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 14),

                        // TOMBOL KUNING LIHAT SEMUA SEKTOR
                        GestureDetector(
                          onTap: () {
                            GuestGatekeeper.checkAccess(
                              context,
                              onGranted: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const LayananScreen()));
                              },
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8A33D),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Lihat Semua Sektor',
                                style: TextStyle(
                                  color: Color(0xFF0A1E33),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // =========================================================
                // 6. SEKSI INSTANSI (OPD DINAS)
                // =========================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: const Color(0xFF0A1E33),
                  child: const Row(
                    children: [
                      Icon(Icons.account_balance_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Instansi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListenableBuilder(
                    listenable: OpdService(),
                    builder: (context, _) {
                      final diskominfo = OpdService().getInstansiByKode('diskominfo');
                      final dpmptsp = OpdService().getInstansiByKode('dpmptsp');
                      final dkp3 = OpdService().getInstansiByKode('dkp3');

                      return Row(
                        children: [
                          _buildInstansiItem(
                            context: context,
                            title: 'Diskominfo',
                            imagePath: 'assets/images/diskominfo.png',
                            fallbackIcon: Icons.computer_rounded,
                            isMaintenance: diskominfo != null && !diskominfo.isActive,
                            onTap: () {
                              if (diskominfo != null) {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => GenericInfoInstansiScreen(instansi: diskominfo)));
                              }
                            },
                          ),
                          const SizedBox(width: 16),
                          _buildInstansiItem(
                            context: context,
                            title: 'DPMPTSP',
                            imagePath: 'assets/images/dpmptsp.png',
                            fallbackIcon: Icons.store_rounded,
                            isMaintenance: dpmptsp != null && !dpmptsp.isActive,
                            onTap: () {
                              if (dpmptsp != null) {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => GenericInfoInstansiScreen(instansi: dpmptsp)));
                              }
                            },
                          ),
                          const SizedBox(width: 16),
                          _buildInstansiItem(
                            context: context,
                            title: 'DKP3',
                            imagePath: 'assets/images/dkp3.png',
                            fallbackIcon: Icons.grass_rounded,
                            isMaintenance: dkp3 != null && !dkp3.isActive,
                            onTap: () {
                              if (dkp3 != null) {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => GenericInfoInstansiScreen(instansi: dkp3)));
                              }
                            },
                          ),
                          const SizedBox(width: 6),
                          _buildInstansiItem(
                            context: context,
                            title: 'Lainnya',
                            fallbackIcon: Icons.grid_view_rounded,
                            width: 54,
                            height: 38,
                            isExpanded: false,
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const InstansiScreen()));
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // =========================================================
                // 7. SEKSI SUKABUMI HARI INI (BERITA UPDATE & SLIDER)
                // =========================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: const Color(0xFF0A1E33),
                  child: const Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Sukabumi ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text: 'Hari Ini',
                              style: TextStyle(
                                color: Color(0xFFE8A33D),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
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
                    children: [
                      // FEATURED NEWS SLIDER CARD (MATCH SCREENSHOT 3)
                      if (_daftarBerita.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            final currentBerita = _daftarBerita[_currentNewsIndex];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailBeritaScreen(
                                  judul: currentBerita['judul'].toString(),
                                  kategori: currentBerita['kategori'].toString(),
                                  tanggal: currentBerita['created_at'].toString(),
                                  gambar: currentBerita['gambar'].toString(),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 190,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              image: DecorationImage(
                                image: NetworkImage(_daftarBerita[_currentNewsIndex]['gambar'].toString()),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: const LinearGradient(
                                  colors: [Colors.transparent, Colors.black87],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8A33D),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Topik Hangat',
                                          style: TextStyle(
                                            color: Color(0xFF0A1E33),
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${_daftarBerita[_currentNewsIndex]['kategori']} • ${_daftarBerita[_currentNewsIndex]['created_at']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _daftarBerita[_currentNewsIndex]['judul'].toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins',
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(_daftarBerita.length, (index) {
                                          return Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 3),
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              color: index == _currentNewsIndex
                                                  ? const Color(0xFFE8A33D)
                                                  : Colors.white.withOpacity(0.4),
                                              shape: BoxShape.circle,
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 14),

                      // DAFTAR 3 KARTU BERITA DARK NAVY (MATCH SCREENSHOT 3)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 3,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = _daftarBerita[index % _daftarBerita.length];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailBeritaScreen(
                                    judul: item['judul'].toString(),
                                    kategori: item['kategori'].toString(),
                                    tanggal: item['created_at'].toString(),
                                    gambar: item['gambar'].toString(),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A1E33),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item['gambar'].toString(),
                                      width: 64,
                                      height: 54,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 64,
                                        height: 54,
                                        color: Colors.blueGrey,
                                        child: const Icon(Icons.newspaper, color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['judul'].toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins',
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item['kategori']} • ${item['created_at']}',
                                          style: const TextStyle(
                                            color: Color(0xFFE8A33D),
                                            fontSize: 10,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // =========================================================
                // 8. CALL TO ACTION KUNING (BANER PERTANYAAN SUKABUMI ONE ACCESS)
                // =========================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: InkWell(
                    onTap: () => _bukaModalPusatBantuan(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8A33D),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0A1E33),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Sampaikan pertanyaan terkait Sukabumi One Access atau layanan publik di Kota Sukabumi',
                              style: TextStyle(
                                color: Color(0xFF0A1E33),
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFF0A1E33), size: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // =========================================================
                // 9. TOMBOL KEMBALI KE ATAS (DARK NAVY BUTTON)
                // =========================================================
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _scrollToTop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A1E33),
                      foregroundColor: const Color(0xFFE8A33D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.unfold_less_rounded, size: 18),
                    label: const Text(
                      'Kembali ke atas',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLifePhaseCard({
    required BuildContext context,
    required String title,
    String? imagePath,
    required IconData fallbackIcon,
    required VoidCallback onTap,
    bool isMaintenance = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ColorFiltered(
        colorFilter: isMaintenance 
          ? const ColorFilter.mode(Colors.grey, BlendMode.saturation) 
          : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0), // Beri ruang napas agar tidak sesak
                      child: SmartImage(
                        imagePath: imagePath ?? '',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain, // Agar gambar utuh, tidak pernah terpotong
                        fallbackIcon: fallbackIcon,
                        fallbackColor: const Color(0xFF0A1E33),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF123457).withOpacity(0.12),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8A33D),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // MAINTENANCE OVERLAY LABEL
              if (isMaintenance)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'MT',
                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstansiItem({
    required BuildContext context,
    required String title,
    String? imagePath,
    required IconData fallbackIcon,
    required VoidCallback onTap,
    double? width,
    double? height,
    bool isExpanded = true,
    bool isMaintenance = false,
  }) {
    final Widget content = GestureDetector(
      onTap: () {
        GuestGatekeeper.checkAccess(
          context, 
          onGranted: () {
            if (isMaintenance) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MaintenanceScreen(
                    title: title,
                    category: 'Instansi OPD',
                  ),
                ),
              );
              return;
            }
            onTap();
          },
        );
      },
      child: Column(
        children: [
          ColorFiltered(
            colorFilter: isMaintenance 
              ? const ColorFilter.mode(Colors.grey, BlendMode.saturation) 
              : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
            child: Container(
              width: width,
              height: height ?? 85,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isMaintenance ? Colors.grey : const Color(0xFF0A1E33), 
                  width: 1.2
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: imagePath != null
                        ? Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              fallbackIcon,
                              color: const Color(0xFF0A1E33),
                              size: height != null ? (height * 0.65) : 32,
                            ),
                          )
                        : Icon(
                            fallbackIcon,
                            color: const Color(0xFF0A1E33),
                            size: height != null ? (height * 0.65) : 32,
                          ),
                  ),
                  if (isMaintenance)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Icon(Icons.build_circle_rounded, color: Colors.red.shade700, size: 12),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: isMaintenance ? Colors.grey : Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    return isExpanded ? Expanded(child: content) : content;
  }
}

class _SectorItem {
  final String id;
  final String title;
  final String imagePath;
  final IconData icon;
  final Widget Function() routeBuilder;

  _SectorItem({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.icon,
    required this.routeBuilder,
  });
}