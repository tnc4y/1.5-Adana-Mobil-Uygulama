import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NetworkImageBox extends StatelessWidget {
  const NetworkImageBox({
    super.key,
    required this.imageUrl,
    this.height = 180,
    this.width = double.infinity,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final double height;
  final double width;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = _normalizeImageUrl(imageUrl);

    if (normalizedUrl.isEmpty) {
      return _placeholder();
    }

    final likelySvg = _isLikelySvg(normalizedUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: likelySvg
          ? _buildSvgWithFallback(normalizedUrl)
          : _buildRasterWithFallback(normalizedUrl),
    );
  }

  Widget _buildRasterWithFallback(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      fit: fit,
      errorWidget: (_, __, ___) =>
          _buildSvgWithFallback(url, showPlaceholderOnError: true),
      placeholder: (_, __) => _loading(),
    );
  }

  Widget _buildSvgWithFallback(String url,
      {bool showPlaceholderOnError = false}) {
    return SvgPicture.network(
      url,
      height: height,
      width: width,
      fit: fit,
      placeholderBuilder: (_) => _loading(),
      clipBehavior: Clip.hardEdge,
      errorBuilder: (_, __, ___) => showPlaceholderOnError
          ? _placeholder()
          : _buildRasterWithFallback(url),
    );
  }

  Widget _loading() {
    return Container(
      height: height,
      width: width,
      color: const Color(0xFFE9EDF5),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }

  bool _isLikelySvg(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('image/svg+xml')) {
      return true;
    }

    final parsed = Uri.tryParse(url);
    final path = parsed?.path.toLowerCase() ?? lower;
    return path.endsWith('.svg');
  }

  String _normalizeImageUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';

    if (value.startsWith('//')) {
      return 'https:$value';
    }

    if (value.startsWith('http://')) {
      return value.replaceFirst('http://', 'https://');
    }

    final hasScheme = value.startsWith('https://') ||
        value.startsWith('data:') ||
        value.startsWith('asset:');
    if (hasScheme) {
      return value;
    }

    // Plain host/path entries like cdn.example.com/file.png should still work.
    final looksLikeHostPath =
        !value.startsWith('/') && value.contains('.') && !value.contains(' ');
    if (looksLikeHostPath) {
      return 'https://$value';
    }

    return value;
  }

  Widget _placeholder() {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFE9EDF5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Icon(Icons.image_not_supported_outlined, size: 28),
    );
  }
}
