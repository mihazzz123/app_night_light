// core/utils/password_validator.dart
import '../error/validation_errors.dart';

class PasswordValidator {
  /// Валидирует пароль (аналогично Go реализации)
  static String? validate(String? value, {String? confirmPassword}) {
    // Добавляем nullable
    final password = value?.trim() ?? '';

    if (password.isEmpty) {
      return ValidationErrors.passwordRequired;
    }

    if (password.length < 8) {
      return ValidationErrors.weakPassword;
    }

    // Дополнительные проверки как в Go
    if (!_hasUpperCase(password)) {
      return ValidationErrors.passwordNoUpperCase;
    }

    if (!_hasLowerCase(password)) {
      return ValidationErrors.passwordNoLowerCase;
    }

    if (!_hasDigits(password)) {
      return ValidationErrors.passwordNoDigits;
    }

    if (!_hasSpecialCharacters(password)) {
      return ValidationErrors.passwordNoSpecial;
    }

    // Проверка подтверждения пароля
    if (confirmPassword != null && password != confirmPassword.trim()) {
      return ValidationErrors.passwordConfirm;
    }

    return null;
  }

  static bool _hasUpperCase(String password) {
    return password.contains(RegExp(r'[A-Z]'));
  }

  static bool _hasLowerCase(String password) {
    return password.contains(RegExp(r'[a-z]'));
  }

  static bool _hasDigits(String password) {
    return password.contains(RegExp(r'[0-9]'));
  }

  static bool _hasSpecialCharacters(String password) {
    return password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }
}
