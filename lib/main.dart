// lib/main.dart
import 'package:flutter/material.dart';
import 'app.dart';
import 'services/api_service.dart';

export 'app.dart' show MyApp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await ApiService.init();
  
  runApp(const MyApp());
}
