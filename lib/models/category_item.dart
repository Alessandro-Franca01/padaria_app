class CategoryItem {
  final String imagePath;
  final String category;
  final String title;

  CategoryItem({required this.imagePath, required this.category, required this.title});
}

final List<CategoryItem> categories = [
  CategoryItem(
    imagePath: 'assets/images/categories/categoria_paes.jpeg',
    category: 'Pães',
    title: 'Pães Artesanais',
  ),
  CategoryItem(
    imagePath: 'assets/images/categories/bolos.jpg',
    category: 'Bolos',
    title: 'Bolos Caseiros',
  ),
  CategoryItem(
    imagePath: 'assets/images/categories/categoria_salgados.webp',
    category: 'Salgados',
    title: 'Salgados Finos',
  ),
  CategoryItem(
    imagePath: 'assets/images/categories/categoria_cafes.webp',
    category: 'Bebidas',
    title: 'Café Especial',
  ),
  CategoryItem(
    imagePath: 'assets/images/categories/categoria_doces.jpeg',
    category: 'Doces',
    title: 'Doces Tradicionais',
  ),
  CategoryItem(
    imagePath: 'assets/images/categories/categoria_vegano.jpg',
    category: 'Lanches',
    title: 'Opções Veganas',
  ),
];