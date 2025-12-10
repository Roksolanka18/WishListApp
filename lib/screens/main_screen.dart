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
      // реєструє функцію, яка буде виконана один раз одразу після того, як віджет буде повністю побудований та відображений на екрані
      if (_selectedIndex == 0) {
        Provider.of<WishlistProvider>(context, listen: false).loadWishlist(); // використовується для доступу до екземпляра WishlistProvider
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

class WishlistContent extends StatelessWidget {
  const WishlistContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>( // віджет, який підписує своє піддерево на зміни у WishlistProvider
      builder: (context, provider, child) {
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
          // успішно завантажені дані
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statusCard(
                        Icons.favorite, 
                        "${provider.filteredWishlist.where((i) => i.status == WishStatus.Wanted).length} wanted"
                    ),
                    _statusCard(
                        Icons.shopping_bag, 
                        "${provider.filteredWishlist.where((i) => i.status == WishStatus.Purchased).length} purchased"
                    ),
                  ],
                ),
                const SizedBox(height: 20),

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
                    _filterSortButton(
                      icon: Icons.filter_list,
                      onPressed: () => _showFilterDialog(context),
                    ),
                    const SizedBox(width: 8),
                    _filterSortButton(
                      icon: Icons.sort,
                      onPressed: () => _showSortDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Text(
                  "${provider.filteredWishlist.length} item${provider.filteredWishlist.length != 1 ? 's' : ''}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

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
                
                // add button 
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
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
    final isPurchased = item.status == WishStatus.Purchased;

    final buttonColor = isPurchased ? const Color(0xFF4CAF50) : const Color(0xFFF72585);
    final buttonText = isPurchased ? "Purchased!" : "Mark as Purchased";
    final onPressedHandler = isPurchased ? null : () { 
      // тут буде логіка переходу статусу у "придбано"
    };

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
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onPressedHandler,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor, 
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: isPurchased ? 0 : 2, // зменшуємо тінь, якщо неактивна
                  ),
                  child: Text(
                    buttonText, // динамічний текст
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
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
              
              GestureDetector(
                onTap: () {
                    // placeholder для логіки видалення
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
                trailing: context.read<WishlistProvider>().filterStatus == WishStatus.Wanted
                    ? const Icon(Icons.check, color: Color(0xFFF72585)) : null,
                onTap: () {
                  context.read<WishlistProvider>().setFilter(WishStatus.Wanted);
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                title: const Text('Purchased'),
                trailing: context.read<WishlistProvider>().filterStatus == WishStatus.Purchased
                    ? const Icon(Icons.check, color: Color(0xFFF72585)) : null,
                onTap: () {
                  context.read<WishlistProvider>().setFilter(WishStatus.Purchased);
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

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