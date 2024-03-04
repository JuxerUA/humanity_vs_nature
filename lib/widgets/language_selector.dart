import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/utils/styles.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButton<String>(
        style: Styles.white20,
        icon: const Icon(Icons.chevron_right, color: Colors.white),
        alignment: Alignment.center,
        underline: const SizedBox(),
        dropdownColor: Colors.black,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        value: selectedLanguage,
        onChanged: (value) => setState(() => selectedLanguage = value!),
        items: <String>[
          'English',
          'Українська',
        ]
            .map<DropdownMenuItem<String>>(
              (value) => DropdownMenuItem<String>(
                value: value,
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(value),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
