class Category {
  final String name;
  final String icon; // Icon name or path

  Category({
    required this.name,
    this.icon = 'store', // Default icon
  });

  static List<Category> getDefaultCategories() {
    return [
      Category(name: "Men's Salon", icon: 'store'),
      Category(name: "Women's Salon", icon: 'store'),
      Category(name: "Unisex", icon: 'store'),
      Category(name: "Makeup", icon: 'services'),
      Category(name: "Facial", icon: 'services'),
      Category(name: "Hair Care", icon: 'services'),
    ];
  }
}

