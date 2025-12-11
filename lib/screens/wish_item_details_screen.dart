// lib/screens/wish_item_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/create_edit_wish_provider.dart'; 
import '../models/wish_item.dart';

class WishItemDetailsScreen extends StatefulWidget {
  const WishItemDetailsScreen({super.key});

  @override
  State<WishItemDetailsScreen> createState() => _WishItemDetailsScreenState();
}

class _WishItemDetailsScreenState extends State<WishItemDetailsScreen> {
  // Стан для керування режимом редагування
  bool _isEditing = false;
  
  // Контролери для полів вводу
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _costController;

  // Початковий елемент (містить ID та дату)
  late WishItem _initialItem; 
  
  // Змінні стану для обраних значень Dropdown
  String? _selectedCategory; 
  String? _selectedStatus; 

  // Списки для Dropdown
  static const List<String> _categories = [
    'Electronics',
    'Travel',
    'Clothing',
    'Home Goods',
    'Vehicle',
    'Self-Development',
    'Other',
  ];
  static const List<String> _statusOptions = [
    'Wanted',
    'Purchased',
  ];

  // Стилі
  static const Color primaryPink = Color(0xFFF72585);
  static const Color softBackground = Color(0xFFF7EAF0);
  static const TextStyle _labelStyle = TextStyle(
    fontSize: 16, 
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!mounted) return;

    final itemId = ModalRoute.of(context)?.settings.arguments as String?;
    final provider = context.read<WishListProvider>();
    
    // Знаходимо елемент
    _initialItem = provider.wishlist.firstWhere(
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

    // Ініціалізація контролерів
    _titleController = TextEditingController(text: _initialItem.title);
    _descriptionController = TextEditingController(text: _initialItem.description);
    _costController = TextEditingController(text: _initialItem.cost.toString());

    // Ініціалізація обраних значень Dropdown
    _selectedCategory = _initialItem.category;
    _selectedStatus = _initialItem.status.toFirestoreString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = true;
    });
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

  Future<void> _saveChanges() async {
    final provider = context.read<CreateEditWishProvider>();
    final listProvider = Provider.of<WishListProvider>(context, listen: false);

    final newTitle = _titleController.text.trim();
    final newCost = double.tryParse(_costController.text.trim());

    // 1. Валідація
    if (newTitle.isEmpty || newCost == null || newCost < 0) {
      _showSnackbar("Please enter valid Title and Cost.", isError: true);
      return;
    }
    if (_selectedCategory == null || _selectedStatus == null) {
      _showSnackbar("Category and Status must be selected.", isError: true);
      return;
    }
    
    // Перетворення рядка статусу назад в Enum
    final newStatus = _selectedStatus == 'Purchased' ? WishStatus.Purchased : WishStatus.Wanted;

    // 2. Виклик функції оновлення (Завдання 5, FR4)
    await provider.saveWish(
      existingId: _initialItem.id, // ID елемента для оновлення
      title: newTitle,
      description: _descriptionController.text.trim(),
      category: _selectedCategory!, 
      cost: newCost,
      status: newStatus,
      dateAdded: _initialItem.dateAdded, // Зберігаємо оригінальну дату
    );

    // 3. Обробка результату
    if (provider.state == CreateEditState.success) {
      _showSnackbar("Wish successfully updated!");
      
      // >>> ВИПРАВЛЕННЯ: ЕКСПЛІЦИТНИЙ ВИКЛИК ОНОВЛЕННЯ СПИСКУ <<<
      // Це змушує головний екран перезавантажити дані з Firestore
      await listProvider.fetchWishes();      // >>> КІНЕЦЬ ВИПРАВЛЕННЯ <<<
      
      setState(() {
        _isEditing = false; // Вимикаємо режим редагування
      });
      // Оновлюємо _initialItem для відображення нових даних
      _initialItem = _initialItem.copyWith(
        title: newTitle,
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        cost: newCost,
        status: newStatus,
      );
    } else if (provider.state == CreateEditState.error) {
      _showSnackbar("Save error: ${provider.errorMessage}", isError: true);
    }
    
    provider.resetState();
  }

  @override
  Widget build(BuildContext context) {
    // Прослуховуємо стан CreateEditWishProvider для відображення індикатора
    final createEditState = context.watch<CreateEditWishProvider>().state;

    // Перевіряємо валідність елемента
    final isItemValid = _initialItem.id.isNotEmpty;
    // Вимикаємо UI під час завантаження
    final isProcessing = createEditState == CreateEditState.loading;
    final isUIEnabled = !isProcessing && isItemValid;

    // Якщо елемент не знайдено, показуємо помилку
    if (!isItemValid) {
        return Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: const Center(child: Text("Wish item not found.")),
        );
    }

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

              // Поля вводу
              const Text("Title", style: _labelStyle),
              const SizedBox(height: 8),
              _buildTextField(_titleController, "Enter title", enabled: _isEditing && isUIEnabled),
              const SizedBox(height: 20),

              const Text("Description", style: _labelStyle),
              const SizedBox(height: 8),
              _buildTextField(_descriptionController, "Enter description", maxLines: 5, enabled: _isEditing && isUIEnabled),
              const SizedBox(height: 20),

              // Category Dropdown
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
                  enabled: _isEditing && isUIEnabled, // Увімкнено лише в режимі редагування
                  validator: (v) => v == null || v!.isEmpty ? "Category is required." : null,
              ),
              const SizedBox(height: 20),

              const Text("Cost", style: _labelStyle),
              const SizedBox(height: 8),
              _buildTextField(_costController, "Enter cost", keyboardType: TextInputType.number, enabled: _isEditing && isUIEnabled),
              const SizedBox(height: 20),

              // Status Dropdown
              const Text("Status", style: _labelStyle),
              const SizedBox(height: 8),
              _buildStatusDropdown(
                  currentValue: _selectedStatus,
                  statusOptions: _statusOptions,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatus = newValue;
                    });
                  },
                  enabled: _isEditing && isUIEnabled, // Увімкнено лише в режимі редагування
                  validator: (v) => v == null || v!.isEmpty ? "Status is required." : null,
              ),
              const SizedBox(height: 30),

              if (isProcessing)
                const Center(child: CircularProgressIndicator(color: primaryPink))
              else 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 54,
                      child: OutlinedButton(
                        // LEFT SIDE: Edit Button
                        onPressed: _isEditing || isProcessing ? null : _toggleEditMode, 
                        style: OutlinedButton.styleFrom(
                          backgroundColor: (_isEditing || isProcessing) ? Colors.grey.shade300 : softBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide.none,
                        ),
                        child: Text(
                          _isEditing ? "Editing..." : "Edit",
                          style: TextStyle(
                            color: (_isEditing || isProcessing) ? Colors.black54 : Colors.black87,
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
                        // RIGHT SIDE: Save Button
                        onPressed: _isEditing && !isProcessing ? _saveChanges : null, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (_isEditing && !isProcessing) ? primaryPink : Colors.grey.shade400,
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

  // --- Helper Widget for Category Dropdown ---
  Widget _buildCategoryDropdown({
    required List<String> categories,
    required void Function(String?) onChanged,
    required String? currentValue,
    required bool enabled, 
    String? Function(String?)? validator,
  }) {
    final fillColor = enabled ? Colors.white : softBackground;
    final textStyle = TextStyle(color: enabled ? Colors.black87 : Colors.black54);

    return DropdownButtonFormField<String>(
      value: currentValue, 
      items: categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null, 
      validator: enabled ? validator : null,
      decoration: InputDecoration(
        hintText: "Category",
        hintStyle: const TextStyle(color: Color(0xFF9A4D73)),
        filled: true,
        fillColor: fillColor,
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
        disabledBorder: OutlineInputBorder( 
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      style: textStyle,
      icon: enabled ? const Icon(Icons.arrow_drop_down) : null, 
    );
  }
  
  // --- Helper Widget for Status Dropdown ---
  Widget _buildStatusDropdown({
    required List<String> statusOptions,
    required void Function(String?) onChanged,
    required String? currentValue,
    required bool enabled, 
    String? Function(String?)? validator,
  }) {
    final fillColor = enabled ? Colors.white : softBackground;
    final textStyle = TextStyle(color: enabled ? Colors.black87 : Colors.black54);
    
    return DropdownButtonFormField<String>(
      value: currentValue, 
      items: statusOptions.map((String status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(status.substring(0, 1).toUpperCase() + status.substring(1)), // Capitalize first letter
        );
      }).toList(),
      onChanged: enabled ? onChanged : null, 
      validator: enabled ? validator : null,
      decoration: InputDecoration(
        hintText: "Status",
        hintStyle: const TextStyle(color: Color(0xFF9A4D73)),
        filled: true,
        fillColor: fillColor,
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
        disabledBorder: OutlineInputBorder( 
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      style: textStyle,
      icon: enabled ? const Icon(Icons.arrow_drop_down) : null, 
    );
  }


  // --- Helper Widget for TextFormField ---
  Widget _buildTextField(
    TextEditingController controller, 
    String hint, {
    int maxLines = 1,
    bool enabled = false, 
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled, 
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9A4D73)),
        filled: true,
        fillColor: enabled ? const Color(0xFFFFFFFF) : softBackground, 
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(color: enabled ? Colors.black87 : Colors.black54),
    );
  }
}