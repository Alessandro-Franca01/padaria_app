import 'package:flutter/material.dart';
import 'api_client.dart';

class LoyaltyService with ChangeNotifier {
  int _points = 0;
  List<Map<String, dynamic>> _benefits = [];
  bool _isLoading = false;

  int get points => _points;
  List<Map<String, dynamic>> get benefits => _benefits;
  bool get isLoading => _isLoading;

  Future<void> fetchStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/loyalty');
      _points = data['points'];
      _benefits = List<Map<String, dynamic>>.from(data['benefits']);
    } catch (e) {
      // mantém o estado anterior em caso de falha
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> redeem(String benefitCode) async {
    try {
      final data = await ApiClient.post('/loyalty/redeem', body: {'benefit': benefitCode});
      _points = data['points'];
      _benefits = List<Map<String, dynamic>>.from(data['benefits']);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
