import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // для відстеження активної вкладки

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      body: SafeArea(
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
                  _statusCard(Icons.favorite, "1 wanted"),
                  _statusCard(Icons.shopping_bag, "0 purchased"),
                ],
              ),
              const SizedBox(height: 20),

              TextField(
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
              const SizedBox(height: 20),

              const Text(
                "1 item",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              _wishlistItem(),

              const Spacer(),

              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {  throw Exception("Test Crash from Flutter button");},
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
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
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

  Widget _wishlistItem() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE0EB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Buy a car",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Text(
            "Added 9/28/2025",
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF72585),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Mark as Purchased",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EAF0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit, color: Color(0xFF9A4D73)),
              ),
              const SizedBox(width: 14),
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EAF0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Color(0xFF9A4D73)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
