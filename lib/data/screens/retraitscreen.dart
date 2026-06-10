import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'mesretraitspage.dart';

class RetraitScreen extends StatelessWidget {
  const RetraitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.makeWithdrawal,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(
                    Colors.grey.r.toInt(),
                    Colors.grey.g.toInt(),
                    Colors.grey.b.toInt(),
                    0.2,
                  ),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  l10n.withdrawal,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(l10n.transferAccount),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildImage('assets/images/American Express.png'),
                      const SizedBox(width: 10),
                      _buildImage('assets/images/Visa.png'),
                      const SizedBox(width: 10),
                      _buildImage('assets/images/American Express.png'),
                      const SizedBox(width: 10),
                      _buildImage('assets/images/Discover.png'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextField(l10n.nameOnCard, l10n.cardPlaceholderName),
                const SizedBox(height: 35),
                _buildTextField(l10n.cardNumber, l10n.cardNumberPlaceholder),
                const SizedBox(height: 35),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(l10n.month, const ['01', '02', '03', '04']),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDropdown(
                        l10n.yearDropdown,
                        const ['2024', '2025', '2026'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                _buildTextField(
                  l10n.securityCode,
                  l10n.codeHint,
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width < 600
                        ? MediaQuery.sizeOf(context).width * 0.9
                        : 600,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0Xfff8bf13),
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.sizeOf(context).height < 600 ? 5 : 15,
                        horizontal: MediaQuery.sizeOf(context).width < 600 ? 10 : 60,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MesRetraitsPage(),
                        ),
                      );
                    },
                    child: Text(
                      l10n.requestWithdrawal,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    bool obscureText = false,
  }) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, List<String> items) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) {},
    );
  }

  Widget _buildImage(String imagePath) {
    return SizedBox(
      height: 30,
      width: 50,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      ),
    );
  }
}
