// lib/providers/app_user_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart';
import '../user_repository.dart';
import '../storage_repository.dart'; // << ДОДАНО

enum ProfileLoadState { initial, loading, loaded, error }
enum ProfileEditState { initial, loading, success, error }

class AppUserProvider with ChangeNotifier {
  final UserRepository _userRepository;
  final StorageRepository _storageRepository; // << ДОДАНО

  ProfileLoadState _loadState = ProfileLoadState.initial;
  ProfileEditState _editState = ProfileEditState.initial;

  AppUser? _user;
  String? _errorMessage;
  File? _selectedImage; // << Тимчасове зберігання обраного фото

  AppUserProvider(this._userRepository, this._storageRepository); // << ПРИЙМАЄ STORAGE

  ProfileLoadState get loadState => _loadState;
  ProfileEditState get editState => _editState;
  AppUser? get user => _user;
  File? get selectedImage => _selectedImage; // << ГЕТЕР
  String? get errorMessage => _errorMessage;

  // 1. Завантаження даних профілю
  Future<void> fetchUserProfile() async {
    _loadState = ProfileLoadState.loading;
    notifyListeners();
    try {
      _user = await _userRepository.fetchUserProfile();
      _loadState = ProfileLoadState.loaded;
    } catch (e) {
      _loadState = ProfileLoadState.error;
      _errorMessage = 'Failed to load user profile: ${e.toString()}';
    }
    notifyListeners();
  }
  
  // 2. Вибір фото з галереї (Завдання 6)
  void pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  // 3. Збереження змін (ім'я та фото)
  Future<void> saveProfileChanges({required String newName}) async {
    if (_user == null) return;
    
    _editState = ProfileEditState.loading;
    notifyListeners();

    try {
      String? newImageUrl = _user!.profilePictureUrl;

      // 3.1. Якщо вибрано нове зображення, завантажуємо його у Storage (Завдання 6)
      if (_selectedImage != null) {
        String? oldUrl = _user!.profilePictureUrl;
        
        // Завантаження нового фото та отримання його URL
        newImageUrl = await _storageRepository.uploadProfilePicture(_selectedImage!);
        
        // Видалення старого фото
        if (oldUrl != null && oldUrl.isNotEmpty) {
           await _storageRepository.deleteFileByUrl(oldUrl);
        }
      }

      // 3.2. Оновлення імені та нового URL у Firestore
      await _userRepository.updateUserNameAndPictureUrl(
        name: newName,
        profilePictureUrl: newImageUrl,
      );
      
      // 3.3. Оновлення локальної моделі після успішного збереження
      _user = _user!.copyWith(
        name: newName,
        profilePictureUrl: newImageUrl,
      );

      _selectedImage = null; // Очищення тимчасового стану
      _editState = ProfileEditState.success;
      
    } catch (e) {
      _editState = ProfileEditState.error;
      _errorMessage = 'Failed to save changes: ${e.toString()}';
    }
    notifyListeners();
  }
}