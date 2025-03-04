import 'package:flutter/material.dart';
import 'package:tramoo/data/screens/third_page.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1E1E1E),
      body: SingleChildScrollView( //pour éviter la barre rayure jaune
        child: Padding(
          padding: EdgeInsets.only(right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              Image.asset('assets/images/voiture_deuxieme_page.png'),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Découvrez votre\nvéhicule idéal en\nquelques clics',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  Expanded(child: SizedBox()),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xffF8BF13).withAlpha(50),
                          spreadRadius: 0,
                          blurRadius: 50,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ThirdPage()),
                        );
                      },
                      icon: Icon(Icons.arrow_circle_right, color: Color(0xffF8BF13), size: 60),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
