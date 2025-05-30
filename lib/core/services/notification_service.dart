import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../utils/enums.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final AuthService _authService = AuthService();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // Initialize notification service
  Future<void> initialize() async {
    try {
      // Request permission for notifications
      await _requestPermission();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      await _getFCMToken();

      // Setup message handlers
      _setupMessageHandlers();

      if (kDebugMode) {
        print('NotificationService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize NotificationService: $e');
      }
    }
  }

  // Request notification permissions
  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('Notification permission status: ${settings.authorizationStatus}');
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  // Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    const defaultChannel = AndroidNotificationChannel(
      'default_channel',
      'Default Notifications',
      description: 'General notifications from IGPL Monday',
      importance: Importance.high,
    );

    const leadChannel = AndroidNotificationChannel(
      'lead_channel',
      'Lead Notifications',
      description: 'Notifications related to leads and follow-ups',
      importance: Importance.high,
    );

    const requestChannel = AndroidNotificationChannel(
      'request_channel',
      'Request Notifications',
      description: 'Join requests and approval notifications',
      importance: Importance.max,
    );

    const renewalChannel = AndroidNotificationChannel(
      'renewal_channel',
      'Renewal Notifications',
      description: 'Account renewal and expiry notifications',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(defaultChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(leadChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(requestChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(renewalChannel);
  }

  // Get FCM token and update in Firestore
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        await _authService.updateFCMToken(_fcmToken!);
        if (kDebugMode) {
          print('FCM Token: $_fcmToken');
        }
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) async {
        _fcmToken = token;
        await _authService.updateFCMToken(token);
        if (kDebugMode) {
          print('FCM Token refreshed: $token');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get FCM token: $e');
      }
    }
  }

  // Setup message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle app launch from notification
    _handleAppLaunchFromNotification();
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('Received foreground message: ${message.messageId}');
    }

    // Show local notification when app is in foreground
    await _showLocalNotification(message);
  }

  // Handle message when app is opened from notification
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    if (kDebugMode) {
      print('App opened from notification: ${message.messageId}');
    }

    // Navigate to appropriate screen based on notification data
    _handleNotificationNavigation(message.data);
  }

  // Handle app launch from notification
  Future<void> _handleAppLaunchFromNotification() async {
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        print('App launched from notification: ${initialMessage.messageId}');
      }
      _handleNotificationNavigation(initialMessage.data);
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final notificationType = _getNotificationTypeFromData(message.data);
    final channelId = _getChannelIdForType(notificationType);

    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      channelDescription: 'General notifications from IGPL Monday',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails.copyWith(channelId: channelId),
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _handleNotificationNavigation(data);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to parse notification payload: $e');
        }
      }
    }
  }

  // Handle notification navigation
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = _getNotificationTypeFromData(data);

    switch (type) {
      case NotificationType.leadAssigned:
        final leadId = data['leadId'];
        if (leadId != null) {
          // Navigate to lead detail screen
          // This will be implemented with Go Router
        }
        break;

      case NotificationType.followupDue:
        final leadId = data['leadId'];
        if (leadId != null) {
          // Navigate to lead detail screen
        }
        break;

      case NotificationType.joinRequest:
      // Navigate to join requests screen
        break;

      case NotificationType.joinRequestApproved:
      case NotificationType.joinRequestRejected:
      // Navigate to dashboard
        break;

      case NotificationType.renewalReminder:
      case NotificationType.accountExpiry:
      // Navigate to renewal screen
        break;
    }
  }

  // Get notification type from data
  NotificationType _getNotificationTypeFromData(Map<String, dynamic> data) {
    final typeString = data['type'] as String?;
    if (typeString == null) return NotificationType.leadAssigned;

    return NotificationType.values.firstWhere(
          (type) => type.value == typeString,
      orElse: () => NotificationType.leadAssigned,
    );
  }

  // Get channel ID for notification type
  String _getChannelIdForType(NotificationType type) {
    switch (type) {
      case NotificationType.leadAssigned:
      case NotificationType.followupDue:
        return 'lead_channel';
      case NotificationType.joinRequest:
      case NotificationType.joinRequestApproved:
      case NotificationType.joinRequestRejected:
        return 'request_channel';
      case NotificationType.renewalReminder:
      case NotificationType.accountExpiry:
        return 'renewal_channel';
    }
  }

  // Schedule local notification
  Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, dynamic>? data,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      channelDescription: 'Scheduled notifications from IGPL Monday',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      notificationDetails,
      payload: data != null ? jsonEncode(data) : null,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Show immediate local notification (for testing/manual triggers)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.leadAssigned,
    Map<String, dynamic>? data,
  }) async {
    final channelId = _getChannelIdForType(type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelNameForType(type),
      channelDescription: _getChannelDescriptionForType(type),
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: data != null ? jsonEncode(data) : null,
    );
  }

  // Get channel name for type
  String _getChannelNameForType(NotificationType type) {
    switch (type) {
      case NotificationType.leadAssigned:
      case NotificationType.followupDue:
        return 'Lead Notifications';
      case NotificationType.joinRequest:
      case NotificationType.joinRequestApproved:
      case NotificationType.joinRequestRejected:
        return 'Request Notifications';
      case NotificationType.renewalReminder:
      case NotificationType.accountExpiry:
        return 'Renewal Notifications';
    }
  }

  // Get channel description for type
  String _getChannelDescriptionForType(NotificationType type) {
    switch (type) {
      case NotificationType.leadAssigned:
      case NotificationType.followupDue:
        return 'Notifications related to leads and follow-ups';
      case NotificationType.joinRequest:
      case NotificationType.joinRequestApproved:
      case NotificationType.joinRequestRejected:
        return 'Join requests and approval notifications';
      case NotificationType.renewalReminder:
      case NotificationType.accountExpiry:
        return 'Account renewal and expiry notifications';
    }
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  // Subscribe to topic (for broadcasting)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to subscribe to topic $topic: $e');
      }
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to unsubscribe from topic $topic: $e');
      }
    }
  }

  // Dispose
  void dispose() {
    // Clean up resources if needed
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Background message received: ${message.messageId}');
  }
}