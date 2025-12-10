import 'package:flutter/material.dart';
import 'package:wishlist_app/models/wish_item.dart';
import 'dart:async';

enum LoadingStatus { initial, loading, loaded, error }
enum WishSortBy { dateAdded, title }

class WishlistProvider with ChangeNotifier {
  LoadingStatus _status = LoadingStatus.initial;
  List<WishItem> _wishlist = [];
  String _errorMessage = '';
  WishSortBy _sortBy = WishSortBy.dateAdded; // поточний критерій сортування
  WishStatus? _filterStatus;

  LoadingStatus get status => _status;
  List<WishItem> get wishlist => _wishlist;
  String get errorMessage => _errorMessage;
  WishSortBy get sortBy => _sortBy;
  WishStatus? get filterStatus => _filterStatus;

  List<WishItem> get filteredWishlist {
    Iterable<WishItem> filtered = _wishlist.where((item) => 
        _filterStatus == null || item.status == _filterStatus);

    switch (_sortBy) {
      case WishSortBy.dateAdded:
        filtered = filtered.toList()..sort((a, b) => b.dateAdded.compareTo(a.dateAdded)); 
        break;
      case WishSortBy.title:
        filtered = filtered.toList()..sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return filtered.toList();
  }

  final List<WishItem> _hardcodedData = [
    WishItem(
      id: '1',
      title: 'Buy a car',
      description: 'A blue Tesla Model 3 Long Range.',
      category: 'Vehicle',
      cost: 50000.0,
      dateAdded: DateTime(2025, 9, 28),
      status: WishStatus.Wanted,
    ),
    WishItem(
      id: '2',
      title: 'New Laptop',
      description: 'MacBook Pro M3 Max, 32GB RAM.',
      category: 'Electronics',
      cost: 3500.0,
      dateAdded: DateTime(2025, 10, 15),
      status: WishStatus.Purchased,
    ),
    WishItem(
      id: '3',
      title: 'Vacation to Bali',
      description: 'Two weeks trip to Bali with full resort access.',
      category: 'Travel',
      cost: 4500.0,
      dateAdded: DateTime(2025, 11, 1),
      status: WishStatus.Wanted,
    ),
    WishItem(
      id: '4',
      title: 'Electric Scooter',
      description: 'High-speed electric scooter for city commuting.',
      category: 'Vehicle',
      cost: 800.0,
      dateAdded: DateTime(2025, 11, 20),
      status: WishStatus.Wanted,
    ),
    WishItem(
      id: '5',
      title: 'New Phone',
      description: 'Latest iPhone model.',
      category: 'Electronics',
      cost: 1500.0,
      dateAdded: DateTime(2025, 11, 25),
      status: WishStatus.Wanted,
    ),
    WishItem(
      id: '6',
      title: 'Coffee Machine',
      description: 'High-end espresso machine for home use.',
      category: 'Home Goods',
      cost: 1200.0,
      dateAdded: DateTime(2025, 12, 1),
      status: WishStatus.Purchased,
    ),
    WishItem(
      id: '7',
      title: 'Skiing trip to Alps',
      description: 'Weekend skiing in the French Alps.',
      category: 'Travel',
      cost: 2500.0,
      dateAdded: DateTime(2025, 12, 10),
      status: WishStatus.Wanted,
    ),
    WishItem(
      id: '8',
      title: 'Digital Camera',
      description: 'Mirrorless camera for photography.',
      category: 'Electronics',
      cost: 2200.0,
      dateAdded: DateTime(2025, 12, 15),
      status: WishStatus.Wanted,
    ),
    WishItem(
      id: '9',
      title: 'Smart Watch',
      description: 'Latest model of Apple Watch.',
      category: 'Accessories',
      cost: 450.0,
      dateAdded: DateTime(2025, 12, 18),
      status: WishStatus.Wanted,
    ),
  ];


  Future<void> loadWishlist({bool shouldFail = false}) async {
    _status = LoadingStatus.loading;
    _errorMessage = '';
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); 

    if (shouldFail) {
      _status = LoadingStatus.error;
      _errorMessage = 'An unexpected error occurred';
    } else {
      _status = LoadingStatus.loaded;
      _wishlist = _hardcodedData;
    }
    notifyListeners();
  }

  void setFilter(WishStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setSortBy(WishSortBy sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }
}