import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: ColorManager.textPrimaryLight),
      decoration: InputDecoration(
        hintText: "Search symbol or name",
        hintStyle: const TextStyle(color: ColorManager.textSecondaryLight),
        prefixIcon: const Icon(
          Icons.search,
          color: ColorManager.textSecondaryLight,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.close,
                  color: ColorManager.textSecondaryLight,
                ),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: ColorManager.cardLight,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: ColorManager.textSecondaryLight,
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: ColorManager.textSecondaryLight,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: ColorManager.primary, width: 2),
        ),
      ),
    );
  }
}
