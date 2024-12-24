import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  print("Handling a background message: ${message.messageId}");
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  // Initialize notification services
  Future<void> init() async {
    // Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permissions');
    } else {
      print('User declined or has not accepted notification permissions');
      return;
    }

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle tap on notification
        _handleNotificationTap(details);
      },
    );

    // Configure foreground message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received foreground message");
      _showLocalNotification(message);
    });

    // Configure background message tap handling
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message opened app");
      _handleMessageTap(message);
    });
  }

  // Method to save FCM token to SharedPreferences
  Future<void> saveFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
    print('FCM Token saved: $token');
  }

  // Method to get FCM token from SharedPreferences
  Future<String?> getSavedFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  // Get and save FCM token
  Future<String?> getAndSaveFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await saveFCMToken(token);
      }
     
      return token;
    } catch (e) {
      print("Error getting FCM token: $e");
      return null;
    }
  }

  // Get FCM token
  Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print("Firebase Messaging Token: $token");
      return token;
    } catch (e) {
      print("Error getting FCM token: $e");
      return null;
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    // Android notification details
    const AndroidNotificationDetails androidPlatformChannelSpecifics = 
        AndroidNotificationDetails(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.max,
      priority: Priority.high,
    );

    // Notification details
    const NotificationDetails platformChannelSpecifics = 
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Show the notification
    await _flutterLocalNotificationsPlugin.show(
      message.hashCode, // Unique ID for each notification
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data['payload'],
    );
  }

  // Handle notification tap
  void _handleNotificationTap(NotificationResponse details) {
    // Navigate or perform action based on notification payload
    print("Notification tapped with payload: ${details.payload}");
    // Example: Navigate to a specific screen
    // Get.toNamed('/specific-screen', arguments: details.payload);
  }

  // Handle message tap when app is in background
  void _handleMessageTap(RemoteMessage message) {
    print("Message tapped when app was in background");
    // Navigate or perform action based on message data
    // Example: Navigate to a specific screen
    // Get.toNamed('/specific-screen', arguments: message.data);
  }

  // Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print("Subscribed to topic: $topic");
    } catch (e) {
      print("Error subscribing to topic: $e");
    }
  }

  // Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print("Unsubscribed from topic: $topic");
    } catch (e) {
      print("Error unsubscribing from topic: $e");
    }
  }
}
