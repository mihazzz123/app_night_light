class Home {
  final String id;
  final String name;

  const Home({required this.id, required this.name});
}

class Room {
  final String id;
  final String name;

  const Room({required this.id, required this.name});
}

class Device {
  final String id;
  final String name;
  final bool isOnline;
  final bool isLocalOnline;
  final String room;

  Device(
      {required this.id,
      required this.name,
      required this.isOnline,
      required this.isLocalOnline,
      required this.room});
}

class MainState {
  final List<Home> homes;
  final Home? selectedHome;
  final List<Room> rooms;
  final List<Device> devices;
  final bool isLoading;

  const MainState({
    required this.homes,
    required this.selectedHome,
    required this.rooms,
    required this.devices,
    this.isLoading = false,
  });

  MainState copyWith({
    List<Home>? homes,
    Home? selectedHome,
    List<Room>? rooms,
    List<Device>? devices,
    bool? isLoading,
  }) {
    return MainState(
      homes: homes ?? this.homes,
      selectedHome: selectedHome ?? this.selectedHome,
      rooms: rooms ?? this.rooms,
      devices: devices ?? this.devices,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
