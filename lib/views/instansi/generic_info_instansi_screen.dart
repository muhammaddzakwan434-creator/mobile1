import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile/services/opd_service.dart';
import 'package:mobile/models/instansi_model.dart';
import 'package:mobile/models/layanan_model.dart';
import 'package:mobile/views/layanan/detail_layanan_usaha.dart';
import 'package:mobile/views/informasi/maintenance_screen.dart';
import 'package:mobile/widgets/smart_image.dart';
import 'package:mobile/widgets/guest_gatekeeper.dart';

class GenericInfoInstansiScreen extends StatefulWidget {
  final InstansiModel instansi;

  const GenericInfoInstansiScreen({
    super.key,
    required this.instansi,
  });

  @override
  State<GenericInfoInstansiScreen> createState() => _GenericInfoInstansiScreenState();
}

class _GenericInfoInstansiScreenState extends State<GenericInfoInstansiScreen> {
  bool _isTentangExpanded = true;
  final OpdService _opdService = OpdService();

  Future<void> _bukaGoogleMaps() async {
    final String query = widget.instansi.mapsQuery;
    final Uri uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  IconData _getIconForLayanan(String iconName) {
    switch (iconName) {
      case 'badge_outlined': return Icons.badge_rounded;
      case 'family_restroom_outlined': return Icons.family_restroom_rounded;
      case 'child_care_outlined': return Icons.child_care_rounded;
      case 'child_friendly_outlined': return Icons.child_friendly_rounded;
      case 'description_outlined': return Icons.description_rounded;
      case 'move_to_inbox_outlined': return Icons.move_to_inbox_rounded;
      case 'school_outlined': return Icons.school_rounded;
      case 'store_outlined': return Icons.storefront_rounded;
      case 'home_work_outlined': return Icons.home_work_rounded;
      case 'directions_car_outlined': return Icons.directions_car_rounded;
      case 'local_hospital_outlined': return Icons.local_hospital_rounded;
      case 'warning_amber_outlined': return Icons.warning_amber_rounded;
      case 'work_outlined': return Icons.work_rounded;
      case 'gavel_outlined': return Icons.gavel_rounded;
      case 'sports_soccer_outlined': return Icons.sports_soccer_rounded;
      case 'receipt_long_outlined': return Icons.receipt_long_rounded;
      case 'real_estate_agent_outlined': return Icons.real_estate_agent_rounded;
      case 'print_outlined': return Icons.print_rounded;
      case 'pets_outlined': return Icons.pets_rounded;
      case 'medical_services_outlined': return Icons.medical_services_rounded;
      case 'grass_outlined': return Icons.grass_rounded;
      default: return Icons.assignment_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF123457);
    const Color accentColor = Color(0xFFE8A33D);

    if (!widget.instansi.isActive) {
      return MaintenanceScreen(
        title: widget.instansi.namaLengkap,
        category: 'Instansi ${widget.instansi.namaSingkat}',
      );
    }

    final layananDinas = _opdService.getLayananByInstansi(widget.instansi.kodeInstansi);

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
          'Instansi',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO HEADER (LOGO & NAMA)
            Container(
              width: double.infinity,
              height: 124,
              color: primaryColor,
              child: ClipRect(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Align(
                        alignment: const Alignment(0.4, 0.0),
                        child: Opacity(
                          opacity: 0.22,
                          child: SmartImage(
                            imagePath: widget.instansi.logoPath,
                            width: 320,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 86,
                            height: 86,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x25000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                            child: SmartImage(
                              imagePath: widget.instansi.logoPath,
                              fit: BoxFit.contain,
                              fallbackIcon: Icons.account_balance_rounded,
                              fallbackColor: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.instansi.namaSingkat,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  widget.instansi.namaLengkap,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontFamily: 'Poppins',
                                    height: 1.3,
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
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. KARTU INFORMASI
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0C000000),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                color: accentColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Informasi Instansi',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoItem(Icons.location_on_outlined, 'ALAMAT', widget.instansi.alamat),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: Color(0xFFEEEEEE))),
                        _buildInfoItem(Icons.access_time_rounded, 'JAM OPERASIONAL', widget.instansi.jamOperasional),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: Color(0xFFEEEEEE))),
                        _buildInfoItem(Icons.phone_outlined, 'KONTAK', widget.instansi.kontak),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 3. MAPS PREVIEW
                  GestureDetector(
                    onTap: _bukaGoogleMaps,
                    child: Container(
                      width: double.infinity,
                      height: 175,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300, width: 1.2),
                        boxShadow: const [
                          BoxShadow(color: Color(0x0C000000), blurRadius: 6, offset: Offset(0, 3))
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: const Color(0xFFE8ECEF),
                              child: CustomPaint(painter: MapPatternPainterGeneric()),
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(6)),
                                    child: Text(
                                      '${widget.instansi.namaSingkat} Kota Sukabumi',
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 40),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 4. LAYANAN TERSEDIA
                  const Text(
                    'Layanan Tersedia',
                    style: TextStyle(color: primaryColor, fontSize: 17.5, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  layananDinas.isEmpty 
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Belum ada layanan digital terintegrasi.', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey))))
                    : SizedBox(
                        height: 108,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: layananDinas.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final item = layananDinas[index];
                            return GestureDetector(
                              onTap: () {
                                GuestGatekeeper.checkAccess(context, onGranted: () {
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
                                });
                              },
                              child: Container(
                                width: 92,
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade300, width: 1.3),
                                  boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 6, offset: Offset(0, 3))],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(_getIconForLayanan(item.iconName), color: primaryColor, size: 38),
                                    const SizedBox(height: 6),
                                    Text(item.rawTitle, textAlign: TextAlign.center, style: const TextStyle(color: primaryColor, fontSize: 10.5, fontWeight: FontWeight.bold, fontFamily: 'Poppins', height: 1.15), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                  const SizedBox(height: 22),

                  // 5. TENTANG INSTANSI
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, width: 1.2),
                      boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 6, offset: Offset(0, 3))],
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => setState(() => _isTentangExpanded = !_isTentangExpanded),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Tentang Instansi', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                                Icon(_isTentangExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Colors.black87, size: 28),
                              ],
                            ),
                          ),
                        ),
                        if (_isTentangExpanded)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                                const SizedBox(height: 14),
                                Text(widget.instansi.deskripsi, style: TextStyle(color: Colors.grey.shade800, fontSize: 13, height: 1.5, fontFamily: 'Poppins')),
                                if (widget.instansi.tugasFungsi.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  Text('Tugas dan Fungsi Utama :', style: TextStyle(color: Colors.grey.shade800, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                                  const SizedBox(height: 8),
                                  ...widget.instansi.tugasFungsi.map((tf) => _buildBulletPoint(tf)),
                                ],
                              ],
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

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey.shade800, fontSize: 12.5, height: 1.5, fontFamily: 'Poppins'))),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey.shade700, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 0.8, fontFamily: 'Poppins')),
              const SizedBox(height: 2),
              Text(content, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins', height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }
}

class MapPatternPainterGeneric extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()..color = Colors.white..strokeWidth = 6..style = PaintingStyle.stroke;
    final mainRoadPaint = Paint()..color = const Color(0xFF4A90E2).withOpacity(0.5)..strokeWidth = 8..style = PaintingStyle.stroke;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.4);
    path1.lineTo(size.width, size.height * 0.6);
    canvas.drawPath(path1, mainRoadPaint);

    final path2 = Path();
    path2.moveTo(size.width * 0.3, 0);
    path2.lineTo(size.width * 0.7, size.height);
    canvas.drawPath(path2, roadPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
