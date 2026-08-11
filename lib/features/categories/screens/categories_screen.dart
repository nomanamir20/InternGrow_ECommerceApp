import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  final String? initialCategory;

  const CategoriesScreen({super.key, this.initialCategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Categories Screen — TODO (initial: $initialCategory)'),
      ),
    );
  }
}