import 'package:flutter/material.dart';

import 'view/inicio_page.dart';

void main() {
  runApp(const BuscaPet());
}

class BuscaPet extends StatelessWidget {
  const BuscaPet({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'BuscaPet',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF20A39E),
        ),

        fontFamily: 'Arial',
      ),

      home: const InicioPage(),
    );
  }
}