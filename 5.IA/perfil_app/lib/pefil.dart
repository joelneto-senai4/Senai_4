import 'package:flutter/material.dart';

class PerfilPage extends StatefulWidget {
  const new({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Meu Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color.fromARGB(255, 33, 37, 243),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: Color.fromARGB(255, 33, 37, 243), width: 3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(125, 0, 0, 0),
                        blurRadius: 20,
                        offset: Offset(2, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/spider.jpg',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Joel Neto',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Análise e Desenvolvimento de Sistemas',
                textAlign: TextAlign.center,
              ),
              Text('SENAI', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              Text(
                'Desenvolvedor interessado em tecnologia, '
                'programação e desenvolvimento mobile.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.phone),
                  Icon(Icons.email),
                  Icon(Icons.location_on),
                ],
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 33, 37, 243),
                  foregroundColor: Colors.white,
                ),
                child: Text('Editar Perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
