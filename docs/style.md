## 🔹 Пример 1: Базовая структура AuthScreen

```dart
class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Верхняя панель с заголовком
      appBar: AppBar(
        title: Text('Авторизация'),
        centerTitle: true,
      ),

      // Основное тело с градиентным фоном
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0), // Внутренние отступы
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Центрирование по вертикали
              crossAxisAlignment: CrossAxisAlignment.stretch, // Растягивание по ширине
              children: [
                AuthButton(label: 'Войти', onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                }),
                SizedBox(height: 16), // Отступ между кнопками
                AuthButton(label: 'Регистрация', onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen()));
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 🔹 Пример 2: Переиспользуемый виджет AuthButton

```dart
class AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AuthButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo, // Цвет фона
        foregroundColor: Colors.white,  // Цвет текста
        padding: EdgeInsets.symmetric(vertical: 14), // Высота кнопки
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Скругление углов
        ),
      ),
      onPressed: onPressed,
      child: Text(label, style: TextStyle(fontSize: 18)),
    );
  }
}
```

---

## 🔹 Пример 3: Подключение темы в MaterialApp

```dart
MaterialApp(
  theme: ThemeData(
    primarySwatch: Colors.indigo,
    scaffoldBackgroundColor: Colors.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(fontSize: 16),
      titleLarge: TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  home: AuthScreen(),
)
```

---

## 🔹 Пример 4: Адаптация под экран

```dart
double screenWidth = MediaQuery.of(context).size.width;
bool isSmallScreen = screenWidth < 400;

return Padding(
  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 32),
  child: Column(...),
);
```