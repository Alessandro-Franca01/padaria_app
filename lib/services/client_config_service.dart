import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClientConfigService {
  static final ClientConfigService _instance = ClientConfigService._internal();
  factory ClientConfigService() => _instance;
  ClientConfigService._internal();

  Map<String, dynamic>? _config;
  bool _loaded = false;

  Future<void> loadConfig() async {
    if (_loaded) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/config/client_config.json');
      _config = json.decode(jsonString) as Map<String, dynamic>;
      _loaded = true;
    } catch (e) {
      // Fallback para valores padrão se o arquivo não existir
      _config = {
        'app_name': 'Padaria App',
        'package_name': 'com.example.padaria_app',
        'colors': {
          'primary': '#8B4513',
          'primary_dark': '#5D2F0E',
          'accent': '#FF9800',
          'secondary': '#FFA726',
        },
        'strings': {
          'app_name': 'Padaria App',
          'splash_text': 'Seu pão fresquinho na palma da mão',
          'home_welcome': 'Bem-vindo!',
        },
      };
      _loaded = true;
    }
  }

  String get appName => _config?['app_name'] ?? 'Padaria App';
  String get packageName => _config?['package_name'] ?? 'com.example.padaria_app';

  // Cores
  Color get primaryColor => _hexToColor(_config?['colors']?['primary'] ?? '#8B4513');
  Color get primaryDarkColor => _hexToColor(_config?['colors']?['primary_dark'] ?? '#5D2F0E');
  Color get accentColor => _hexToColor(_config?['colors']?['accent'] ?? '#FF9800');
  Color get secondaryColor => _hexToColor(_config?['colors']?['secondary'] ?? '#FFA726');

  // Strings
  String get splashText => _config?['strings']?['splash_text'] ?? 'Seu pão fresquinho na palma da mão';
  String get homeWelcome => _config?['strings']?['home_welcome'] ?? 'Bem-vindo!';

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  bool get isLoaded => _loaded;
}