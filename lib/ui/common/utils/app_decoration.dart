import 'package:flutter/material.dart';
import 'app_colors.dart';

InputDecoration appInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.primary,
      ),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 1.5,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 2,
      ),
    ),

    floatingLabelStyle: const TextStyle(
      color: AppColors.primaryDark,
    ),
  );
}