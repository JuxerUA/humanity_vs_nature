import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/generated/l10n.dart';
import 'package:humanity_vs_nature/utils/prefs.dart';
import 'package:humanity_vs_nature/utils/styles.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({
    required this.onLocaleChanged,
    super.key,
  });

  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButton<Locale>(
        style: Styles.white20,
        icon: const Icon(Icons.chevron_right, color: Colors.white),
        alignment: Alignment.center,
        underline: const SizedBox(),
        dropdownColor: Colors.black,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        value: Prefs.currentLocale,
        onChanged: _onLanguageChanged,
        items: S.delegate.supportedLocales
            .map<DropdownMenuItem<Locale>>(
              (value) => DropdownMenuItem<Locale>(
                value: value,
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    value.languageCode == 'uk' ? 'Українська' : 'English',
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _onLanguageChanged(Locale? value) async {
    final locale = value;
    if (locale != null) {
      Prefs.currentLocale = locale;
      widget.onLocaleChanged(locale);
    }
  }
}
