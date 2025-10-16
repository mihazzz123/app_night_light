// core/utils/email_validator.dart
import '../error/validation_errors.dart';

class EmailValidator {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Валидирует email (аналогично Go реализации)
  static String? validate(String? value) {
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
  static String normalize(String email) {
    return email.trim().toLowerCase();
  }
}
