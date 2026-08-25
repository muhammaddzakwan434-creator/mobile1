import 'package:flutter/material.dart';
import 'package:mobile/views/profile/edit_profile_screen.dart';
import 'package:mobile/views/profile/login_screen.dart';
import 'package:mobile/views/informasi/terms_and_policy_screen.dart';
import 'package:mobile/views/informasi/about_screen.dart';
import 'package:mobile/views/informasi/feedback_screen.dart';
import 'package:mobile/views/informasi/help_center_screen.dart';
import 'package:mobile/services/user_service.dart';
import 'package:mobile/models/user_model.dart';
import 'package:mobile/services/notification_service.dart';
import 'package:mobile/models/notification_model.dart';
import 'package:mobile/widgets/smart_image.dart';
import 'package:mobile/widgets/admin_image_picker.dart';
import 'package:mobile/widgets/guest_gatekeeper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();

  void _showProfileImageModal(BuildContext context, UserModel user) {
    const Color primaryColor = Color(0xFF0A1E33);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kelola Foto Profil',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 1),
              const SizedBox(height: 14),

              // TOMBOL UNGGAH FOTO BARU
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_camera_rounded, color: primaryColor),
                ),
                title: const Text(
                  'Unggah / Pilih Foto Baru',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                ),
                subtitle: const Text(
                  'Pilih foto dari galeri atau aset foto resmi',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey, fontFamily: 'Poppins'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _bukaPickerFoto(user);
                },
              ),

              // TOMBOL HAPUS FOTO PROFIL (JIKA FOTO KUSTOM ADA)
              if (user.profileImagePath.isNotEmpty) ...[
                const SizedBox(height: 6),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  ),
                  title: const Text(
                    'Hapus Foto Profil',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent, fontFamily: 'Poppins'),
                  ),
                  subtitle: const Text(
                    'Kembalikan foto profil ke avatar default inisial',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey, fontFamily: 'Poppins'),
                  ),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);
                    await _userService.removeProfileImage();
                    if (!mounted) return;
                    setState(() {});
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Foto profil berhasil dihapus!'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _bukaPickerFoto(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Avatar / Unggah Foto Profil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A1E33), fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 12),
              AdminImagePicker(
                label: 'Foto Profil',
                currentImagePath: user.profileImagePath,
                onImageSelected: (path) async {
                  final messenger = ScaffoldMessenger.of(context);
                  final updated = user.copyWith(profileImagePath: path);
                  await _userService.updateProfile(updated);
                  if (!mounted) return;
                  setState(() {});
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Foto profil baru berhasil diperbarui!'),
                      backgroundColor: Color(0xFF123457),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutBottomSheet(BuildContext context) {
    const Color primaryColor = Color(0xFF0A1E33);

    showModalBottomSheet(
      context: context,
      backgroundColor: primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Keluar Akun Sukabumi One Access',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Apakah anda yakin ingin keluar dari akun Sukabumi One Access?',
                style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Semua data Anda akan tetap tersimpan secara otomatis.',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Poppins'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    navigator.pop();

                    // TAMBAH NOTIFIKASI SISTEM KELUAR AKUN
                    await NotificationService().addNotification(
                      title: 'Berhasil Keluar Akun',
                      description: 'Anda telah keluar dari akun Sukabumi One Access. Sesi diakhiri secara aman.',
                      category: NotificationCategory.general,
                    );

                    messenger.showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Anda berhasil keluar dari akun Sukabumi One Access.',
                                style: TextStyle(fontFamily: 'Poppins'),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Color(0xFF123457),
                        duration: Duration(seconds: 3),
                      ),
                    );

                    navigator.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Ya, Keluar Sekarang',
                    style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batal Keluar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A1E33);
    const Color accentColor = Color(0xFFE8A33D);
    const Color backgroundColor = Colors.white;

    final user = _userService.currentUser;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER PROFILE CARD (CONTAINER BLUE WITH AVATAR & USER DATA)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
              child: Column(
                children: [
                  // Row: Edit Profil Button
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        GuestGatekeeper.checkAccess(context, onGranted: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                          ).then((_) {
                            setState(() {});
                          });
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white60),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Edit Profil',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Row: Profile Info (Avatar dengan Interaksi Unggah/Hapus | Name, ID)
                  Row(
                    children: [
                      // FOTO AVATAR INTERAKTIF DENGAN TOMBOL KAMERA
                      GestureDetector(
                        onTap: () {
                          GuestGatekeeper.checkAccess(context, onGranted: () {
                            _showProfileImageModal(context, user);
                          });
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: 86,
                              height: 86,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: accentColor, width: 2.5),
                                color: Colors.grey.shade300,
                              ),
                              child: ClipOval(
                                child: user.profileImagePath.isNotEmpty
                                    ? SmartImage(
                                        imagePath: user.profileImagePath,
                                        width: 86,
                                        height: 86,
                                        fit: BoxFit.cover,
                                      )
                                    : Center(
                                        child: Text(
                                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                          style: const TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.photo_camera_rounded,
                                  color: primaryColor,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Text(
                                'Warga Digital',
                                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (_userService.isLoggedIn && user.id != 'GUEST-001') ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.verified, color: Colors.blueAccent, size: 22),
                                ],
                              ],
                            ),
                            Text(
                              user.id,
                              style: const TextStyle(color: accentColor, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white24, thickness: 1.5),
                  const SizedBox(height: 16),

                  // "Data Sudah Lengkap" Banner
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description, color: accentColor, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Data Sudah Lengkap',
                        style: TextStyle(color: accentColor, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // MENU LIST SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                children: [
                  // 1. KRLIK & SARAN (FEEDBACK)
                  _buildMenuItem(
                    icon: Icons.rate_review_outlined,
                    title: 'Kritik & Saran',
                    subtitle: 'Bantu kami meningkatkan kualitas layanan',
                    onTap: () {
                      GuestGatekeeper.checkAccess(context, onGranted: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // 3. PUSAT BANTUAN
                  _buildMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Pusat Bantuan',
                    subtitle: 'Pertanyaan umum dan bantuan penggunaan',
                    onTap: () {
                      GuestGatekeeper.checkAccess(context, onGranted: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // 4. TENTANG APLIKASI
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang Aplikasi',
                    subtitle: 'Informasi versi dan pengembang',
                    onTap: () {
                      GuestGatekeeper.checkAccess(context, onGranted: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AboutScreen()),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // 5. SYARAT & KETENTUAN
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Syarat & Kebijakan Privasi',
                    subtitle: 'Ketentuan penggunaan dan keamanan data',
                    onTap: () {
                      GuestGatekeeper.checkAccess(context, onGranted: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TermsAndPolicyScreen()),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 12),



                  // TOMBOL KELUAR AKUN
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        GuestGatekeeper.checkAccess(context, onGranted: () {
                          _showLogoutBottomSheet(context);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Keluar Akun',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Icon(Icons.logout_rounded, color: accentColor),
                        ],
                      ),
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF0A1E33),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A1E33),
            fontFamily: 'Poppins',
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'Poppins'),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }
}
