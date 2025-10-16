// core/error/validation_errors.dart
class ValidationErrors {
  static const String emailRequired = 'Заполните email';
  static const String emailInvalid = 'Некорректный формат email';
  static const String emailTooLong = 'Email слишком длинный';
  static const String emailTaken = 'Email уже используется';

  static const String userNameRequired = 'Заполните имя пользователя';

  static const String passwordRequired = 'Заполните пароль';
  static const String passwordConfirm = 'Пароли не совпадают';
  static const String weakPassword = 'Пароль слишком слабый';
  static const String passwordTooShort =
      'Пароль должен содержать минимум 8 символов';
  static const String passwordNoUpperCase =
      'Пароль должен содержать заглавные буквы';
  static const String passwordNoLowerCase =
      'Пароль должен содержать строчные буквы';
  static const String passwordNoDigits = 'Пароль должен содержать цифры';
  static const String passwordNoSpecial =
      'Пароль должен содержать специальные символы';

  static const String firstNameRequired = 'Имя обязательно';
  static const String lastNameRequired = 'Фамилия обязательна';
}
