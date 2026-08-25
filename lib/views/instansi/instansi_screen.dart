import 'package:flutter/material.dart';
import 'package:mobile/services/opd_service.dart';
import 'package:mobile/widgets/smart_image.dart';
import 'package:mobile/views/instansi/info_disdukcapil.dart';
import 'package:mobile/views/instansi/info_diskominfo.dart';
import 'package:mobile/views/instansi/info_dpmptsp.dart';
import 'package:mobile/views/instansi/info_dkp3.dart';
import 'package:mobile/views/instansi/info_bpkpd.dart';
import 'package:mobile/widgets/guest_gatekeeper.dart';
import 'package:mobile/views/informasi/maintenance_screen.dart';

class InstansiScreen extends StatefulWidget {
  const InstansiScreen({super.key});

  @override
  State<InstansiScreen> createState() => _InstansiScreenState();
}

class _InstansiScreenState extends State<InstansiScreen> {
  final OpdService _opdService = OpdService();

  @override
  void initState() {
    super.initState();
    _opdService.addListener(_refresh);
  }

  @override
  void dispose() {
    _opdService.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF123457);
    const Color accentColor = Color(0xFFE8A33D);

    final instansiList = _opdService.getInstansiList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: CustomScrollView(
        slivers: [
          // APP BAR NAVY HEADER
          SliverAppBar(
            expandedHeight: 140.0,
            floating: false,
            pinned: true,
            backgroundColor: primaryColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, Color(0xFF1B4A7A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.account_balance_rounded,
                              color: accentColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Instansi Daerah',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Daftar Organisasi Perangkat Daerah (OPD) Pemkot Sukabumi.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ISI DAFTAR INSTANSI DINAMIS
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = instansiList[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: item.isActive ? primaryColor : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 52,
                        height: 52,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ColorFiltered(
                          colorFilter: item.isActive 
                            ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                            : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                          child: SmartImage(
                            imagePath: item.logoPath,
                            width: 44,
                            height: 44,
                            fit: BoxFit.contain,
                            fallbackIcon: Icons.account_balance_rounded,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            item.namaSingkat,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          if (!item.isActive)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade700,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'MAINTENANCE',
                                style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.namaLengkap,
                          style: TextStyle(
                            color: item.isActive ? Colors.white70 : Colors.white.withOpacity(0.5),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: Icon(
                        item.isActive ? Icons.arrow_forward_ios_rounded : Icons.build_circle_rounded,
                        size: 18,
                        color: item.isActive ? accentColor : Colors.white60,
                      ),
                      onTap: () {
                        GuestGatekeeper.checkAccess(
                          context,
                          onGranted: () {
                            if (!item.isActive) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MaintenanceScreen(
                                    title: item.namaLengkap,
                                    category: 'Instansi ${item.namaSingkat}',
                                  ),
                                ),
                              );
                              return;
                            }

                            final kode = item.kodeInstansi.toLowerCase();
                            if (kode == 'disdukcapil') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const InfoDisdukcapil()),
                              );
                            } else if (kode == 'diskominfo') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const InfoDiskominfo()),
                              );
                            } else if (kode == 'dpmptsp') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const InfoDpmptsp()),
                              );
                            } else if (kode == 'dkp3') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const InfoDkp3()),
                              );
                            } else if (kode == 'bpkpd') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const InfoBpkpd()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Membuka profil instansi ${item.namaLengkap}'),
                                  backgroundColor: primaryColor,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  );
                },
                childCount: instansiList.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
