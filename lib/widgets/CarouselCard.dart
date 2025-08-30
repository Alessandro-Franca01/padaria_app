import 'package:padaria_app/models/product.dart';
import 'package:padaria_app/models/category_item.dart';

class CarouselCard {
  final String imagePath;
  final String title;
  final Product? product;
  final CategoryItem? category;

  CarouselCard({
    required this.imagePath,
    required this.title,
    this.product,
    this.category,
  });
}

final List<CarouselCard> carouselItems = [
  CarouselCard(
    imagePath: 'assets/images/paes_artesanais.jpeg',
    title: 'Pães Artesanais',
    product: Product(
      id: '1',
      name: 'Pão Francês',
      description: 'Pão francês tradicional, fresco e crocante.',
      price: 1.50,
      imageUrl: 'assets/images/pao_frances.jpg',
      category: 'Pães',
      isFeatured: true,
    ),
  ),
  CarouselCard(
    imagePath: 'assets/images/bolos_caseiros.jpeg',
    title: 'Bolos Caseiros',
    category: CategoryItem(
      imagePath: 'assets/images/categories/bolos.jpg',
      title: 'Bolos Caseiros',
    ),
  ),
  CarouselCard(
    imagePath: 'assets/images/salgados_premium.jpeg',
    title: 'Salgados Premium',
    product: Product(
      id: '2',
      name: 'Coxinha',
      description: 'Coxinha de frango cremosa e crocante.',
      price: 4.00,
      imageUrl: 'assets/images/coxinha.jpeg',
      category: 'Salgados',
      isFeatured: false,
    ),
  ),
];