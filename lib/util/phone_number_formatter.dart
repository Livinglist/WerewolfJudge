import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    print("old: " + oldValue.text);
    print("new: " + newValue.text);

    String text = newValue.text;

    if (newValue.text.length > oldValue.text.length) {
      if ((newValue.text.length == 8 && newValue.text[7] != '-')) {
        TextEditingValue textEditingValue = TextEditingValue(
            text: text.substring(0, 7) + '-' + text[7],
            selection: TextSelection.fromPosition(TextPosition(offset: text.isEmpty ? -1 : text.length + 1)));

        return textEditingValue;
      }

      if ((newValue.text.length == 4 && newValue.text[3] != '-')) {
        TextEditingValue textEditingValue = TextEditingValue(
            text: text.substring(0, 3) + '-' + text[3],
            selection: TextSelection.fromPosition(TextPosition(offset: text.isEmpty ? -1 : text.length + 1)));

        return textEditingValue;
      }

      if (newValue.text.length == 3 || newValue.text.length == 7) {
        TextEditingValue textEditingValue =
            TextEditingValue(text: text + '-', selection: TextSelection.fromPosition(TextPosition(offset: text.isEmpty ? -1 : text.length + 1)));

        return textEditingValue;
      }
    }

    return newValue;
  }
}
