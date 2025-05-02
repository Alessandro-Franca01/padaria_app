class CategoryItem {
  final String imagePath;
  final String title;

  CategoryItem({required this.imagePath, required this.title});
}

final List<CategoryItem> categories = [
  CategoryItem(
    imagePath: 'assets/images/categories/categoria_paes.jpeg',
    title: 'Pães Artesanais',
  ),
  CategoryItem(
    imagePath: 'assets/images/categories/bolos.jpg',
    title: 'Bolos Caseiros',
  ),
  CategoryItem(
    imagePath: 'assets/images/categories/categoria_salgados.webp',
    title: 'Salgados Finos',
  ),
  CategoryItem(
    imagePath: 'assets/images/categories/categoria_cafes.webp',
    title: 'Café Especial',
  ),
  CategoryItem(
    imagePath: 'assets/images/categories/categoria_doces.jpeg',
    title: 'Doces Tradicionais',
  ),
  CategoryItem(
    imagePath: 'assets/images/categories/categoria_vegano.jpg',
    title: 'Opções Veganas',
  ),
];