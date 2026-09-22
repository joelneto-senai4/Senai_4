import 'package:flutter/material.dart';


class ProdutoPage extends StatefulWidget {
  const ProdutoPage({super.key});

  @override
  State<ProdutoPage> createState() => _ProdutoPageState();
}

class _ProdutoPageState extends State<ProdutoPage> {
  int quantidade = 1;

  double preco = 25.90;

  void aumentar() {
    setState(() {
      quantidade++;
    });
  }

  void diminuir() {
    if (quantidade > 1) {
      setState(() {
        quantidade--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = quantidade * preco;

    return Scaffold(
      appBar: AppBar(title: const Text('Produto')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.shopping_cart, size: 100),

            const SizedBox(height: 20),

            const Text(
              'Teclado Gamer',

              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              'R\$ ${preco.toStringAsFixed(2)}',

              style: const TextStyle(fontSize: 22),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                IconButton(onPressed: diminuir, icon: const Icon(Icons.remove)),

                Text('$quantidade', style: const TextStyle(fontSize: 25)),

                IconButton(onPressed: aumentar, icon: const Icon(Icons.add)),
              ],
            ),

            const SizedBox(height: 30),

            Text(
              'Total: R\$ ${total.toStringAsFixed(2)}',

              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
