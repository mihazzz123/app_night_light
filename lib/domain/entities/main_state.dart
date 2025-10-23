class Home {
  final String id;
  final String name;

  const Home({required this.id, required this.name});
}

class Device {
  final String id;
  final String name;
  final bool isOnline;

  Device({required this.id, required this.name, required this.isOnline});
}

class MainState {
  final List<Home> homes;
  final Home? selectedHome;
  final List<Device> devices;
  final bool isLoading;

  const MainState({
    required this.homes,
    required this.selectedHome,
    required this.devices,
    this.isLoading = false,
  });

  MainState copyWith({
    List<Home>? homes,
    Home? selectedHome,
    List<Device>? devices,
    bool? isLoading,
  }) {
    return MainState(
      homes: homes ?? this.homes,
      selectedHome: selectedHome ?? this.selectedHome,
      devices: devices ?? this.devices,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
