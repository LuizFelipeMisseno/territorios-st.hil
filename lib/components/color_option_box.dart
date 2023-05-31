import 'package:flutter/material.dart';
import 'package:territorio/controllers/quadras.controller.dart';

class ColorOptionBox extends StatelessWidget {
  final Color color;
  const ColorOptionBox({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    bool isSelected = colorSelected.value == color.value;
    return InkWell(
      onTap: () => colorSelected.value = color.value,
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          border: Border.all(
            width: isSelected ? 5 : 0,
            color: Colors.black,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isSelected ? 3.0 : 0),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: color,
          ),
        ),
      ),
    );
  }
}
