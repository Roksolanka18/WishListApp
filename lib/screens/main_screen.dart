// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav_bar.dart'; // Імпорт BottomNavBar
import '../providers/wishlist_provider.dart';
import '../models/wish_item.dart';
import 'profile_screen.dart'; 

// Стани для провайдера
enum LoadingStatus { initial, loading, loaded, error }

// Головний віджет, що керує навігацією
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; 

  final List<Widget> _screens = const [
    WishlistContent(), 
    ProfileScreen(), 
  ];

  @override
  void initState() {
    super.initState();
    // Початкове завантаження Wishlist при старті
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Використовуємо нову функцію fetchWishes()
      Provider.of<WishListProvider>(context, listen: false).fetchWishes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      body: _screens[_selectedIndex], 

      // Відновлення Bottom Navigation Bar
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            // Перезавантаження Wishlist при перемиканні на нього
            if (index == 0) {
              Provider.of<WishListProvider>(context, listen: false).fetchWishes();
            }
          });
        },
      ),
    );
  }
}

// --- Wishlist Content Widget (Містить весь дизайн та логіку списку) ---
class WishlistContent extends StatelessWidget {
  const WishlistContent({super.key});
  
  static const Color primaryPink = Color(0xFFF72585);
  static const Color softBackground = Color(0xFFF7EAF0);

  // Helper method to show modal for filtering/sorting
  void _showModal(BuildContext context, Widget content) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => content,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Спостерігаємо за провайдером
    final provider = context.watch<WishListProvider>();
    final List<WishItem> wishes = provider.filteredWishlist;
    final status = provider.state;

    // Розрахунок лічильників
    final wantedCount = provider.wishlist.where((i) => i.status == WishStatus.Wanted).length;
    final purchasedCount = provider.wishlist.where((i) => i.status == WishStatus.Purchased).length;

    // Логіка відображення стану
    Widget listContent;
    if (status == WishListState.loading) {
      listContent = const Center(child: CircularProgressIndicator(color: primaryPink));
    } else if (status == WishListState.error) {
      listContent = Center(
        child: Text('Error: ${provider.errorMessage}'),
      );
    } else if (wishes.isEmpty) {
      listContent = const Center(
        child: Text("Your wishlist is empty."),
      );
    } else {
      listContent = RefreshIndicator(
        onRefresh: provider.fetchWishes, // Pull-to-refresh
        color: primaryPink,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: wishes.length,
          itemBuilder: (context, index) {
            return _buildWishlistItem(context, wishes[index], provider);
          },
        ),
      );
    }

    // Відновлення всього дизайну, який був у Вашому коді
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "My Wishlist",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                "Keep track of all the things you want",
                style: TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 20),

            // Status Cards (FR6)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statusCard(Icons.favorite, "$wantedCount wanted"),
                _statusCard(Icons.shopping_bag, "$purchasedCount purchased"),
              ],
            ),
            const SizedBox(height: 20),

            // Search/Filter/Sort Row (FR8, FR9, FR10)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search items...",
                      filled: true,
                      fillColor: softBackground,
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF9A4D73)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      provider.setSearchQuery(value); // FR8: Реалізація пошуку
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Filter Button (FR10)
                _filterSortButton(
                  icon: Icons.filter_list,
                  onPressed: () => _showModal(context, _buildFilterMenu(context, provider)),
                ),
                const SizedBox(width: 8),
                // Sort Button (FR9)
                _filterSortButton(
                  icon: Icons.sort,
                  onPressed: () => _showModal(context, _buildSortMenu(context, provider)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Item count
            Text(
              "${wishes.length} item${wishes.length != 1 ? 's' : ''}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            // List Content
            Expanded(child: listContent),
            
            // Add Button (Placeholder for creating a new wish)
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  // ЗМІНЮЄМО: Навігація до нового екрану AddItemScreen
                  Navigator.pushNamed(context, '/add_item'); 
                },
                style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF72585),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                child: const Text(
                  "Add",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _statusCard(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: softBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primaryPink),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _filterSortButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      height: 54, 
      width: 54,
      decoration: BoxDecoration(
        color: softBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF9A4D73)),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildWishlistItem(BuildContext context, WishItem item, WishListProvider provider) {
    final isPurchased = item.status == WishStatus.Purchased;

    final buttonColor = isPurchased ? const Color.fromARGB(255, 46, 205, 96) : primaryPink;
    final buttonText = isPurchased ? "Purchased!" : "Mark as Purchased";
    final onPressedHandler = isPurchased ? 
        () => provider.toggleWishStatus(item.id, WishStatus.Wanted) // Повернення у wanted
        : () => provider.toggleWishStatus(item.id, WishStatus.Purchased); // Перехід у purchased

    Color itemColor = isPurchased ? const Color(0xFFE0FDE0) : const Color(0xFFFDE0EB);
    
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: itemColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Title, Date, and Arrow (для навігації)
          GestureDetector(
            onTap: () {
                // FR6: Перехід до деталей
                Navigator.pushNamed(context, '/wish_details', arguments: item.id);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "Added ${item.dateAdded.month}/${item.dateAdded.day}/${item.dateAdded.year}",
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Color(0xFF9A4D73), size: 18), 
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Row 2: Action Buttons
          Row(
            children: [
              // Mark as Purchased Button (FR7)
              Expanded(
                child: ElevatedButton(
                  onPressed: onPressedHandler,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor, 
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: isPurchased ? 0 : 2, 
                  ),
                  child: Text(
                    buttonText, 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Edit Button (Навігація до деталей)
              GestureDetector(
                onTap: () {
                    Navigator.pushNamed(context, '/wish_details', arguments: item.id);
                },
                child: Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: softBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit, color: Color(0xFF9A4D73)),
                ),
              ),
              const SizedBox(width: 14),
              
              // Delete Button (FR5)
              GestureDetector(
                onTap: () {
                    provider.deleteWish(item.id); 
                },
                child: Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: softBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Color(0xFF9A4D73)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterMenu(BuildContext context, WishListProvider provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: const Text('All'), 
          onTap: () { provider.setFilter(null); Navigator.pop(context); },
          trailing: provider.filterStatus == null ? const Icon(Icons.check, color: primaryPink) : null,
        ),
        ListTile(
          title: const Text('Wanted'), 
          onTap: () { provider.setFilter(WishStatus.Wanted); Navigator.pop(context); },
          trailing: provider.filterStatus == WishStatus.Wanted ? const Icon(Icons.check, color: primaryPink) : null,
        ),
        ListTile(
          title: const Text('Purchased'), 
          onTap: () { provider.setFilter(WishStatus.Purchased); Navigator.pop(context); },
          trailing: provider.filterStatus == WishStatus.Purchased ? const Icon(Icons.check, color: primaryPink) : null,
        ),
      ],
    );
  }

  Widget _buildSortMenu(BuildContext context, WishListProvider provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: const Text('By Date Added'), 
          onTap: () { provider.setSortBy(WishSortBy.dateAdded); Navigator.pop(context); },
          trailing: provider.sortBy == WishSortBy.dateAdded ? const Icon(Icons.check, color: primaryPink) : null,
        ),
        ListTile(
          title: const Text('By Title (A-Z)'), 
          onTap: () { provider.setSortBy(WishSortBy.title); Navigator.pop(context); },
          trailing: provider.sortBy == WishSortBy.title ? const Icon(Icons.check, color: primaryPink) : null,
        ),
      ],
    );
  }
}