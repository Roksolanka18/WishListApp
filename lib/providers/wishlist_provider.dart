import 'package:flutter/material.dart';
import '../models/wish_item.dart';
import '../wish_repository.dart';
import 'dart:async'; 

enum WishListState { initial, loading, loaded, error }
enum WishSortBy { dateAdded, title } 

class WishListProvider with ChangeNotifier {
  final BaseWishRepository _wishRepository;
  
  WishListState _state = WishListState.initial;
  List<WishItem> _wishlist = []; 
  String _errorMessage = '';
  
  WishSortBy _sortBy = WishSortBy.dateAdded; 
  WishStatus? _filterStatus; 
  String _searchQuery = ''; 

  WishListProvider(this._wishRepository) {
    fetchWishes(); 
  }

  WishListState get state => _state;
  List<WishItem> get wishlist => _wishlist;
  String get errorMessage => _errorMessage;
  WishSortBy get sortBy => _sortBy;
  WishStatus? get filterStatus => _filterStatus;
  String get searchQuery => _searchQuery; 

  List<WishItem> get filteredWishlist {
    Iterable<WishItem> filtered = _wishlist;
    
    if (_filterStatus != null) {
      filtered = filtered.where((item) => item.status == _filterStatus);
    }
    
    if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        filtered = filtered.where((item) => 
            item.title.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query)
        );
    }

    List<WishItem> sorted = filtered.toList();

    switch (_sortBy) {
      case WishSortBy.dateAdded:
        sorted.sort((a, b) => b.dateAdded.compareTo(a.dateAdded)); 
        break;
      case WishSortBy.title:
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return sorted;
  }
  
  Future<void> fetchWishes() async {
    _state = WishListState.loading;
    notifyListeners();
    try {
      _wishlist = await _wishRepository.getWishes(); 
      _state = WishListState.loaded;
    } catch (e) {
      _state = WishListState.error;
      _errorMessage = 'Failed to load wishes: $e';
    }
    notifyListeners();
  }
  
  Future<void> _refreshListAfterChange(Future<void> operation) async {
      try {
          await operation;
          await fetchWishes();
      } catch (e) {
          _state = WishListState.error;
          _errorMessage = 'Operation failed: $e';
          notifyListeners();
      }
  }

  //методи CRUD, що викликають оновлення
  Future<void> toggleWishStatus(String id, WishStatus newStatus) async {
    await _refreshListAfterChange(
        _wishRepository.toggleWishStatus(id, newStatus)
    );
  }
  
  Future<void> deleteWish(String id) async {
    await _refreshListAfterChange(
        _wishRepository.deleteWish(id)
    );
  }
  
  void setFilter(WishStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setSortBy(WishSortBy sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }
  
  void setSearchQuery(String query) {
      if (_searchQuery != query) {
          _searchQuery = query;
          notifyListeners();
      }
  }
}