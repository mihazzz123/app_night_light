import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/main_state.dart';

// ViewModel
class MainViewModel extends StateNotifier<MainState> {
  MainViewModel()
      : super(const MainState(
            homes: [], selectedHome: null, rooms: [], devices: []));

  Future<void> init() async {
    // Загружаем список домов из локального хранилища
    final localHomes = await _loadHomesFromLocal();
    final selected = localHomes.isNotEmpty ? localHomes.first : null;

    state = state.copyWith(homes: localHomes, selectedHome: selected);

    if (selected != null) {
      await loadDevicesForHome(selected.id);
      await loadRoomsForHome(selected.id);
    }
  }

  Future<void> loadDevicesForHome(String homeId) async {
    state = state.copyWith(isLoading: true);

    // 1. Локальные устройства
    final localDevices = await _loadDevicesFromLocal(homeId);
    state = state.copyWith(devices: localDevices);

    // 2. Обновление с сервера
    try {
      final remoteDevices = await _loadDevicesFromRemote(homeId);
      state = state.copyWith(devices: remoteDevices);
    } catch (e) {
      // логируем ошибку, но не ломаем UI
      if (kDebugMode) {
        print('Ошибка загрузки устройств: $e');
      }
    }

    state = state.copyWith(isLoading: false);
  }

  Future<void> loadRoomsForHome(String homeId) async {
    state = state.copyWith(isLoading: true);

    final localRooms = await _loadRoomsFromLocal(homeId);
    state = state.copyWith(rooms: localRooms);

    // 2. Обновление с сервера
    try {
      final remoteRooms = await _loadRoomsFromRemote(homeId);
      state = state.copyWith(rooms: remoteRooms);
    } catch (e) {
      // логируем ошибку, но не ломаем UI
      if (kDebugMode) {
        print('Ошибка загрузки комнат: $e');
      }
    }

    state = state.copyWith(isLoading: false);
  }

  void selectHome(Home home) {
    state = state.copyWith(selectedHome: home);
    loadDevicesForHome(home.id);
  }

  // Заглушки: заменить на реальные сервисы
  Future<List<Home>> _loadHomesFromLocal() async {
    return [
      const Home(id: 'home1', name: 'Квартира'),
      const Home(id: 'home2', name: 'Дача'),
    ];
  }

  Future<List<Room>> _loadRoomsFromLocal(String homeId) async {
    return [
      const Room(id: 'room', name: 'Гостиная'),
      const Room(id: 'room2', name: 'Кухня'),
    ];
  }

  Future<List<Device>> _loadDevicesFromLocal(String homeId) async {
    return [
      Device(
          id: '1',
          name: 'Thermostat',
          isOnline: true,
          isLocalOnline: true,
          room: 'room1'),
      Device(
          id: '2',
          name: 'Light',
          isOnline: false,
          isLocalOnline: true,
          room: 'room1'),
    ];
  }

  Future<List<Device>> _loadDevicesFromRemote(String homeId) async {
    await Future.delayed(const Duration(seconds: 1)); // имитация запроса
    return [
      Device(
          id: '1',
          name: 'Thermostat',
          isOnline: true,
          isLocalOnline: true,
          room: 'room1'),
      Device(
          id: '2',
          name: 'Light',
          isOnline: true,
          isLocalOnline: true,
          room: 'room1'),
      Device(
          id: '3',
          name: 'Camera',
          isOnline: false,
          isLocalOnline: true,
          room: 'room3'),
    ];
  }

  Future<List<Room>> _loadRoomsFromRemote(String homeId) async {
    await Future.delayed(const Duration(seconds: 1)); // имитация запроса
    return [
      const Room(id: 'room1', name: 'Гостиная'),
      const Room(id: 'room2', name: 'Кухня'),
      const Room(id: 'room3', name: 'Спальня'),
    ];
  }
}
