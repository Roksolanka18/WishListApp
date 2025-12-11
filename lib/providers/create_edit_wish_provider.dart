// lib/providers/create_edit_wish_provider.dart
import 'package:flutter/material.dart';
import '../models/wish_item.dart';
import '../wish_repository.dart';

enum CreateEditState { 
  initial, 
  loading, 
  success, 
  error    
}

class CreateEditWishProvider with ChangeNotifier {
  final BaseWishRepository _wishRepository;
  
  CreateEditState _state = CreateEditState.initial;
  String? _errorMessage;
  
  CreateEditWishProvider(this._wishRepository);

  CreateEditState get state => _state;
  String? get errorMessage => _errorMessage;

  void _setState(CreateEditState newState, {String? message}) {
    _state = newState;
    _errorMessage = message;
    notifyListeners();
  }

  // Завдання 5: Логіка збереження (створення або редагування)
  Future<void> saveWish({
    required String title,
    required String description,
    required String category,
    required double cost,
    String? existingId, 
    WishStatus status = WishStatus.Wanted,
    DateTime? dateAdded,
  }) async {
    _setState(CreateEditState.loading);

    try {
      final wishToSave = WishItem(
        id: existingId ?? 'temporary-id', 
        title: title,
        description: description,
        category: category,
        cost: cost,
        dateAdded: dateAdded ?? DateTime.now(),
        status: status,
      );

      if (existingId != null) {
        // Редагування (FR4)
        await _wishRepository.updateWish(wishToSave.copyWith(id: existingId));
      } else {
        // Створення (FR3)
        await _wishRepository.addWish(wishToSave); 
      }

      _setState(CreateEditState.success);
    } catch (e) {
      _setState(CreateEditState.error, message: 'Operation failed: ${e.toString()}');
    }
  }

  void resetState() {
    _setState(CreateEditState.initial);
  }
}