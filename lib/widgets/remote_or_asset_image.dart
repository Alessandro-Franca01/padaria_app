import 'package:flutter/material.dart';
import '../services/api_client.dart';

/// Renderiza uma imagem a partir de um path que pode ser um asset local do
/// bundle, um caminho relativo servido pela API, ou vazio (mostra fallback).
class RemoteOrAssetImage extends StatelessWidget {
  final String? path;
  final BoxFit fit;
  final double iconSize;

  const RemoteOrAssetImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.iconSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(Icons.image_not_supported, size: iconSize);

    if (path == null || path!.isEmpty) return fallback;

    if (path!.startsWith('assets/')) {
      return Image.asset(
        path!,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    return Image.network(
      ApiClient.mediaUrl(path!),
      fit: fit,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
