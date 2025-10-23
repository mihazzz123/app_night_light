import 'package:app_night_light/core/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/main_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final UserEntity user;

  const HomeScreen({super.key, required this.user});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int currentPageIndex = 0;
  Home? currentHome;
  bool _isLoading = true;
  List<Home> homes = [];
  List<Device> devices = [];

  // Список экранов для каждой вкладки
  late final List<Widget> _screens;

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _init();
    _screens = [];
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.person;
      case 3:
        return Icons.settings;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Добавлен WidgetRef
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: _appPanel(),
      bottomNavigationBar: _navPanel(colorScheme),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.onPrimary,
                ),
              )
            : GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  Text(
                    'Температура 22,5C ',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Влажность 55.3%',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  PreferredSizeWidget _appPanel() {
    return AppBar(
      centerTitle: false,
      title: Text(
        currentHome?.name ?? 'Выберите дом',
      ),
      actions: [
        PopupMenuButton<Home>(
          icon: const Icon(Icons.home_work),
          padding: const EdgeInsetsGeometry.all(16),
          onSelected: (Home home) {
            setState(() {
              currentHome = home;
            });
          },
          itemBuilder: (BuildContext context) => [
            for (final home in homes)
              PopupMenuItem<Home>(
                value: home,
                child: Text(home.name),
              ),
          ],
        ),
      ],
    );
  }

  Widget _navPanel(ColorScheme colorScheme) {
    return BottomAppBar(
      color: Theme.of(context).colorScheme.surface,
      shape: const CircularNotchedRectangle(),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int i = 0; i < 4; i++)
              Expanded(
                child: Center(
                  child: IconButton(
                    icon: Icon(_getIconForIndex(i)),
                    color: selectedIndex == i
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    onPressed: () {
                      setState(() {
                        selectedIndex = i;
                      });
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _init() async {
    // Проверяем mounted в начале
    if (!mounted) return;
    setState(() => _isLoading = true);
    final mainNotifier = ref.read(mainViewModelProvider.notifier);

    try {
      await mainNotifier.init();
      // После асинхронной операции проверяем mounted
      if (!mounted) return;
      final mainState = ref.read(mainViewModelProvider);
      homes = mainState.homes;
      if (homes.isNotEmpty) {
        currentHome = mainState.selectedHome ?? homes.first;
      }

      devices = mainState.devices;
    } catch (e) {
      if (mounted) {
        _showError('Ошибка: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onError,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
