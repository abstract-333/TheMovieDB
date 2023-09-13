import 'package:flutter/material.dart';
import 'package:themoviedb/ui/theme/app_colors.dart';

abstract class AppButtonStyle {
  static final ButtonStyle linkButton = ButtonStyle(
      foregroundColor: MaterialStateProperty.all(AppColors.mainLightBlue),
      textStyle: MaterialStateProperty.all(const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      )));
}
