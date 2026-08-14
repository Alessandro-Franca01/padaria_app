import 'package:flutter/material.dart';
import '../models/loyalty_benefit.dart';
import '../models/loyalty_transaction.dart';
import 'api_client.dart';

class LoyaltyService with ChangeNotifier {
  int _points = 0;
  List<LoyaltyBenefit> _benefits = [];
  List<LoyaltyTransaction> _transactions = [];
  bool _isLoading = false;
  String? _selectedBenefitId;

  int get points => _points;
  List<LoyaltyBenefit> get benefits => _benefits;
  List<LoyaltyTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get selectedBenefitId => _selectedBenefitId;

  LoyaltyBenefit? get selectedBenefit {
    if (_selectedBenefitId == null) return null;
    for (final benefit in _benefits) {
      if (benefit.id == _selectedBenefitId) return benefit;
    }
    return null;
  }

  Future<void> fetchStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/loyalty');
      _points = data['points'];
      _benefits = (data['benefits'] as List).map((json) => LoyaltyBenefit.fromJson(json)).toList();
      if (_selectedBenefitId != null && selectedBenefit == null) {
        _selectedBenefitId = null;
      }
    } catch (e) {
      // mantém o estado anterior em caso de falha
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTransactions() async {
    try {
      final data = await ApiClient.get('/loyalty/transactions') as List;
      _transactions = data.map((json) => LoyaltyTransaction.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      // mantém o estado anterior em caso de falha
    }
  }

  void selectBenefit(String? benefitId) {
    _selectedBenefitId = benefitId;
    notifyListeners();
  }

  void clearSelection() {
    _selectedBenefitId = null;
    notifyListeners();
  }
}
