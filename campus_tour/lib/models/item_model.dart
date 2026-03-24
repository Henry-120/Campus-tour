class ElfItem {
  final int id;
  final String name;
  final String imageUrl;
  final bool isUnlocked;

  ElfItem({
    required this.id,
    required this.name,
    this.imageUrl = '',
    this.isUnlocked = false,
  });
}