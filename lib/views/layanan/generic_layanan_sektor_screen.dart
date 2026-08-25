import 'package:flutter/material.dart';
import '../instansi/mocilegit_webview_screen.dart';
import '../../widgets/guest_gatekeeper.dart';
import '../informasi/maintenance_screen.dart';
import '../../services/opd_service.dart';
import '../../models/layanan_model.dart';
import '../../models/sektor_model.dart';

class GenericLayananSektorScreen extends StatelessWidget {
  final SektorModel sektor;

  const GenericLayananSektorScreen({
    super.key,
    required this.sektor,
  });

  void _tampilkanDialogRedireksi(BuildContext context, String judulLayanan, String urlPortal) {
    const Color primaryColor = Color(0xFF123457);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: primaryColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Layanan Digital Resmi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda akan diarahkan ke Formulir Permohonan Digital "$judulLayanan" resmi terpadu.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Colors.black87,
                  height: 1.45,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MocilegitWebviewScreen(
                          title: 'Pengajuan $judulLayanan',
                          url: urlPortal,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Lanjutkan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _mapIcon(String? iconName) {
    switch (iconName) {
      case 'badge_outlined':
        return Icons.badge_rounded;
      case 'family_restroom_outlined':
        return Icons.family_restroom_rounded;
      case 'child_care_outlined':
        return Icons.child_care_rounded;
      case 'child_friendly_outlined':
        return Icons.child_friendly_rounded;
      case 'description_outlined':
        return Icons.description_rounded;
      case 'move_to_inbox_outlined':
        return Icons.move_to_inbox_rounded;
      case 'school_outlined':
        return Icons.school_rounded;
      case 'store_outlined':
        return Icons.storefront_rounded;
      case 'home_work_outlined':
        return Icons.home_work_rounded;
      case 'directions_car_outlined':
        return Icons.directions_car_rounded;
      case 'local_hospital_outlined':
        return Icons.local_hospital_rounded;
      case 'warning_amber_outlined':
        return Icons.warning_amber_rounded;
      case 'work_outlined':
        return Icons.work_rounded;
      case 'gavel_outlined':
        return Icons.gavel_rounded;
      case 'sports_soccer_outlined':
        return Icons.sports_soccer_rounded;
      case 'receipt_long_outlined':
        return Icons.receipt_long_rounded;
      case 'real_estate_agent_outlined':
        return Icons.real_estate_agent_rounded;
      case 'print_outlined':
        return Icons.print_rounded;
      case 'pets_outlined':
        return Icons.pets_rounded;
      case 'medical_services_outlined':
        return Icons.medical_services_rounded;
      case 'grass_outlined':
        return Icons.grass_rounded;
      case 'workspace_premium_outlined':
        return Icons.workspace_premium_rounded;
      case 'directions_bus_outlined':
        return Icons.directions_bus_rounded;
      case 'attractions_outlined':
        return Icons.attractions_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  IconData _mapSektorIcon(String? iconName) {
    switch (iconName) {
      case 'family_restroom_rounded':
        return Icons.family_restroom_rounded;
      case 'school_rounded':
        return Icons.school_rounded;
      case 'store_rounded':
        return Icons.store_rounded;
      case 'home_work_rounded':
        return Icons.home_work_rounded;
      case 'directions_car_rounded':
        return Icons.directions_car_rounded;
      case 'local_hospital_rounded':
        return Icons.local_hospital_rounded;
      case 'warning_amber_rounded':
        return Icons.warning_amber_rounded;
      case 'work_rounded':
        return Icons.work_rounded;
      case 'sports_soccer_rounded':
        return Icons.sports_soccer_rounded;
      case 'gavel_rounded':
        return Icons.gavel_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF123457);
    const Color accentColor = Color(0xFFFFAC33);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Sektor ${sektor.title}',
          style: const TextStyle(
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
            // HEADER HERO SEKTOR
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              color: primaryColor,
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accentColor, width: 1.5),
                    ),
                    child: Icon(
                      _mapSektorIcon(sektor.iconName),
                      color: primaryColor,
                      size: 38,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sektor.title.toUpperCase(),
                          style: const TextStyle(
                            color: accentColor,
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          sektor.desc,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
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
                  Text(
                    'Pilih Jenis Layanan ${sektor.title}',
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 16.5,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Layanan terpadu yang dapat diakses secara digital melalui satu pintu.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 14),

                  ListenableBuilder(
                    listenable: OpdService(),
                    builder: (context, _) {
                      final allLayanan = OpdService().getLayananBySektor(sektor.title);
                      
                      if (allLayanan.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text('Belum ada layanan tersedia di sektor ini.', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
                          ),
                        );
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
                          final instansi = OpdService().getInstansiByKode(item.kodeInstansi);
                          final bool isMaintenance = !sektor.isActive || 
                                                     (instansi != null && !instansi.isActive) || 
                                                     !item.isActive;

                          return GestureDetector(
                            onTap: () {
                              GuestGatekeeper.checkAccess(
                                context,
                                onGranted: () {
                                  if (isMaintenance) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MaintenanceScreen(
                                          title: item.rawTitle,
                                          category: 'Layanan ${sektor.title} (${item.kodeInstansi.toUpperCase()})',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  _tampilkanDialogRedireksi(
                                    context,
                                    item.rawTitle,
                                    item.urlPortal,
                                  );
                                },
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
                                  border: Border.all(color: primaryColor, width: 1.5),
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
                                        Expanded(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: primaryColor,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                              ),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                _mapIcon(item.iconName),
                                                color: const Color(0xFFE8A33D),
                                                size: 58,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 68,
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
                                                  color: primaryColor,
                                                  fontSize: 13.5,
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
                                                  fontSize: 9.5,
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
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade700,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.build_rounded, color: Colors.white, size: 10),
                                              SizedBox(width: 4),
                                              Text(
                                                'MAINTENANCE',
                                                style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                                              ),
                                            ],
                                          ),
                                        ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
