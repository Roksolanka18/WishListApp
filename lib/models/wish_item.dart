enum WishStatus { Wanted, Purchased }

class WishItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final double cost;
  final DateTime dateAdded;
  final WishStatus status;

  WishItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.cost,
    required this.dateAdded,
    this.status = WishStatus.Wanted,
  });
}