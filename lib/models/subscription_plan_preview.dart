class SubscriptionPlanPreview {
  final String imagePath;
  final String title;
  final String description;
  final double price;

  SubscriptionPlanPreview({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.price,
  });
}

final List<SubscriptionPlanPreview> subscriptionPlanPreviews = [
  SubscriptionPlanPreview(
    imagePath: 'assets/images/paes_artesanais.jpeg',
    title: 'Plano Pães da Semana',
    description: '12 pães artesanais fresquinhos por semana.',
    price: 29.90,
  ),
  SubscriptionPlanPreview(
    imagePath: 'assets/images/categories/categoria_doces.jpeg',
    title: 'Plano Doces Selecionados',
    description: '4 doces variados por semana.',
    price: 34.90,
  ),
];

