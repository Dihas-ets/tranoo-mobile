import 'package:flutter/material.dart';
import 'package:tranoo/data/screens/create_sell.dart';

class Vendre extends StatefulWidget {
  const Vendre({super.key});

  @override
  State<Vendre> createState() => _VendreState();
}

class _VendreState extends State<Vendre> {
  @override
  Widget build(BuildContext context) {
    return CreateSellPage();
  }
}
