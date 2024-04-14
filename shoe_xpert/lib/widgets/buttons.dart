
import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  const MyButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(10))
        ),
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(text,
            style: TextStyle(fontSize: 18),
            ),
          ),
      ),
    );
  }
}
