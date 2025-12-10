import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';
import '../models/wish_item.dart';

class WishItemDetailsScreen extends StatelessWidget {
  const WishItemDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final itemId = ModalRoute.of(context)?.settings.arguments as String?;
    
    final item = context.read<WishlistProvider>().wishlist.firstWhere(
      (i) => i.id == itemId,
      orElse: () => WishItem(
        id: '',
        title: 'Not Found',
        description: '',
        category: '',
        cost: 0,
        dateAdded: DateTime.now(),
      ),
    );

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

              const Text("Title", style: _labelStyle),
              const SizedBox(height: 8),
              _buildTextField(titleController, "Enter title"),
              const SizedBox(height: 20),

              const Text("Description", style: _labelStyle),
              const SizedBox(height: 8),
              _buildTextField(descriptionController, "Enter description", maxLines: 5),
              const SizedBox(height: 20),

              const Text("Category", style: _labelStyle),
              const SizedBox(height: 8),
              _buildTextField(categoryController, "Enter category"),
              const SizedBox(height: 20),

              const Text("Cost", style: _labelStyle),
              const SizedBox(height: 8),
              _buildTextField(costController, "Enter cost"),
              const SizedBox(height: 20),

              const Text("Status", style: _labelStyle),
              const SizedBox(height: 8),
              _buildTextField(statusController, "Set status (e.g., wanted, purchased)"),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 120,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () {
                        // edit functionality (static for now)
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
                        // save functionality (static for now)
                        Navigator.pop(context); // go back after saving
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
              const SizedBox(height: 80), 
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