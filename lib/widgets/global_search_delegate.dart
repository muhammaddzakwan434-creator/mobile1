import 'package:flutter/material.dart';
import '../services/opd_service.dart';
import '../models/global_search_model.dart';
import '../views/instansi/generic_info_instansi_screen.dart';
import '../views/layanan/generic_layanan_sektor_screen.dart';
import '../views/informasi/help_center_screen.dart';
import '../views/informasi/about_screen.dart';
import '../widgets/guest_gatekeeper.dart';

class GlobalSearchDelegate extends SearchDelegate {
  final OpdService _opdService = OpdService();

  @override
  String get searchFieldLabel => 'Cari Layanan, Dinas, atau Bantuan...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded, color: Color(0xFF0A1E33)),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0A1E33), size: 20),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildSuggestions(context);
    }
    return _buildSearchResults(context);
  }

  Widget _buildSuggestions(BuildContext context) {
    const suggestions = [
      {'title': 'KTP Elektronik', 'icon': Icons.badge_outlined},
      {'title': 'Izin Usaha (NIB)', 'icon': Icons.store_rounded},
      {'title': 'Pajak PBB', 'icon': Icons.home_work_rounded},
      {'title': 'Pusat Bantuan', 'icon': Icons.help_outline_rounded},
    ];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saran Pencarian',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: suggestions.map((s) {
              return ActionChip(
                label: Text(s['title'] as String, style: const TextStyle(fontSize: 12, fontFamily: 'Poppins')),
                avatar: Icon(s['icon'] as IconData, size: 16),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onPressed: () => query = s['title'] as String,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final results = _opdService.performGlobalSearch(context, query);

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Tidak ada hasil untuk "$query"',
              style: const TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'Poppins'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: Icon(item.icon, color: const Color(0xFF0A1E33), size: 20),
          ),
          title: Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          subtitle: Text(item.subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'Poppins')),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
          onTap: () {
            _handleNavigation(context, item);
          },
        );
      },
    );
  }

  void _handleNavigation(BuildContext context, GlobalSearchResult item) {
    switch (item.type) {
      case SearchResultType.instansi:
        final kode = item.title.toLowerCase();
        final instansi = _opdService.getInstansiByKode(kode);
        if (instansi != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => GenericInfoInstansiScreen(instansi: instansi)));
        }
        break;
      case SearchResultType.layanan:
        GuestGatekeeper.checkAccess(context, onGranted: () {
          final sektorTitle = item.subtitle.split(' di ')[1];
          final sektor = _opdService.getSektorList().firstWhere(
            (s) => s.title == sektorTitle,
            orElse: () => _opdService.getSektorList().first,
          );
          Navigator.push(context, MaterialPageRoute(builder: (_) => GenericLayananSektorScreen(sektor: sektor)));
        });
        break;
      case SearchResultType.sektor:
        final sektorTitle = item.title.replaceFirst('Sektor ', '');
        final sektor = _opdService.getSektorList().firstWhere(
          (s) => s.title == sektorTitle,
          orElse: () => _opdService.getSektorList().first,
        );
        Navigator.push(context, MaterialPageRoute(builder: (_) => GenericLayananSektorScreen(sektor: sektor)));
        break;
      case SearchResultType.bantuan:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterScreen()));
        break;
      case SearchResultType.tentang:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
        break;
    }
  }
}
