class CarouselItem {
  final String imagePath;
  final String title;

  CarouselItem({required this.imagePath, required this.title});
}

final List<CarouselItem> carouselItems = [
  CarouselItem(
    imagePath: 'assets/images/paes_artesanais.png',
    title: 'Pães Artesanais',
  ),
  CarouselItem(
    imagePath: 'assets/images/bolos_caseiros.png',
    title: 'Bolos Caseiros',
  ),
  CarouselItem(
    imagePath: 'assets/images/salgados_premium.png',
    title: 'Salgados Premium',
  ),
];