import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_client.dart';

/// Renderiza a imagem de um produto, cobrindo os três formatos possíveis
/// de `imageUrl`: asset local do bundle, upload servido pela API (caminho
/// relativo) ou ausência de imagem.
class ProductImage extends StatelessWidget {
  final Product product;
  final BorderRadius? borderRadius;
  final double iconSize;

  const ProductImage({
    super.key,
    required this.product,
    this.borderRadius,
    this.iconSize = 50,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(Icons.fastfood, size: iconSize, color: Colors.brown);

    if (product.imageUrl.isEmpty) return fallback;

    final Widget image = product.imageUrl.startsWith('assets/')
        ? Image.asset(
            product.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.image_not_supported, size: iconSize),
          )
        : Image.network(
            ApiClient.mediaUrl(product.imageUrl),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.image_not_supported, size: iconSize),
          );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
