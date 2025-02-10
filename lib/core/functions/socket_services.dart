import "dart:async";
import "package:get/get.dart";
import "package:murafiq/core/constant/Constatnt.dart";
import "package:murafiq/main.dart";
import "package:socket_io_client/socket_io_client.dart" as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? socket;
  final RxBool isConnected = false.obs;
  final RxBool isConnecting = false.obs;
  bool isReconnecting = false;
  Timer? reconnectTimer;

  SocketService._internal();

  factory SocketService() {
    return _instance;
  }

  Future<void> connectAndListen() async {
    final token = shared!.getString("token");

    // إذا كان السوكت موجوداً ومتصلاً، لا داعي لإعادة الاتصال
    if (socket != null && socket!.connected) {
      print("Socket already connected");
      isConnected.value = true;
      isConnecting.value = false;
      return;
    }

    // إذا كان السوكت موجوداً ولكن غير متصل، نقوم بتنظيفه
    if (socket != null) {
      print("Cleaning up existing socket connection...");
      socket!.disconnect();
      socket!.dispose();
      socket = null;
      isConnected.value = false;
      await Future.delayed(Duration(milliseconds: 500));
    }

    isConnecting.value = true;
    print("Attempting to connect to socket server...");
    final serverAddress = serverConstant.serverUrl.replaceAll('/api', '');
    print("Socket server address: $serverAddress");

    try {
      socket = IO.io(
        serverAddress,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({'Authorization': token!})
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setTimeout(10000)
            .setPath('/socket.io/')
            .disableAutoConnect()
            .enableForceNew()
            .build(),
      );

      socket!.connect();
      _setupSocketListeners();

      // انتظار حتى يتم الاتصال أو فشل الاتصال
      bool connected = await _waitForConnection();
      if (!connected) {
        print("Failed to connect to socket server after timeout");
        dispose();
      }
    } catch (e) {
      print("Error connecting to socket server: $e");
      dispose();
    } finally {
      isConnecting.value = false;
    }
  }

  Future<bool> _waitForConnection() async {
    Completer<bool> connectionCompleter = Completer();

    // تعيين مؤقت للمهلة الزمنية
    Timer timeoutTimer = Timer(Duration(seconds: 10), () {
      if (!connectionCompleter.isCompleted) {
        connectionCompleter.complete(false);
      }
    });

    // الاستماع لحدث الاتصال
    socket!.once('connect', (_) {
      if (!connectionCompleter.isCompleted) {
        timeoutTimer.cancel();
        connectionCompleter.complete(true);
      }
    });

    // الاستماع لأخطاء الاتصال
    socket!.once('connect_error', (error) {
      if (!connectionCompleter.isCompleted) {
        timeoutTimer.cancel();
        connectionCompleter.complete(false);
      }
    });

    return connectionCompleter.future;
  }

  void _setupSocketListeners() {
    socket!.onConnect((_) {
      print("Socket connected successfully");
      isConnected.value = true;
    });

    socket!.on("connect", (_) {
      print("Socket connect event received");
      reconnectTimer?.cancel();
      isReconnecting = false;
      isConnected.value = true;
    });

    socket!.on('reconnect', (_) {
      print('Socket reconnected to server');
      isConnected.value = true;
    });

    socket!.on('reconnecting', (_) {
      print('Socket attempting to reconnect...');
      isConnected.value = false;
    });

    socket!.on('connect_error', (error) {
      print('Socket connection error: $error');
      isConnected.value = false;
      startReconnect();
    });

    socket!.on('disconnect', (_) {
      print('Socket disconnected from server');
      isConnected.value = false;
    });

// ========================================================
// ===================== Driver socket =====================
// ==========================================================
    socket!.on("update-driver", (func) {
      print("Driver Socket connected successfully");
      isConnected.value = true;
    });

// ===========================================================

    // إضافة مستمعين إضافيين للتصحيح
    socket!.onError((error) => print('Socket error: $error'));
    socket!.onConnectError((error) => print('Socket connect error: $error'));
    socket!.onConnectTimeout((_) => print('Socket connection timeout'));
  }

  void startReconnect() {
    if (isReconnecting) return;
    isReconnecting = true;

    reconnectTimer = Timer.periodic(Duration(seconds: 5), (_) {
      print('محاولة إعادة الاتصال...');
      connectAndListen();
    });
  }

  void updateDriver({data}) {
    if (socket != null && socket!.connected) {
      printer.f('update-driver: $data');
      socket!.emit('update-driver', data);
    } else {
      print('Cannot emit event: Socket is not connected');
    }
  }

  void updateUser(function, {data}) {
    if (socket != null && socket!.connected) {
      printer.f('update-user: $function');
      socket!.emit('update-user', data ?? function);
    } else {
      print('Cannot emit event: Socket is not connected');
    }
  }

  void dispose() {
    if (socket != null) {
      print("Disconnecting socket...");
      socket!.disconnect();
      socket!.dispose(); // إضافة dispose() للتنظيف الكامل
      socket = null;
      isConnected.value = false;
      reconnectTimer?.cancel();
    }
  }
}
