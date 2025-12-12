import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart';
import '../user_repository.dart';
import '../storage_repository.dart'; 

enum ProfileLoadState { initial, loading, loaded, error }
enum ProfileEditState { initial, loading, success, error }

class AppUserProvider with ChangeNotifier {
  final UserRepository _userRepository;
  final StorageRepository _storageRepository; 

  ProfileLoadState _loadState = ProfileLoadState.initial;
  ProfileEditState _editState = ProfileEditState.initial;

  AppUser? _user;
  String? _errorMessage;
  File? _selectedImage; // тимчасове зберігання обраного фото

  AppUserProvider(this._userRepository, this._storageRepository);

  ProfileLoadState get loadState => _loadState;
  ProfileEditState get editState => _editState;
  AppUser? get user => _user;
  File? get selectedImage => _selectedImage; 
  String? get errorMessage => _errorMessage;

  // завантаження даних профілю
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
  
  // вибір фото з галереї
  void pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  // збереження змін (ім'я та фото)
  Future<void> saveProfileChanges({required String newName}) async {
    if (_user == null) return;
    
    _editState = ProfileEditState.loading;
    notifyListeners();

    try {
      String? newImageUrl = _user!.profilePictureUrl;

      // якщо вибрано нове зображення, завантажуємо його у Storage
      if (_selectedImage != null) {
        String? oldUrl = _user!.profilePictureUrl;
        
        // завантаження нового фото та отримання його url
        newImageUrl = await _storageRepository.uploadProfilePicture(_selectedImage!);
        
        // dидалення старого фото
        if (oldUrl != null && oldUrl.isNotEmpty) {
           await _storageRepository.deleteFileByUrl(oldUrl);
        }
      }

      // оновлення імені та нового URL у Firestore
      await _userRepository.updateUserNameAndPictureUrl(
        name: newName,
        profilePictureUrl: newImageUrl,
      );
      
      // оновлення локальної моделі після успішного збереження
      _user = _user!.copyWith(
        name: newName,
        profilePictureUrl: newImageUrl,
      );

      _selectedImage = null; // очищення тимчасового стану
      _editState = ProfileEditState.success;
      
    } catch (e) {
      _editState = ProfileEditState.error;
      _errorMessage = 'Failed to save changes: ${e.toString()}';
    }
    notifyListeners();
  }
}