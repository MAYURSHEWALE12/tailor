import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopProvider with ChangeNotifier {
  String _shopName = '';
  String _ownerName = '';
  String _phone = '';
  String _address = '';
  String _gstin = '';
  String _logoPath = '';
  String _terms = '';

  String get shopName => _shopName;
  String get ownerName => _ownerName;
  String get phone => _phone;
  String get address => _address;
  String get gstin => _gstin;
  String get logoPath => _logoPath;
  String get terms => _terms;

  ShopProvider() {
    _loadShopInfo();
  }

  void _loadShopInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _shopName = prefs.getString('shop_name') ?? '';
    _ownerName = prefs.getString('owner_name') ?? '';
    _phone = prefs.getString('shop_phone') ?? '';
    _address = prefs.getString('shop_address') ?? '';
    _gstin = prefs.getString('shop_gstin') ?? '';
    _logoPath = prefs.getString('shop_logo_path') ?? '';
    _terms = prefs.getString('shop_terms') ?? '';
    notifyListeners();
  }

  Future<void> updateShopInfo({
    required String shopName,
    required String ownerName,
    required String phone,
    required String address,
    required String gstin,
    required String logoPath,
    required String terms,
  }) async {
    _shopName = shopName;
    _ownerName = ownerName;
    _phone = phone;
    _address = address;
    _gstin = gstin;
    _logoPath = logoPath;
    _terms = terms;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shop_name', shopName);
    await prefs.setString('owner_name', ownerName);
    await prefs.setString('shop_phone', phone);
    await prefs.setString('shop_address', address);
    await prefs.setString('shop_gstin', gstin);
    await prefs.setString('shop_logo_path', logoPath);
    await prefs.setString('shop_terms', terms);

    notifyListeners();
  }
}
