// lib/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_user_provider.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart'; // << ДОДАНО

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Контролери для окремих полів
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  
  static const Color primaryPink = Color(0xFFF72585);
  static const Color softBackground = Color(0xFFF7EAF0);

  @override
  void initState() {
    super.initState();
    
    // Отримання початкових даних з провайдера
    final user = Provider.of<AppUserProvider>(context, listen: false).user;
    final fullName = user?.name ?? 'User';
    
    // 🟢 Логіка розділення імені та прізвища (для ініціалізації полів)
    List<String> parts = fullName.trim().split(' ');
    String firstName = parts.isNotEmpty ? parts[0] : '';
    // Якщо є більше одного слова, вважаємо решту прізвищем
    String lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    
    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = context.read<AppUserProvider>();
    
    // 1. Об'єднання імені та прізвища (ВИМОГА КОРИСТУВАЧА)
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    // Об'єднуємо обидва поля в єдиний рядок для збереження у полі 'name'
    final combinedName = (firstName + ' ' + lastName).trim();

    // 2. Виклик функції збереження
    await provider.saveProfileChanges(newName: combinedName);

    // 3. Обробка результату
    if (provider.editState == ProfileEditState.success) {
      _showSnackbar("Profile successfully updated!");
      // Після успішного збереження повертаємося на сторінку профілю
      Navigator.pop(context); 
    } else if (provider.editState == ProfileEditState.error) {
      _showSnackbar("Save error: ${provider.errorMessage}", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppUserProvider>();
    final user = provider.user;
    final isProcessing = provider.editState == ProfileEditState.loading;

    final currentPhotoUrl = user?.profilePictureUrl;
    final displayImage = provider.selectedImage;

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
                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close), 
                    ),
                    const SizedBox(width: 12),
                    const Text("Edit Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 30),

                // Photo Placeholder (Рис. 8)
               Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      // Відображення фото
                      _buildProfilePicture(displayImage, currentPhotoUrl),
                      Positioned(
                        child: GestureDetector(
                          onTap: provider.pickImage, // Вибір нового фото
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: primaryPink,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Name Field
                const Text("Name", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _firstNameController,
                  enabled: !isProcessing,
                  decoration: _inputDecoration("Enter your name"),
                  validator: (v) => v!.isEmpty ? "Name is required." : null,
                ),
                const SizedBox(height: 20),

                // Surname Field
                const Text("Surname", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lastNameController,
                  enabled: !isProcessing,
                  decoration: _inputDecoration("Enter your surname"),
                  validator: (v) => v!.isEmpty ? "Surname is required." : null,
                ),
                const SizedBox(height: 20),
                
                // Email Display (Non-editable)
                const Text("Email", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                // 🟢 Відображення актуальної пошти
                Text(user?.email ?? 'N/A', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 50),

                // Save Button
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isProcessing ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: isProcessing 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Save", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildProfilePicture(File? displayImage, String? currentPhotoUrl) {
    ImageProvider? imageProvider;
    
    if (displayImage != null) {
      // 1. Вибране нове фото
      imageProvider = FileImage(displayImage);
    } else if (currentPhotoUrl != null && currentPhotoUrl.isNotEmpty) {
      // 2. Існуюче фото з Firebase Storage
      imageProvider = CachedNetworkImageProvider(currentPhotoUrl);
    } 

    return CircleAvatar(
      radius: 50,
      backgroundColor: softBackground,
      backgroundImage: imageProvider,
      child: (displayImage == null && (currentPhotoUrl == null || currentPhotoUrl.isEmpty))
          ? const Icon(Icons.person, size: 60, color: Colors.grey)
          : null,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: softBackground,
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
        borderSide: const BorderSide(color: primaryPink, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}

