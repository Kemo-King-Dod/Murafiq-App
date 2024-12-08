// import "dart:async";

// import "package:get/get.dart";
// import "package:murafiq/main.dart";
// import "package:murafiq/core/utils/systemVarible.dart";
// import "package:murafiq/core/constant/Constatnt.dart";
// import "package:socket_io_client/socket_io_client.dart" as IO;

// class SocketService {
//   static final SocketService _instance = SocketService._internal();
//   IO.Socket? socket;
//   SocketService._internal();

//   factory SocketService() {
//     return _instance;
//   }
//    bool isReconnecting = false;
//      Timer? reconnectTimer;
//   connectAndListen() {
//     final token = shared!.getString("token");
//     if (socket == null) {
//       print("______________________________________");
//       DriverhomepageController driverController = Get.find();

     


//       socket = IO.io(
//         '${serverConstant.serverUrl}',
//         IO.OptionBuilder()
//             .setTransports(["websocket"]) // تأكد من أنك تستخدم WebSocket فقط
//             .setExtraHeaders({"Authorization": token!}) // إرسال الـ token
//             .enableReconnection() // تمكين إعادة الاتصال التلقائي
//             .setReconnectionAttempts(5) // عدد المحاولات لإعادة الاتصال
//             .setReconnectionDelay(1000) // تأخير بين المحاولات (بالملي ثانية)
//             .setTimeout(5000)
//             .setReconnectionDelayMax(10000) // Timeout للإتصال (بالملي ثانية)
//             .build(),
//       );

//       socket!.onConnect((_) => {
//             print("السيرفر متصل"),
//           });
//       socket!.on("connect", (_) {
//         print("connected");
//         driverController.socketState.value = true;
//            reconnectTimer?.cancel();
//            isReconnecting = false;
        
//       });

  

//       socket!.on('reconnect', (_) {
//         print('Reconnected to server');
//       });
//       socket!.on('reconnecting', (_) {
//         print('Reconnecting to server');
//       });

//       socket!.on('connect_error', (error) {
//         print('Connection Error: $error');
//           if (driverController.isDriverActive.value) {
//       startReconnect();
//     }
//       });
  
//       socket!.on("addJourney",
//           (journey) => {systemControllers.driverController.isThereJourney()});

//       socket!.on(
//           'disconnect',
//           (_) => {
//                 print("disconnect from Socket"),
//                 driverController.socketState.value = false,
//                     if (driverController.isDriverActive.value) {
//       startReconnect()
//     }
//               });
              
//     }
    
//   }

//   // إعادة المحاولة
//   void startReconnect() {
//     if (isReconnecting) return;
//     isReconnecting = true;

//     reconnectTimer = Timer.periodic(Duration(seconds: 5), (_) {
//       print('محاولة إعادة الاتصال...');
//       socket!.connect();
//     });
//   }

//   void compliteJourney(id) {
//     print("inSocket Service");

//     if (socket != null) {
//       socket!.emit('complite-journey-in-server', (id));
//     }
//   }

//   void whatHappenToJourney(journeyId) {
//     if (socket != null) {
//       socket!.emit('what-happen-to-journey-in-server', journeyId);
//     }
//   }


//   void dispose() {
//     if (socket != null) {
//       print("driver is offline");
//       socket!.disconnect();
//       socket = null;
//     }
//   }
// }
