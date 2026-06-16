import 'package:flutter/material.dart';

enum FieldType { text, date, dropdown, file, checkbox }

class FormFieldConfig {
  final String key;
  final String label;
  final String? hint;
  final FieldType type;
  final bool required;
  final List<String>? options; // pour dropdown
  final IconData? icon;

  FormFieldConfig({
    required this.key,
    required this.label,
    this.hint,
    required this.type,
    this.required = true,
    this.options,
    this.icon,
  });
}