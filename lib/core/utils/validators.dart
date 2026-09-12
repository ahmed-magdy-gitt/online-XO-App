import '../constants/app_strings.dart';

abstract final class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.invalidEmail;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) {
      return AppStrings.invalidPassword;
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value != password) {
      return AppStrings.passwordMismatch;
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.nameRequired;
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters.';
    }
    return null;
  }

  static String? required(String? value, {String message = 'This field is required.'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }
}
