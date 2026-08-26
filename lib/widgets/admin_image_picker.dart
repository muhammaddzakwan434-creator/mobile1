import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'smart_image.dart';

class AdminImagePicker extends StatefulWidget {
  final String currentImagePath;
  final ValueChanged<String> onImageSelected;
  final String label;

  const AdminImagePicker({
    super.key,
    required this.currentImagePath,
    required this.onImageSelected,
    this.label = 'Logo / Foto Instansi',
  });

  @override
  State<AdminImagePicker> createState() => _AdminImagePickerState();
}

class _AdminImagePickerState extends State<AdminImagePicker> {
  late String _selectedPath;
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, String>> _presetLogos = const [
    {'title': 'Disdukcapil Logo', 'path': 'assets/images/disduk.png'},
    {'title': 'Diskominfo Logo', 'path': 'assets/images/diskominfo.png'},
    {'title': 'DPMPTSP Logo', 'path': 'assets/images/dpmptsp.png'},
    {'title': 'BPKPD Logo', 'path': 'assets/images/bpkpd.png'},
    {'title': 'DKP3 Logo', 'path': 'assets/images/dkp3.png'},
    {'title': 'Sektor Keluarga', 'path': 'assets/icon/keluarga.png'},
    {'title': 'Sektor Pendidikan', 'path': 'assets/icon/pendidikan.png'},
    {'title': 'Sektor Usaha', 'path': 'assets/icon/usaha.png'},
    {'title': 'Sektor Lingkungan', 'path': 'assets/icon/lingkungan.png'},
    {'title': 'Sektor Kendaraan', 'path': 'assets/icon/kendaraan.png'},
    {'title': 'Sektor Kesehatan', 'path': 'assets/icon/kesehatan.png'},
    {'title': 'Sektor Tanggap Darurat', 'path': 'assets/icon/tanggapdarurat.png'},
    {'title': 'Sektor Karier', 'path': 'assets/icon/karier.png'},
    {'title': 'Sektor Rekreasi', 'path': 'assets/icon/rekreasi.png'},
    {'title': 'Sektor Sosial Hukum', 'path': 'assets/icon/sosialhukum.png'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedPath = widget.currentImagePath;
  }

  @override
  void didUpdateWidget(covariant AdminImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentImagePath != oldWidget.currentImagePath) {
      setState(() {
        _selectedPath = widget.currentImagePath;
      });
    }
  }

  void _simpanPathFoto(String sumber, String chosenPath) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _selectedPath = chosenPath;
    });
    widget.onImageSelected(_selectedPath);

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Berhasil mengambil foto dari $sumber!',
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF123457),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 1. DIRECT NATIVE CAMERA (MEMBUKA KAMERA ASLI HP)
  Future<void> _bukaKameraLangsung() async {
    Navigator.pop(context); // Tutup bottom sheet
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50, // Lebih ringan
        maxWidth: 500, // Cukup untuk ikon
        maxHeight: 500,
      );
      if (photo != null && photo.path.isNotEmpty) {
        _simpanPathFoto('Kamera HP', photo.path);
      }
    } catch (e) {
      debugPrint('Kamera hardware error / desktop mode: $e');
      _simpanPathFoto('Kamera HP', 'assets/icon/camera.png');
    }
  }

  // 2. DIRECT NATIVE GALLERY (MEMBUKA GALERI FOTO ASLI HP)
  Future<void> _bukaGaleriLangsung() async {
    Navigator.pop(context); // Tutup bottom sheet
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Lebih ringan
        maxWidth: 500, // Cukup untuk ikon
        maxHeight: 500,
      );
      if (image != null && image.path.isNotEmpty) {
        _simpanPathFoto('Galeri Foto', image.path);
      }
    } catch (e) {
      debugPrint('Galeri error / desktop mode: $e');
      _simpanPathFoto('Galeri Foto', 'assets/images/logo.png');
    }
  }

  // 3. DIRECT NATIVE FILE MANAGER (MEMBUKA PENGELOLA BERKAS ASLI HP)
  Future<void> _bukaFileManagerLangsung() async {
    Navigator.pop(context); // Tutup bottom sheet
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
      );
      if (result != null && result.files.single.path != null) {
        _simpanPathFoto('File Manager', result.files.single.path!);
      }
    } catch (e) {
      debugPrint('File Manager error / desktop mode: $e');
      _simpanPathFoto('File Manager', 'assets/images/diskominfo.png');
    }
  }

  void _bukaModalPilihGambar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Pilih / Unggah ${widget.label}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF123457),
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // OPSI DIRECT NATIVE: KAMERA, GALERI, FILE MANAGER
              const Text(
                'Pilih Sumber Unggah Foto:',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF123457),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  // 1. KAMERA (DIRECT NATIVE CAMERA)
                  Expanded(
                    child: _buildSourceCard(
                      icon: Icons.photo_camera_rounded,
                      title: 'Kamera',
                      subtitle: 'Buka Kamera',
                      color: const Color(0xFF123457),
                      onTap: _bukaKameraLangsung,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 2. GALERI FOTO (DIRECT NATIVE GALLERY)
                  Expanded(
                    child: _buildSourceCard(
                      icon: Icons.photo_library_rounded,
                      title: 'Galeri',
                      subtitle: 'Buka Album',
                      color: const Color(0xFFE8A33D),
                      onTap: _bukaGaleriLangsung,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 3. FILE MANAGER (DIRECT NATIVE FILE PICKER)
                  Expanded(
                    child: _buildSourceCard(
                      icon: Icons.folder_open_rounded,
                      title: 'File Manager',
                      subtitle: 'Buka Berkas',
                      color: const Color(0xFF008080),
                      onTap: _bukaFileManagerLangsung,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Divider(height: 1),
              const SizedBox(height: 14),

              // KOLEKSI ASET LOGO RESMI
              const Text(
                'Atau Pilih dari Koleksi Logo Resmi:',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF123457),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _presetLogos.length,
                  itemBuilder: (context, index) {
                    final item = _presetLogos[index];
                    final bool isSelected = _selectedPath == item['path'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPath = item['path']!;
                        });
                        widget.onImageSelected(_selectedPath);
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFE8A33D) : Colors.grey.shade300,
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            SmartImage(
                              imagePath: item['path']!,
                              width: 36,
                              height: 36,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['title']!,
                              style: const TextStyle(fontSize: 9.5, color: Color(0xFF123457), fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSourceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9.5,
                color: Colors.grey.shade700,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF123457);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: primaryColor,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                child: SmartImage(
                  imagePath: _selectedPath,
                  width: 46,
                  height: 46,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPath.isNotEmpty ? _selectedPath : 'Belum ada gambar terpilih',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Klik tombol di kanan untuk memilih atau mengunggah logo baru.',
                      style: TextStyle(fontSize: 10.5, color: Colors.grey, fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _bukaModalPilihGambar,
                icon: const Icon(Icons.photo_camera_rounded, size: 16),
                label: const Text('Unggah / Pilih', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: const BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
