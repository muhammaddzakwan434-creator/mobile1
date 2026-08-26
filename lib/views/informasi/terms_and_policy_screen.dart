import 'package:flutter/material.dart';
import 'package:mobile/widgets/smart_image.dart';

class TermsAndPolicyScreen extends StatefulWidget {
  const TermsAndPolicyScreen({super.key});

  @override
  State<TermsAndPolicyScreen> createState() => _TermsAndPolicyScreenState();
}

class _TermsAndPolicyScreenState extends State<TermsAndPolicyScreen> {
  // Map status ekspansi accordion
  final Map<String, bool> _expandedMap = {
    'Dasar Hukum': false,
    'Data Pribadi Pengguna': false,
    'Data Non-Pribadi Pengguna': false,
    'Cookies': false,
    'Bagaimana Kami Menggunakan Data': false,
    'Perlindungan Data Pribadi Pengguna': false,
    'Berbagi Data Pribadi Dan Data Non-Pribadi': false,
    'Jangka Waktu Data': false,
    'Perubahan Kebijakan Privasi': false,
    'Mengubah, Menghapus, Dan Meminta': false,
    'Perangkat Lunak Dan Ekstensi Yang Digunakan': false,
    'Persetujuan': false,
  };

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A1E33);
    const Color accentColor = Color(0xFFE8A33D);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: accentColor, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            children: [
              TextSpan(text: 'Kebijakan ', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'dan Ketentuan', style: TextStyle(color: accentColor)),
            ],
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // TITLE KEBIJAKAN PRIVASI
              const Text(
                'KEBIJAKAN PRIVASI',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 0.5,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 14),

              // VERSION BADGE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Versi 5.4.3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // UPDATE DATE ROW
              const Row(
                children: [
                  Icon(Icons.calendar_today_outlined, color: primaryColor, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Diperbarui per tanggal ',
                    style: TextStyle(color: Colors.grey, fontSize: 12.5, fontFamily: 'Poppins'),
                  ),
                  Text(
                    '23 Desember 2026',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // INTRO PARAGRAPH
              const Text(
                'Kebijakan Privasi ini menjelaskan bagaimana Sukabumi City One Access mengumpulkan, menggunakan, menyimpan, dan melindungi data pribadi Anda selama menggunakan layanan aplikasi. Informasi yang Anda berikan akan digunakan untuk mendukung penyelenggaraan layanan, meningkatkan kualitas pelayanan, serta memberikan pengalaman penggunaan aplikasi yang lebih baik sesuai dengan ketentuan yang berlaku.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.55,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),

              // ACCORDION ITEMS DENGAN TEKS RESMI
              _buildAccordionItem(
                title: 'Dasar Hukum',
                contentWidget: _buildDasarHukumContent(),
              ),
              _buildAccordionItem(
                title: 'Data Pribadi Pengguna',
                contentWidget: const Text(
                  'Kami mengumpulkan data pribadi dari Anda melalui berbagai cara, termasuk namun tidak terbatas pada, ketika Anda mengunjungi Aplikasi dan menggunakan layanan, mendaftar sebagai Pengguna, menggunakan layanan tertentu, mengisi dan melengkapi formulir, dan yang berkaitan dengan kegiatan, layanan, fitur, atau konten yang Kami sediakan dalam Aplikasi. Anda dapat diminta memberikan data, termasuk namun tidak terbatas pada nama, alamat email, alamat sesuai Kartu Tanda Penduduk (KTP), alamat domisili, foto diri, foto KTP, foto diri dengan memegang KTP, Nomor Induk Kependudukan, Nomor Kartu Keluarga, tanggal lahir, jenis kelamin, tempat lahir, status perkawinan, nomor telepon, dan dokumen surat keputusan rukun warga. Kami mengumpulkan data pribadi dari Pengguna, yang secara sukarela diberikan kepada Kami. Anda dapat setiap saat menolak memberikan data pribadi, kecuali jika hal tersebut dapat membatasi mereka untuk mengakses bagian tertentu dalam Aplikasi.',
                  style: TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.55, fontFamily: 'Poppins'),
                ),
              ),
              _buildAccordionItem(
                title: 'Data Non-Pribadi Pengguna',
                contentWidget: const Text(
                  'Kami dapat mengumpulkan data non-pribadi Anda ketika berinteraksi dengan Situs dan Aplikasi. Data non-pribadi termasuk perangkat telepon, data lokasi dan informasi lainnya berkaitan dengan cara Anda terhubung dengan Aplikasi Kami, termasuk, namun tidak terbatas seperti internet protocol (IP), model perangkat, data geospasial, sistem operasi, layanan internet, sosial media, dan pengaturan aplikasi saat menggunakan layanan, waktu, dan tanggal penggunaan layanan, statistik lain, dan data historis layanan yang Anda akses.',
                  style: TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.55, fontFamily: 'Poppins'),
                ),
              ),
              _buildAccordionItem(
                title: 'Cookies',
                contentWidget: const Text(
                  'Situs Kami tidak menggunakan cookies secara eksplisit. Namun, Aplikasi mungkin menggunakan kode dan library pihak ketiga yang menggunakan cookies untuk mengumpulkan informasi dan memperbaiki layanan mereka. Anda dapat menginstruksikan browser mereka, dengan mengubah pilihan, untuk berhenti menerima cookies atau untuk meminta Anda sebelum menerima cookies dari situs-situs yang dikunjungi. Jika Anda tidak menerima cookies, maka Anda mungkin tidak dapat menggunakan semua bagian dari Situs dan Aplikasi atau semua fungsi dari layanan Kami.',
                  style: TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.55, fontFamily: 'Poppins'),
                ),
              ),
              _buildAccordionItem(
                title: 'Bagaimana Kami Menggunakan Data',
                contentWidget: _buildMenggunakanDataContent(),
              ),
              _buildAccordionItem(
                title: 'Perlindungan Data Pribadi Pengguna',
                contentWidget: _buildPerlindunganDataContent(),
              ),
              _buildAccordionItem(
                title: 'Berbagi Data Pribadi Dan Data Non-Pribadi',
                contentWidget: const Text(
                  'Data pribadi dan data non-pribadi Anda hanya dibagikan demi kepentingan pelaksanaan tugas pemerintahan dan penyelenggaraan pelayanan publik yang sah. Kami tidak menjual, memperdagangkan, atau menyewakan data pribadi pengguna kepada pihak manapun.',
                  style: TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.55, fontFamily: 'Poppins'),
                ),
              ),
              _buildAccordionItem(
                title: 'Jangka Waktu Data',
                contentWidget: const Text(
                  'Kami hanya mengumpulkan dan menggunakan data dalam bentuk foto diri, foto KTP, foto diri dengan memegang KTP selama proses verifikasi dan validasi identitas Anda dan akan segera dihapus setelah proses tersebut selesai, kecuali Anda telah menyetujui hal lain berkaitan dengan penggunaan data pribadi dan data non-pribadi. Data pribadi maupun data non-pribadi lainnya digunakan sesuai dengan tujuan pengolahan selama Anda masih menggunakan Situs atau Aplikasi Kami. Kami akan menghentikan pemrosesan data Anda pada saat Anda menghapus akun di Situs atau Aplikasi Kami.',
                  style: TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.55, fontFamily: 'Poppins'),
                ),
              ),
              _buildAccordionItem(
                title: 'Perubahan Kebijakan Privasi',
                contentWidget: const Text(
                  'Kami memiliki hak dan diskresi untuk mengubah, memodifikasi, menambah, atau menghapus bagian dari Kebijakan Privasi ini setiap saat. Namun, jika sewaktu-waktu di masa depan Kami merencanakan untuk menggunakan informasi pribadi dengan cara yang secara material berbeda dari kebijakan ini, Kami akan memberitahu perubahan tersebut dan memberikan Anda kesempatan untuk meninjau ulang persetujuan Anda terhadap perubahan tersebut. Jika Anda tetap menggunakan Situs atau Aplikasi setelah adanya pengumuman setiap perubahan Kebijakan Privasi ini berarti Anda menerima perubahan tersebut.',
                  style: TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.55, fontFamily: 'Poppins'),
                ),
              ),
              _buildAccordionItem(
                title: 'Mengubah, Menghapus, Dan Meminta',
                contentWidget: const Text(
                  'Anda dapat meninjau, memperbarui, memperbaiki, atau menghapus data pribadi yang diberikan saat pendaftaran dengan mengubah halaman profil akun atau melakukan permintaan ke tim customer service Kami. Anda juga dapat meminta salinan atas data yang telah diberikan selama menggunakan Situs atau Aplikasi. Permintaan akan Kami tangani sesuai ketentuan Undang-Undang Nomor 27 Tahun 2022 tentang Perlindungan Data Pribadi (UU PDP), termasuk hak untuk menarik persetujuan dan menghentikan pemrosesan yang berbasis persetujuan.',
                  style: TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.55, fontFamily: 'Poppins'),
                ),
              ),
              _buildAccordionItem(
                title: 'Perangkat Lunak Dan Ekstensi Yang Digunakan',
                contentWidget: _buildPerangkatLunakContent(),
              ),
              _buildAccordionItem(
                title: 'Persetujuan',
                contentWidget: const Text(
                  'Dengan menggunakan Aplikasi Kami, Anda dengan ini menyetujui Kebijakan Privasi dengan ketentuan-ketentuannya. Kebijakan Privasi ini dapat diperbaharui atau diubah, dan perubahan tersebut akan dimuat di halaman ini.',
                  style: TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.55, fontFamily: 'Poppins'),
                ),
              ),

              const SizedBox(height: 36),

              // FOOTER LOGO SUKABUMI CITY ONE ACCESS
              const Center(
                child: SmartImage(
                  imagePath: 'assets/images/logo.png',
                  width: 140,
                  height: 48,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccordionItem({
    required String title,
    required Widget contentWidget,
  }) {
    const Color primaryColor = Color(0xFF0A1E33);
    const Color accentColor = Color(0xFFE8A33D);

    final bool isExpanded = _expandedMap[title] ?? false;

    return Column(
      children: [
        const Divider(height: 1, color: Colors.black12),
        InkWell(
          onTap: () {
            setState(() {
              _expandedMap[title] = !isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: isExpanded ? accentColor : primaryColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isExpanded ? accentColor : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.chevron_right_rounded,
                    color: isExpanded ? Colors.white : Colors.grey.shade600,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, top: 4.0),
            child: contentWidget,
          ),
      ],
    );
  }

  Widget _buildDasarHukumContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pemrosesan data pribadi pada Aplikasi dilaksanakan sesuai peraturan perundang-undangan yang berlaku, termasuk Undang-Undang Nomor 27 Tahun 2022 tentang Perlindungan Data Pribadi (UU PDP). Bergantung pada tujuan pemrosesan, Kami menggunakan satu atau lebih dasar hukum berikut, yang diterapkan secara proporsional dan terdokumentasi:',
          style: TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.5, fontFamily: 'Poppins'),
        ),
        const SizedBox(height: 10),
        _buildNumberedPoint('1.', 'Persetujuan (Consent). ', 'Pemrosesan dilakukan berdasarkan persetujuan yang jelas dan aktif dari Anda. Persetujuan dapat ditarik sewaktu-waktu tanpa mempengaruhi keabsahan pemrosesan sebelum penarikan.'),
        _buildNumberedPoint('2.', 'Kewajiban Hukum. ', 'Pemrosesan diperlukan untuk memenuhi kewajiban hukum yang mengikat Kami sesuai ketentuan peraturan perundang-undangan yang berlaku.'),
        _buildNumberedPoint('3.', 'Kepentingan Umum dalam Rangka Penyelenggaraan Negara. ', 'Pemrosesan diperlukan penyelenggaraan pelayanan publik dan/atau pelaksanaan tugas pemerintahan yang sah, termasuk verifikasi identitas menggunakan NIK dan/atau Nomor KK melalui sistem/penyedia resmi yang berwenang serta pertukaran data yang diperlukan dengan instansi terkait.'),
        _buildNumberedPoint('4.', 'Pelaksanaan Perjanjian. ', 'Pemrosesan diperlukan untuk memenuhi dan/atau mengeksekusi perjanjian antara Anda dan Kami, termasuk penyediaan fitur dan layanan.'),
        _buildNumberedPoint('5.', 'Kepentingan yang Sah (Legitimate Interests). ', 'Pemrosesan diperlukan untuk kepentingan yang sah dari Kami dan/atau pihak ketiga, sepanjang tidak mengesampingkan hak dan kebebasan Anda.'),
        const SizedBox(height: 10),
        const Text(
          'Dasar hukum dapat berbeda antar tujuan pemrosesan dan tidak saling meniadakan. Untuk setiap tujuan, Kami menentukan dasar hukum yang paling tepat (misalnya penyelenggaraan negara/kewajiban hukum untuk verifikasi NIK/KK; persetujuan untuk pemrosesan opsional seperti personalisasi/analitik non-esensial), dan melakukan pencatatan internal atas dasar hukum yang digunakan beserta versi kebijakan yang berlaku pada saat pemrosesan dilakukan. Apabila di kemudian hari terdapat perubahan material pada tujuan atau ruang lingkup pemrosesan yang berbasis persetujuan, Kami akan meminta persetujuan ulang sesuai ketentuan yang berlaku.',
          style: TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.5, fontFamily: 'Poppins'),
        ),
      ],
    );
  }

  Widget _buildMenggunakanDataContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data pribadi dan data non-pribadi Anda hanya digunakan seperti yang dijelaskan dalam Kebijakan Privasi ini, kecuali Anda telah menyetujui hal lain berkaitan dengan penggunaan data pribadi dan data non-pribadi. Kami menggunakan data pribadi dan data non-pribadi Anda untuk tujuan berikut:',
          style: TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.5, fontFamily: 'Poppins'),
        ),
        const SizedBox(height: 10),
        _buildSimpleNumberedPoint('1.', 'Menyediakan, memperbaiki, atau meningkatkan kualitas Situs dan Aplikasi Kami, layanan, fitur dan konten;'),
        _buildSimpleNumberedPoint('2.', 'Memenuhi permintaan Pengguna;'),
        _buildSimpleNumberedPoint('3.', 'Mempersonalisasi pengalaman Pengguna;'),
        _buildSimpleNumberedPoint('4.', 'Menyebarluaskan informasi kepada Pengguna;'),
        _buildSimpleNumberedPoint('5.', 'Membantu Pemerintah Daerah Provinsi Jawa Barat dalam membuat keputusan;'),
        _buildSimpleNumberedPoint('6.', 'Mendukung kegiatan pemerintah dalam memberikan pelayanan lainnya;'),
        _buildSimpleNumberedPoint('7.', 'Melaksanakan tujuan lainnya yang mengacu pada peraturan perundang-undangan; dan'),
        _buildSimpleNumberedPoint('8.', 'Mengungkapkan data pribadi dan data non-pribadi Anda jika diminta untuk melakukannya oleh penegak hukum, atau jika diperlukan untuk menyelidiki penipuan, pelanggaran terhadap Kebijakan Privasi atau sehubungan dengan bahaya apa pun yang disebabkan kepada pihak ketiga atau hak-hak mereka.'),
      ],
    );
  }

  Widget _buildPerlindunganDataContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kami sewaktu-waktu bekerja sama dengan badan usaha, yayasan atau individu pihak ketiga demi melaksanakan tujuan-tujuan berikut:',
          style: TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.5, fontFamily: 'Poppins'),
        ),
        const SizedBox(height: 10),
        _buildSimpleNumberedPoint('1.', 'Untuk memfasilitasi layanan Kami;'),
        _buildSimpleNumberedPoint('2.', 'Untuk menyediakan layanan atas nama Kami;'),
        _buildSimpleNumberedPoint('3.', 'Untuk melaksanakan layanan yang berhubungan dengan layanan Kami;'),
        _buildSimpleNumberedPoint('4.', 'Untuk mendampingi Kami dalam menganalisis bagaimana layanan Kami digunakan;'),
        _buildSimpleNumberedPoint('5.', 'Untuk membantu melaksanakan layanan lainnya; dan'),
        _buildSimpleNumberedPoint('6.', 'Untuk mendukung tujuan lain tercantum pada sebagaimana Kebijakan Privasi ini.'),
        const SizedBox(height: 10),
        const Text(
          'Dengan ini Kami memberitahu Anda bahwa pihak ketiga ini memiliki akses kepada informasi data pribadi dan data non-pribadi Anda demi melaksanakan tujuan-tujuan di atas. Pihak ketiga tersebut berkewajiban untuk menjaga kerahasiaan dan tidak menggunakan informasi tersebut untuk keperluan lain.',
          style: TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.5, fontFamily: 'Poppins'),
        ),
      ],
    );
  }

  Widget _buildPerangkatLunakContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kami berkomitmen untuk menjaga seluruh data pribadi Anda.\nUntuk melindungi seluruh data pada Situs dan Aplikasi, Kami tidak mengizinkan Anda menggunakan perangkat lunak pihak ketiga, termasuk perayap (crawler), bot, plug-in browser, atau ekstensi browser (juga disebut "add-on"), yang mengambil data, mengubah tampilan, atau mengotomatisasi aktivitas di Aplikasi namun tidak terbatas pada kegiatan yang dilarang sebagai berikut:',
          style: TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.5, fontFamily: 'Poppins'),
        ),
        const SizedBox(height: 10),
        _buildSimpleNumberedPoint('1.', 'Mengembangkan, mendukung, atau menggunakan perangkat lunak, perangkat, skrip, robot, atau cara dan proses lainnya (termasuk perayap, plug-in dan add-on browser, atau teknologi lainnya) untuk mengambil secara melawan hukum sebagian atau seluruh data yang terdapat dalam Aplikasi;'),
        _buildSimpleNumberedPoint('2.', 'Mengganti atau mengubah tampilan di Aplikasi;'),
        _buildSimpleNumberedPoint('3.', 'Melakukan deep-link pada seluruh produk dan layanan Kami untuk tujuan apa pun, tanpa persetujuan Kami.'),
        const SizedBox(height: 10),
        const Text(
          'Anda yang menggunakan alat untuk tujuan di atas berarti melanggar Kebijakan Privasi Situs dan Aplikasi. Kami berhak untuk membatasi atau menutup akun serta melakukan blokir alamat IP Anda yang melanggar Kebijakan Privasi Aplikasi tanpa pemberitahuan sebelumnya. Untuk menjaga keamanan seluruh data Kami, Kami selalu meningkatkan sistem keamanan secara teratur untuk mencegah penggunaan alat pengambil data, otomatisasi, dan alat lain yang menyalahgunakan penggunaan Aplikasi.',
          style: TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.5, fontFamily: 'Poppins'),
        ),
      ],
    );
  }

  Widget _buildNumberedPoint(String number, String title, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A1E33),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1E33),
                      fontSize: 12.5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextSpan(
                    text: text,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12.5,
                      height: 1.45,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleNumberedPoint(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A1E33),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12.5,
                height: 1.45,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
