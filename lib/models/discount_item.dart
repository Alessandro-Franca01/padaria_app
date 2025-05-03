class DiscountItem {
  final String imagePath;
  final String description;

  DiscountItem({
    required this.imagePath,
    required this.description,
  });
}

final List<DiscountItem> DiscountItems = [
  DiscountItem(
    imagePath: 'assets/images/descontos/descontos_paes.jpeg',
    description: 'Descontos 10% em pães artesanais',
  ),
  DiscountItem(
    imagePath: 'assets/images/descontos/descontos_doces.jpeg',
    description: 'Até 20% doces selecionados',
  ),
  DiscountItem(
    imagePath: 'assets/images/descontos/descontos_gemini_planos.jpeg',
    description: 'Desconto 20% para novas assinaturas',
  ),
  // DiscountItem(
  //   imagePath: 'https://via.placeholder.com/100?text=Vegano',
  //   description: 'Zero ingredientes animais',
  // ),
  // DiscountItem(
  //   imagePath: 'https://via.placeholder.com/100?text=Promoção',
  //   description: 'Ofertas especiais',
  // ),
];