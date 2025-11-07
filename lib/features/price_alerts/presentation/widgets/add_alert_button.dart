import 'package:flutter/material.dart';

class AddAlertButton extends StatelessWidget {
  const AddAlertButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingActionButton(
      backgroundColor: theme.colorScheme.secondary,
      onPressed: () {},
      child: const Icon(Icons.add, size: 28, color: Colors.white),
    );
  }
}
