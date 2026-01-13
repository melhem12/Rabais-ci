import 'package:flutter/material.dart';

/// Manages a single key/value entry for additional profile information.
class AdditionalInfoFieldController {
  AdditionalInfoFieldController({
    String? key,
    String? value,
  })  : keyController = TextEditingController(text: key ?? ''),
        valueController = TextEditingController(text: value ?? '');

  final TextEditingController keyController;
  final TextEditingController valueController;

  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }
}


