import '../error/validation_errors.dart';

class Validator {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp _nameRegex = RegExp(r'^[a-zA-Zа-яА-ЯёЁ\s\-]+$');

  /// Валидирует email (аналогично Go реализации)
  static String? validateEmail(String? value) {
    // Добавляем nullable
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return ValidationErrors.emailRequired;
    }

    if (email.length > 254) {
      return ValidationErrors.emailTooLong;
    }

    if (!_emailRegex.hasMatch(email)) {
      return ValidationErrors.emailInvalid;
    }

    return null;
  }

  /// Нормализует email (приводит к нижнему регистру и обрезает пробелы)
  static String normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Валидирует имя пользователя (аналогично Go реализации)
  static String? validateUserName(String? value) {
    // Добавляем nullable
    final userName = value?.trim() ?? '';

    if (userName.isEmpty) {
      return ValidationErrors.userNameRequired;
    }

    if (userName.length < 2) {
      return 'Имя пользователя должно содержать минимум 2 символа';
    }

    if (userName.length > 50) {
      return 'Имя пользователя слишком длинное';
    }

    if (!_nameRegex.hasMatch(userName)) {
      return 'Имя пользователя может содержать только буквы, пробелы и дефисы';
    }

    return null;
  }

  /// Нормализует имя (обрезает пробелы)
  static String normalizeUserName(String name) {
    return name.trim();
  }

  static String? validatePassword(String? value, {String? confirmPassword}) {
    // Добавляем nullable
    final password = value?.trim() ?? '';

    if (password.isEmpty) {
      return ValidationErrors.passwordRequired;
    }

    if (password.length < 8) {
      return ValidationErrors.weakPassword;
    }

    // Дополнительные проверки как в Go
    if (!_hasUpperCasePassword(password)) {
      return ValidationErrors.passwordNoUpperCase;
    }

    if (!_hasLowerCasePassword(password)) {
      return ValidationErrors.passwordNoLowerCase;
    }

    if (!_hasDigitsPassword(password)) {
      return ValidationErrors.passwordNoDigits;
    }

    if (!_hasSpecialCharactersPassword(password)) {
      return ValidationErrors.passwordNoSpecial;
    }

    // Проверка подтверждения пароля
    if (confirmPassword != null && password != confirmPassword.trim()) {
      return ValidationErrors.passwordConfirm;
    }

    return null;
  }

  static bool _hasUpperCasePassword(String password) {
    return password.contains(RegExp(r'[A-Z]'));
  }

  static bool _hasLowerCasePassword(String password) {
    return password.contains(RegExp(r'[a-z]'));
  }

  static bool _hasDigitsPassword(String password) {
    return password.contains(RegExp(r'[0-9]'));
  }

  static bool _hasSpecialCharactersPassword(String password) {
    return password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }
}
