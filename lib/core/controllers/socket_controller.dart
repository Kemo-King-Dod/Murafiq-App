import 'package:get/get.dart';
import 'package:murafiq/core/functions/socket_services.dart';

class SocketController extends GetxController {
  final socket = SocketService();
  
  @override
  void onInit() {
    super.onInit();
  }

  Future<void> initializeSocket() async {
    await socket.connectAndListen();
  }

  void updateUser(String function, {Map<String, dynamic>? data}) {
    socket.updateUser(function, data: data);
  }

  void updateDriver(String function) {
    socket.updateDriver( );
  }

  @override
  void onClose() {
    socket.dispose();
    super.onClose();
  }
}
