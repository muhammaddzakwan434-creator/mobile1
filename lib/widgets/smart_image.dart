import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SmartImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final IconData fallbackIcon;
  final Color fallbackColor;

  const SmartImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.fallbackIcon = Icons.image_rounded,
    this.fallbackColor = const Color(0xFF123457),
  });

  @override
  Widget build(BuildContext context) {
    final String path = imagePath.trim();
    Widget imageWidget;

    if (path.isEmpty) {
      imageWidget = _buildFallback();
    } else if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('blob:') || path.startsWith('data:')) {
      imageWidget = Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    } else if (path.startsWith('assets/')) {
      imageWidget = Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    } else {
      // Path lokal (hanya didukung di HP, di web otomatis ke fallback)
      if (kIsWeb) {
        imageWidget = _buildFallback();
      } else {
        imageWidget = Image.file(
          File(path),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      }
    }

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: fallbackColor.withOpacity(0.12),
      child: Center(
        child: Icon(
          fallbackIcon,
          color: fallbackColor,
          size: (width != null && width! < 40) ? 18 : 26,
        ),
      ),
    );
  }
}
