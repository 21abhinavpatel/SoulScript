import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 5.0,
        ),
      ),
    );
  }
}