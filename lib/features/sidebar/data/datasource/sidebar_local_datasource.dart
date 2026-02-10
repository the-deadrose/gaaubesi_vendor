import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gaaubesi_vendor/features/sidebar/data/model/side_bar_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SidebarLocalDatasource {
  Future<List<SideBarModel>?> getCachedSidebarData();
  Future<void> cacheSidebarData(List<SideBarModel> items);
  Future<void> clearSidebarCache();
}

@Singleton(as: SidebarLocalDatasource)
class SidebarLocalDatasourceImpl implements SidebarLocalDatasource {
  static const String _cacheKey = 'sidebar_data_cache';
  final SharedPreferences _sharedPreferences;

  SidebarLocalDatasourceImpl(this._sharedPreferences);

  @override
  Future<List<SideBarModel>?> getCachedSidebarData() async {
    try {
      final cachedData = _sharedPreferences.getString(_cacheKey);
      if (cachedData == null) return null;

      final jsonList = jsonDecode(cachedData) as List;
      return _parseSubItems(jsonList)
          .map((item) => SideBarModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Error retrieving cached sidebar data: $e');
      return null;
    }
  }

  @override
  Future<void> cacheSidebarData(List<SideBarModel> items) async {
    try {
      final jsonList = items.map((item) => _convertToJson(item)).toList();
      final jsonString = jsonEncode(jsonList);
      await _sharedPreferences.setString(_cacheKey, jsonString);
    } catch (e) {
      if (kDebugMode) debugPrint('Error caching sidebar data: $e');
    }
  }

  @override
  Future<void> clearSidebarCache() async {
    try {
      await _sharedPreferences.remove(_cacheKey);
    } catch (e) {
      if (kDebugMode) debugPrint('Error clearing sidebar cache: $e');
    }
  }

  /// Helper method to convert SideBarModel to JSON with recursive subItems handling
  Map<String, dynamic> _convertToJson(SideBarModel item) {
    final json = item.toJson();
    
    // Handle subItems recursively
    if (item.subItems != null && item.subItems!.isNotEmpty) {
      json['sub_items'] = (item.subItems as List<SideBarModel>)
          .map((subItem) => _convertToJson(subItem))
          .toList();
    }
    
    return json;
  }

  /// Helper method to parse and ensure subItems are in the correct format
  List<dynamic> _parseSubItems(List<dynamic> items) {
    return items.map((item) {
      if (item is Map<String, dynamic> && item['sub_items'] != null) {
        item['sub_items'] = _parseSubItems(item['sub_items'] as List<dynamic>);
      }
      return item;
    }).toList();
  }
}
