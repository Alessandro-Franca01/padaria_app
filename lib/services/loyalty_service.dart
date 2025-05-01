import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoyaltySchedule {
  final String id;
  final List<String> days;
  final TimeOfDay deliveryTime;
  final bool isActive;
  
  LoyaltySchedule({
    required this.id,
    required this.days,
    required this.deliveryTime,
    this.isActive = true,
  });
  
  factory LoyaltySchedule.fromJson(Map<String, dynamic> json) {
    final timeParts = json['deliveryTime'].split(':');
    return LoyaltySchedule(
      id: json['id'],
      days: List<String>.from(json['days']),
      deliveryTime: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      isActive: json['isActive'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'days': days,
      'deliveryTime': '${deliveryTime.hour}:${deliveryTime.minute}',
      'isActive': isActive,
    };
  }
  
  String get formattedTime {
    final hour = deliveryTime.hour.toString().padLeft(2, '0');
    final minute = deliveryTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  String get formattedDays {
    final dayNames = {
      'mon': 'Segunda',
      'tue': 'Terça',
      'wed': 'Quarta',
      'thu': 'Quinta',
      'fri': 'Sexta',
      'sat': 'Sábado',
      'sun': 'Domingo',
    };
    
    return days.map((day) => dayNames[day] ?? day).join(', ');
  }
}

class LoyaltyService with ChangeNotifier {
  List<LoyaltySchedule> _schedules = [];
  int _loyaltyPoints = 0;
  
  List<LoyaltySchedule> get schedules => [..._schedules];
  int get loyaltyPoints => _loyaltyPoints;
  
  // Pontos necessários para diferentes benefícios
  static const int pointsForFreeDelivery = 100;
  static const int pointsForFreeBread = 150;
  static const int pointsFor10PercentDiscount = 200;
  static const int pointsFor15PercentDiscount = 300;
  
  LoyaltyService() {
    _loadData();
  }
  
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Carrega pontos de fidelidade
    _loyaltyPoints = prefs.getInt('loyalty_points') ?? 0;
    
    // Carrega agendamentos
    final schedulesData = prefs.getString('loyalty_schedules');
    if (schedulesData != null) {
      final List<dynamic> decodedData = jsonDecode(schedulesData);
      _schedules = decodedData.map((item) => LoyaltySchedule.fromJson(item)).toList();
    }
    
    notifyListeners();
  }
  
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Salva pontos de fidelidade
    await prefs.setInt('loyalty_points', _loyaltyPoints);
    
    // Salva agendamentos
    final schedulesData = jsonEncode(_schedules.map((schedule) => schedule.toJson()).toList());
    await prefs.setString('loyalty_schedules', schedulesData);
  }
  
  void addPoints(int points) {
    if (points > 0) {
      _loyaltyPoints += points;
      _saveData();
      notifyListeners();
    }
  }
  
  bool usePoints(int points) {
    if (points > 0 && _loyaltyPoints >= points) {
      _loyaltyPoints -= points;
      _saveData();
      notifyListeners();
      return true;
    }
    return false;
  }
  
  Future<void> addSchedule(List<String> days, TimeOfDay deliveryTime) async {
    final newSchedule = LoyaltySchedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      days: days,
      deliveryTime: deliveryTime,
    );
    
    _schedules.add(newSchedule);
    await _saveData();
    notifyListeners();
  }
  
  Future<void> updateSchedule(String id, List<String> days, TimeOfDay deliveryTime, bool isActive) async {
    final index = _schedules.indexWhere((schedule) => schedule.id == id);
    
    if (index >= 0) {
      _schedules[index] = LoyaltySchedule(
        id: id,
        days: days,
        deliveryTime: deliveryTime,
        isActive: isActive,
      );
      
      await _saveData();
      notifyListeners();
    }
  }
  
  Future<void> toggleScheduleActive(String id) async {
    final index = _schedules.indexWhere((schedule) => schedule.id == id);
    
    if (index >= 0) {
      final schedule = _schedules[index];
      _schedules[index] = LoyaltySchedule(
        id: schedule.id,
        days: schedule.days,
        deliveryTime: schedule.deliveryTime,
        isActive: !schedule.isActive,
      );
      
      await _saveData();
      notifyListeners();
    }
  }
  
  Future<void> removeSchedule(String id) async {
    _schedules.removeWhere((schedule) => schedule.id == id);
    await _saveData();
    notifyListeners();
  }
  
  Map<String, int> getBenefits() {
    return {
      'Entrega gratuita': pointsForFreeDelivery,
      'Pão francês grátis (6 unidades)': pointsForFreeBread,
      'Desconto de 10% na compra': pointsFor10PercentDiscount,
      'Desconto de 15% na compra': pointsFor15PercentDiscount,
    };
  }
  
  List<Map<String, dynamic>> getAvailableBenefits() {
    final benefits = [
      {
        'name': 'Entrega gratuita',
        'points': pointsForFreeDelivery,
        'available': _loyaltyPoints >= pointsForFreeDelivery,
      },
      {
        'name': 'Pão francês grátis (6 unidades)',
        'points': pointsForFreeBread,
        'available': _loyaltyPoints >= pointsForFreeBread,
      },
      {
        'name': 'Desconto de 10% na compra',
        'points': pointsFor10PercentDiscount,
        'available': _loyaltyPoints >= pointsFor10PercentDiscount,
      },
      {
        'name': 'Desconto de 15% na compra',
        'points': pointsFor15PercentDiscount,
        'available': _loyaltyPoints >= pointsFor15PercentDiscount,
      },
    ];
    
    return benefits;
  }
}
