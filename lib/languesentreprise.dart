import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/providers/locale_provider.dart';
import 'package:tranoo/utils/locale_helper.dart';

class LanguesEntreprise extends StatefulWidget {
  const LanguesEntreprise({super.key});

  @override
  State<LanguesEntreprise> createState() => _LanguesState();
}

class _LanguesState extends State<LanguesEntreprise> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage =
        context.read<LocaleProvider>().languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.language,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: const Color(0xffF8BF13),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * (isPortrait ? 0.05 : 0.1),
          vertical: screenHeight * (isPortrait ? 0.03 : 0.1),
        ),
        child: Column(
          children: [
            for (final code in LocaleHelper.supportedLanguageCodes) ...[
              _buildLanguageTile(
                context: context,
                code: code,
                label: LocaleHelper.languageLabel(code, l10n),
                emoji: LocaleHelper.flagEmoji(code),
                screenWidth: screenWidth,
                isPortrait: isPortrait,
              ),
              if (code != LocaleHelper.supportedLanguageCodes.last)
                SizedBox(height: screenHeight * (isPortrait ? 0.02 : 0.06)),
            ],
            SizedBox(height: screenHeight * (isPortrait ? 0.15 : 0.15)),
            SizedBox(
              width: screenWidth * (isPortrait ? 0.9 : 0.8),
              height: screenHeight * (isPortrait ? 0.06 : 0.2),
              child: ElevatedButton(
                onPressed: () async {
                  final provider =
                      Provider.of<LocaleProvider>(context, listen: false);
                  await provider.setLocale(Locale(_selectedLanguage));
                  if (context.mounted) Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color(0xFFF8BF13),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  elevation: WidgetStateProperty.all(3),
                ),
                child: Text(
                  l10n.validate,
                  style: TextStyle(
                    fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required String code,
    required String label,
    required String emoji,
    required double screenWidth,
    required bool isPortrait,
  }) {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            title: Text(label),
            value: code,
            activeColor: const Color(0xff072858),
            groupValue: _selectedLanguage,
            onChanged: (value) {
              setState(() => _selectedLanguage = value!);
            },
          ),
        ),
        CircleAvatar(
          radius: screenWidth * (isPortrait ? 0.06 : 0.04),
          backgroundColor: const Color(0xFFF5F5F5),
          child: Text(
            emoji,
            style: TextStyle(fontSize: screenWidth * (isPortrait ? 0.06 : 0.04)),
          ),
        ),
      ],
    );
  }
}
