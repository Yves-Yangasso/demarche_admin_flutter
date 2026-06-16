import 'package:flutter/material.dart';

class DropdownField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final List<Map<String, dynamic>> sections;

  const DropdownField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.sections,
  }) : super(key: key);

  @override
  _DropdownFieldState createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> {
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption =
        widget.controller.text.isNotEmpty ? widget.controller.text : null;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        //contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      dropdownColor: Colors.white,
      initialValue: _selectedOption,
      items: widget.sections.map((s) {
        return DropdownMenuItem<String>(
          value: s["nameBase"],
          child: Text(
            s["nameBase"], 
            style: const TextStyle(color: Colors.black),
          ),
          
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedOption = value;
          widget.controller.text = value ?? '';
          print('Selected option: ');
          print(_selectedOption);
          print(value);
          print(widget.controller.text);
        });
      },
      validator: (value) => value == null || value.isEmpty
          ? "Veuillez sélectionner ${widget.labelText.toLowerCase()}"
          : null,
    );
  }
}
