import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static IO.Socket? socket;

  static void connect(String userId) {
    if (socket != null && socket!.connected) return;

    socket = IO.io(
      'https://questify-backend-8zi5.onrender.com', // ✅ works for Android emulator
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      print('✅ Socket connected');
      socket!.emit('register', userId); // register this user
    });

    socket!.onDisconnect((_) => print('❌ Socket disconnected'));
  }

  static void listenForNotifications(
    Function(Map<String, dynamic>) onNotification,
  ) {
    socket?.on('notification', (data) {
      final Map<String, dynamic> notification = Map<String, dynamic>.from(data);
      print('📩 Notification received: $notification');
      onNotification(notification);
    });
  }

  static void disconnect() {
    socket?.disconnect();
  }
}
