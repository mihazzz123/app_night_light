// core/utils/name_validator.dart
import '../error/validation_errors.dart';

class NameValidator {
  static final RegExp _nameRegex = RegExp(r'^[a-zA-Zа-яА-ЯёЁ\s\-]+$');

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
  static String normalize(String name) {
    return name.trim();
  }
}
