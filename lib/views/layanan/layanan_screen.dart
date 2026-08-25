import 'package:flutter/material.dart';
import 'package:mobile/views/layanan/generic_layanan_sektor_screen.dart';
import 'package:mobile/views/layanan/form_pengajuan_screen.dart';
import 'package:mobile/widgets/smart_image.dart';
import 'package:mobile/widgets/guest_gatekeeper.dart';

import 'package:mobile/services/opd_service.dart';
import 'package:mobile/views/informasi/maintenance_screen.dart';

class LayananScreen extends StatelessWidget {
  const LayananScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A1E33);
    const Color accentColor = Color(0xFFE8A33D);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
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
        child: ListenableBuilder(
          listenable: OpdService(),
          builder: (context, _) {
            final allSektor = OpdService().getSektorList();

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allSektor.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
                childAspectRatio: 0.80,
              ),
              itemBuilder: (context, index) {
                final sektor = allSektor[index];
                final bool isMaintenance = !sektor.isActive;
                
                // Map Icon Name to IconData
                IconData displayIcon = Icons.help_outline_rounded;
                if (sektor.iconName == 'family_restroom_rounded') displayIcon = Icons.family_restroom_rounded;
                if (sektor.iconName == 'school_rounded') displayIcon = Icons.school_rounded;
                if (sektor.iconName == 'store_rounded') displayIcon = Icons.storefront_rounded;
                if (sektor.iconName == 'home_work_rounded') displayIcon = Icons.home_work_rounded;
                if (sektor.iconName == 'directions_car_rounded') displayIcon = Icons.directions_car_rounded;
                if (sektor.iconName == 'local_hospital_rounded') displayIcon = Icons.local_hospital_rounded;
                if (sektor.iconName == 'warning_amber_rounded') displayIcon = Icons.warning_amber_rounded;
                if (sektor.iconName == 'work_rounded') displayIcon = Icons.work_rounded;
                if (sektor.iconName == 'gavel_rounded') displayIcon = Icons.gavel_rounded;
                if (sektor.iconName == 'sports_soccer_rounded') displayIcon = Icons.sports_soccer_rounded;

                return GestureDetector(
                  onTap: () {
                    GuestGatekeeper.checkAccess(
                      context,
                      onGranted: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GenericLayananSektorScreen(sektor: sektor),
                          ),
                        );
                      },
                    );
                  },
                  child: ColorFiltered(
                    colorFilter: isMaintenance 
                      ? const ColorFilter.mode(Colors.grey, BlendMode.saturation) 
                      : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x30000000),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // KOTAK IKON PUTIH DENGAN OUTLINE EMAS (GOLD BORDER)
                              Container(
                                height: 72,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: accentColor, width: 2),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0), // Beri ruang napas
                                  child: SmartImage(
                                    imagePath: sektor.imagePath,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.contain, // Agar tidak terpotong
                                    fallbackIcon: displayIcon,
                                    fallbackColor: primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // JUDUL FASE KEHIDUPAN (TEKS PUTIH PRESISI)
                              Expanded(
                                child: Center(
                                  child: Text(
                                    sektor.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
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
                          if (isMaintenance)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Icon(Icons.build_circle_rounded, color: Colors.red.shade400, size: 14),
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
