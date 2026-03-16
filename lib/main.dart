import 'package:flutter/material.dart';
import 'package:couturio/shared/services/service_locator.dart';
import 'ui/loading/loading_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ServiceLocator().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Couturio',
      home: const LoadingPage(),
    );
  }
}