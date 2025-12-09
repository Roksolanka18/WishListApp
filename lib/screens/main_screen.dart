import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/wishlist_provider.dart';
import '../models/wish_item.dart';
import 'profile_screen.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; 

  final List<Widget> _screens = [
    const WishlistContent(), 
    const ProfileScreen(), 
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedIndex == 0) {
        Provider.of<WishlistProvider>(context, listen: false).loadWishlist();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      body: _screens[_selectedIndex], 

      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 0) {
              Provider.of<WishlistProvider>(context, listen: false).loadWishlist();
            }
          });
        },
      ),
    );
  }
}

// --- Wishlist Content Widget ---
class WishlistContent extends StatelessWidget {
  const WishlistContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, provider, child) {
        // Логіка відображення стану (Task 2)
        Widget content;
        if (provider.status == LoadingStatus.loading) {
          content = const Center(child: CircularProgressIndicator());
        } else if (provider.status == LoadingStatus.error) {
          content = Center(
            child: Text('Error: ${provider.errorMessage}'),
          );
        } else if (provider.filteredWishlist.isEmpty) {
          content = const Center(
            child: Text("Your wishlist is empty."),
          );
        } else {
          // Успішно завантажені дані
          content = Expanded(
            child: ListView.builder(
              itemCount: provider.filteredWishlist.length,
              itemBuilder: (context, index) {
                return _wishlistItem(context, provider.filteredWishlist[index]);
              },
            ),
          );
        }

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

                // Status Cards 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statusCard(
                        Icons.favorite, 
                        "${provider.filteredWishlist.where((i) => i.status == WishStatus.wanted).length} wanted"
                    ),
                    _statusCard(
                        Icons.shopping_bag, 
                        "${provider.filteredWishlist.where((i) => i.status == WishStatus.purchased).length} purchased"
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search/Filter/Sort Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search items...",
                          filled: true,
                          fillColor: const Color(0xFFF7EAF0),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF9A4D73)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Filter Button
                    _filterSortButton(
                      icon: Icons.filter_list,
                      onPressed: () => _showFilterDialog(context),
                    ),
                    const SizedBox(width: 8),
                    // Sort Button
                    _filterSortButton(
                      icon: Icons.sort,
                      onPressed: () => _showSortDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Item count
                Text(
                  "${provider.filteredWishlist.length} item${provider.filteredWishlist.length != 1 ? 's' : ''}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                // List Content (Conditional based on loading status)
                Expanded(
                  child: provider.status == LoadingStatus.loading || provider.status == LoadingStatus.error
                      ? Center(child: content)
                      : ListView.builder(
                          itemCount: provider.filteredWishlist.length,
                          itemBuilder: (context, index) {
                            return _wishlistItem(context, provider.filteredWishlist[index]);
                          },
                        ),
                ),
                
                // Add Button 
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
                      // Example to simulate crash
                      throw Exception("Test Crash from Flutter button");
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
      },
    );
  }

  Widget _statusCard(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF7EAF0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFF72585)),
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
        color: const Color(0xFFF7EAF0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF9A4D73)),
        onPressed: onPressed,
      ),
    );
  }

  Widget _wishlistItem(BuildContext context, WishItem item) {
    // 1. Визначаємо, чи елемент придбаний
    final isPurchased = item.status == WishStatus.purchased;

    // 2. Встановлюємо динамічні властивості кнопки
    final buttonColor = isPurchased ? const Color(0xFF9A4D73) : const Color(0xFFF72585);
    final buttonText = isPurchased ? "Purchased!" : "Mark as Purchased";
    final onPressedHandler = isPurchased ? null : () { 
      // Тут буде логіка переходу статусу у "придбано"
    };

    // 3. Визначення кольору фону елемента
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
              // Mark as Purchased Button (Динамічний)
              Expanded(
                child: ElevatedButton(
                  onPressed: onPressedHandler,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor, // Динамічний колір
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: isPurchased ? 0 : 2, // Зменшуємо тінь, якщо неактивна
                  ),
                  child: Text(
                    buttonText, // Динамічний текст
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Edit Button (Навігація)
              GestureDetector(
                onTap: () {
                    Navigator.pushNamed(context, '/wish_details', arguments: item.id);
                },
                child: Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EAF0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit, color: Color(0xFF9A4D73)),
                ),
              ),
              const SizedBox(width: 14),
              
              // Delete Button
              GestureDetector(
                onTap: () {
                    // Placeholder for actual Delete logic
                },
                child: Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EAF0),
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

  // --- Filter Dialog ---
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Filter by Status"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('All'),
                trailing: context.read<WishlistProvider>().filterStatus == null 
                    ? const Icon(Icons.check, color: Color(0xFFF72585)) : null,
                onTap: () {
                  context.read<WishlistProvider>().setFilter(null);
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                title: const Text('Wanted'),
                trailing: context.read<WishlistProvider>().filterStatus == WishStatus.wanted
                    ? const Icon(Icons.check, color: Color(0xFFF72585)) : null,
                onTap: () {
                  context.read<WishlistProvider>().setFilter(WishStatus.wanted);
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                title: const Text('Purchased'),
                trailing: context.read<WishlistProvider>().filterStatus == WishStatus.purchased
                    ? const Icon(Icons.check, color: Color(0xFFF72585)) : null,
                onTap: () {
                  context.read<WishlistProvider>().setFilter(WishStatus.purchased);
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Sort Dialog ---
  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Sort by"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Date Added (Newest)'),
                trailing: context.read<WishlistProvider>().sortBy == WishSortBy.dateAdded
                    ? const Icon(Icons.check, color: Color(0xFFF72585)) : null,
                onTap: () {
                  context.read<WishlistProvider>().setSortBy(WishSortBy.dateAdded);
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                title: const Text('Title (A-Z)'),
                trailing: context.read<WishlistProvider>().sortBy == WishSortBy.title
                    ? const Icon(Icons.check, color: Color(0xFFF72585)) : null,
                onTap: () {
                  context.read<WishlistProvider>().setSortBy(WishSortBy.title);
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}