import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';
import '../models/wish_item.dart';

class WishItemDetailsScreen extends StatelessWidget {
  const WishItemDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final itemId = ModalRoute.of(context)?.settings.arguments as String?;
    
    // Find the item using the provider's hardcoded data for simplicity
    final item = context.read<WishlistProvider>().wishlist.firstWhere(
      (i) => i.id == itemId,
      // Provide a fallback in case the item isn't found
      orElse: () => WishItem(
        id: '',
        title: 'Not Found',
        description: '',
        category: '',
        cost: 0,
        dateAdded: DateTime.now(),
      ),
    );

    // TextControllers for editable fields (static form for now)
    final titleController = TextEditingController(text: item.title);
    final descriptionController = TextEditingController(text: item.description);
    final categoryController = TextEditingController(text: item.category);
    final costController = TextEditingController(text: item.cost.toString());
    final statusController = TextEditingController(text: item.status.toString().split('.').last);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Wish Item Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- Title ---
              const Text("Title", style: _labelStyle),
              const SizedBox(height: 8),
              _buildTextField(titleController, "Enter title"),
              const SizedBox(height: 20),

              // --- Description ---
              const Text("Description", style: _labelStyle),
              const SizedBox(height: 8),
              _buildTextField(descriptionController, "Enter description", maxLines: 5),
              const SizedBox(height: 20),

              // --- Category ---
              const Text("Category", style: _labelStyle),
              const SizedBox(height: 8),
              _buildTextField(categoryController, "Enter category"),
              const SizedBox(height: 20),

              // --- Cost ---
              const Text("Cost", style: _labelStyle),
              const SizedBox(height: 8),
              _buildTextField(costController, "Enter cost"),
              const SizedBox(height: 20),

              // --- Status ---
              const Text("Status", style: _labelStyle),
              const SizedBox(height: 8),
              _buildTextField(statusController, "Set status (e.g., wanted, purchased)"),
              const SizedBox(height: 30),

              // --- Buttons ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 120,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () {
                        // Edit functionality (static for now)
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7EAF0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide.none,
                      ),
                      child: const Text(
                        "Edit",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        // Save functionality (static for now)
                        Navigator.pop(context); // Go back after saving
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF72585),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80), // Space for bottom nav bar
            ],
          ),
        ),
      ),
    );
  }

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 16, 
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9A4D73)),
        filled: true,
        fillColor: const Color(0xFFF7EAF0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}