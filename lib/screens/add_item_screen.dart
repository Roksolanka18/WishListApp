// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/create_edit_wish_provider.dart';
import '../providers/wishlist_provider.dart';
import '../models/wish_item.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  static const List<String> _categories = [
    'Electronics',
    'Travel',
    'Clothing',
    'Home Goods',
    'Vehicle',
    'Self-Development',
    'Other',
  ];
  
  String? _selectedCategory; 


  static const Color primaryPink = Color(0xFFF72585);
  static const Color softBackground = Color(0xFFF7EAF0);
  static const TextStyle _labelStyle = TextStyle(
    fontSize: 16, 
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : primaryPink,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveNewWish() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<CreateEditWishProvider>();
    final newCost = double.tryParse(_costController.text.trim());

    await provider.saveWish(
      existingId: null, 
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory!, 
      cost: newCost ?? 0.0,
      status: WishStatus.Wanted, 
      dateAdded: DateTime.now(),
    );

    if (provider.state == CreateEditState.success) {
      _showSnackbar("Wish successfully added!");
      provider.resetState();
      
      Navigator.pop(context); 
      
      // оновлюємо список на головній сторінці
      Provider.of<WishListProvider>(context, listen: false).fetchWishes();

    } else if (provider.state == CreateEditState.error) {
      _showSnackbar("Error saving wish: ${provider.errorMessage}", isError: true);
      provider.resetState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = context.watch<CreateEditWishProvider>().state == CreateEditState.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close), 
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Add Item", 
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
                _buildTextField(_titleController, "Title", 
                    validator: (v) => v!.isEmpty ? "Title is required." : null,
                    fillColor: Colors.white, 
                ),
                const SizedBox(height: 20),

                const Text("Description (Optional)", style: _labelStyle),
                const SizedBox(height: 8),
                _buildTextField(_descriptionController, "Description (Optional)", maxLines: 5, fillColor: Colors.white),
                const SizedBox(height: 20),
                
                const Text("Category", style: _labelStyle),
                const SizedBox(height: 8),
                _buildCategoryDropdown(
                  currentValue: _selectedCategory,
                  categories: _categories,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  validator: (v) => v == null || v.isEmpty ? "Category is required." : null,
                ),
                const SizedBox(height: 20),

                const Text("Cost (Optional)", style: _labelStyle),
                const SizedBox(height: 8),
                _buildTextField(
                  _costController, 
                  "Cost (Optional)", 
                  keyboardType: TextInputType.number, 
                  fillColor: Colors.white,
                  validator: (v) => v!.isNotEmpty && double.tryParse(v) == null ? "Enter a valid cost." : null,
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: softBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide.none,
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.black87, fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isProcessing ? null : _saveNewWish, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isProcessing 
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : const Text(
                                "Save",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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
      ),
    );
  }

  Widget _buildCategoryDropdown({
    required List<String> categories,
    required void Function(String?) onChanged,
    required String? currentValue,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: currentValue, 
      items: categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: "Category",
        hintStyle: const TextStyle(color: Color(0xFF9A4D73)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }


  Widget _buildTextField(
    TextEditingController controller, 
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Color fillColor = softBackground,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9A4D73)),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}