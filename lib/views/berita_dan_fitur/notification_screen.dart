import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/services/notification_service.dart';
import 'package:mobile/models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua Notifikasi';
  String _selectedSort = 'Terbaru';

  @override
  void initState() {
    super.initState();
    _notificationService.addListener(_refresh);
    _searchController.addListener(() {
      setState(() {});
    });
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _notificationService.removeListener(_refresh);
    _searchController.dispose();
    super.dispose();
  }

  List<NotificationModel> _getFilteredNotifications() {
    List<NotificationModel> filtered = _notificationService.notifications.where((n) {
      // Filter by Search Text
      bool matchesSearch = n.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          n.description.toLowerCase().contains(_searchController.text.toLowerCase());
      
      if (!matchesSearch) return false;

      // Filter by Category
      if (_selectedFilter == 'Semua Notifikasi') return true;
      if (_selectedFilter == 'Informasi') return n.category == NotificationCategory.news;
      if (_selectedFilter == 'Layanan') return n.category == NotificationCategory.service;
      if (_selectedFilter == 'Kebencanaan') return n.category == NotificationCategory.disaster;
      
      return true;
    }).toList();

    // Apply Sorting
    if (_selectedSort == 'Terbaru') {
      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } else if (_selectedSort == 'Terlama') {
      filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } else if (_selectedSort == 'A ke Z') {
      filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else if (_selectedSort == 'Z ke A') {
      filtered.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFFE8A33D);

    final notifications = _getFilteredNotifications();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      body: Column(
        children: [
          _buildHeader(accentColor),
          Expanded(
            child: notifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationList(notifications, accentColor),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color accentColor) {
    return Column(
      children: [
        // 1. TOP BAR (Logo & Weather)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo Section
                Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 40,
                      height: 36,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.location_city, color: Color(0xFF123457), size: 32),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sukabumi',
                          style: TextStyle(
                            color: Color(0xFF0A1E33),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ONE ACCESS',
                          style: TextStyle(
                            color: Color(0xFFE8A33D),
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Weather Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Sukabumi,',
                      style: TextStyle(color: Color(0xFF0A1E33), fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF123457),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                '28°C',
                                style: TextStyle(color: Color(0xFFE8A33D), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Terasa seperti 31°C',
                                style: TextStyle(color: Colors.white, fontSize: 6),
                              ),
                            ],
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.wb_sunny_rounded, color: Color(0xFFE8A33D), size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // 2. LAYERED HEADER WITH SEARCH
        Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                // Header Layer with Poster Background (Notif.png)
                Container(
                  width: double.infinity,
                  height: 90,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/poster/Notif.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0.15),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none_rounded, color: Colors.white, size: 32),
                          SizedBox(width: 8),
                          Text(
                            'Notifikasi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black45,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Yellow Divider Line
                Container(
                  width: double.infinity,
                  height: 4,
                  color: accentColor,
                ),
                // Dark Blue Layer (Filters)
                Container(
                  width: double.infinity,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF123457),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
                  child: Row(
                    children: [
                      _buildFilterTab(accentColor),
                      const Spacer(),
                      _buildSortButton(),
                      _buildMoreOptionsButton(accentColor),
                    ],
                  ),
                ),
              ],
            ),
            // Floating Search Bar
            Positioned(
              top: 50, // Center over the yellow line (70-20ish)
              left: 24,
              right: 24,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Cari Notifikasi...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    suffixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                  ),
                ),
              ),
            ),
            // Info Icon (Top Right of Light Blue)
            Positioned(
              top: 15,
              right: 16,
              child: Icon(Icons.info_outline, color: const Color(0xFF123457).withOpacity(0.7), size: 24),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterTab(Color accentColor) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        setState(() {
          _selectedFilter = value;
        });
      },
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _buildPopupMenuItem('Semua Notifikasi'),
        _buildPopupMenuItem('Informasi'),
        _buildPopupMenuItem('Layanan'),
        _buildPopupMenuItem('Kebencanaan'),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedFilter,
              style: const TextStyle(
                color: Color(0xFF123457),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down_rounded, color: accentColor, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        setState(() {
          _selectedSort = value;
        });
      },
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      icon: const Icon(Icons.tune, color: Colors.white70, size: 22),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _buildPopupMenuItem('Terbaru'),
        _buildPopupMenuItem('Terlama'),
        _buildPopupMenuItemWithIcon('A ke Z', Icons.sort_by_alpha_rounded),
        _buildPopupMenuItemWithIcon('Z ke A', Icons.sort_by_alpha_rounded),
      ],
    );
  }

  Widget _buildMoreOptionsButton(Color accentColor) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        if (value == 'read_all') {
          _notificationService.markAllAsRead();
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Semua notifikasi ditandai telah dibaca')),
          );
        } else if (value == 'delete_all') {
          _showDeleteConfirmation();
        }
      },
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      icon: Icon(Icons.more_vert, color: accentColor, size: 22),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'read_all',
          height: 40,
          child: Text(
            'Tandai telah dibaca',
            style: TextStyle(
              color: Color(0xFF123457),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete_all',
          height: 40,
          child: Text(
            'Hapus',
            style: TextStyle(
              color: Color(0xFF123457),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Notifikasi?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Seluruh riwayat notifikasi akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _notificationService.deleteAllNotifications();
              setState(() {});
            },
            child: const Text('Hapus Semua', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value) {
    bool isSelected = _selectedFilter == value || _selectedSort == value;
    return PopupMenuItem<String>(
      value: value,
      height: 40,
      child: Text(
        value,
        style: TextStyle(
          color: isSelected ? const Color(0xFFE8A33D) : const Color(0xFF123457),
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItemWithIcon(String value, IconData icon) {
    bool isSelected = _selectedSort == value;
    return PopupMenuItem<String>(
      value: value,
      height: 40,
      child: Row(
        children: [
          Icon(icon, size: 16, color: isSelected ? const Color(0xFFE8A33D) : const Color(0xFF123457)),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: isSelected ? const Color(0xFFE8A33D) : const Color(0xFF123457),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'Belum ada notifikasi baru',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications, Color accentColor) {
    final Map<String, List<NotificationModel>> grouped = {};
    for (var n in notifications) {
      String groupKey = _getGroupKey(n.timestamp);
      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = [];
      }
      grouped[groupKey]!.add(n);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: grouped.keys.length,
      itemBuilder: (context, index) {
        String groupTitle = grouped.keys.elementAt(index);
        List<NotificationModel> items = grouped[groupTitle]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 8),
              child: Text(
                groupTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            ...items.map((n) => _buildNotificationCard(n, const Color(0xFF123457), accentColor)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  String _getGroupKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) return 'Hari Ini';
    if (notificationDate == yesterday) return 'Kemarin';
    return DateFormat('MMMM yyyy').format(date);
  }

  Widget _buildNotificationCard(NotificationModel notification, Color primaryColor, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryIcon(notification.category, primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    Text(
                      DateFormat('HH.mm').format(notification.timestamp),
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notification.description,
                  style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(NotificationCategory category, Color primaryColor) {
    IconData iconData;
    switch (category) {
      case NotificationCategory.feedback:
        iconData = Icons.rate_review_outlined;
        break;
      case NotificationCategory.service:
        iconData = Icons.description_outlined;
        break;
      case NotificationCategory.news:
        iconData = Icons.info_outline;
        break;
      case NotificationCategory.disaster:
        iconData = Icons.warning_amber_rounded;
        break;
      default:
        iconData = Icons.notifications_none_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, size: 20, color: primaryColor),
    );
  }
}
