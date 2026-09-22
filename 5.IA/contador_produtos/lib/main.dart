import 'package:contador_produtos/produto.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ProdutoApp());
}

class ProdutoApp extends StatelessWidget {
  const ProdutoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: ProdutoPage(),
    );
  }
}
