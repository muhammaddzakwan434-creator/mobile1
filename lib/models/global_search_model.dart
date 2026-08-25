import 'package:flutter/material.dart';

enum SearchResultType {
  instansi,
  layanan,
  sektor,
  bantuan,
  tentang,
}

class GlobalSearchResult {
  final String title;
  final String subtitle;
  final SearchResultType type;
  final VoidCallback onTap;
  final IconData icon;

  GlobalSearchResult({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.onTap,
    required this.icon,
  });
}
