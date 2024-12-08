import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void init() {
    socket = IO.io('http://YOUR_SOCKET_SERVER_URL:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // Connection established
    socket.onConnect((_) {
      print('Connected to socket server');
    });

    // Handle disconnection
    socket.onDisconnect((_) {
      print('Disconnected from socket server');
    });

    // Listen for user creation response
    socket.on('create_user_response', (data) {
      print('User created: $data');
    });

    // Listen for active numbers response
    socket.on('get_active_numbers_response', (data) {
      print('Active numbers: $data');
    });

    // Listen for get available numbers response
    socket.on('get_available_numbers_response', (data) {
      print('Available numbers for country: $data');
    });

    // Listen for message send response
    socket.on('send_message_response', (data) {
      print('Message sent response: $data');
    });

    // Listen for fetched messages
    socket.on('fetch_messages_response', (data) {
      print('Fetched messages: $data');
    });
  }

  void connect() {
    socket.connect();
  }

  void createUser(String email) {
    socket.emit('create_user', {'email': email});
  }

  void fetchPhoneNumbers() {
    socket.emit('fetch_phone_numbers'); // Emit an event to fetch numbers
  }

  void getActiveNumbers() {
    socket.emit('get_active_numbers');
  }

  void getAvailableNumbers(String countryCode) {
    socket.emit('get_available_numbers', countryCode);
  }

  void sendMessage(String fromUser, String toPhoneNumber, String message) {
    socket.emit('send_message', {
      'from_user': fromUser,
      'to_phone_number': toPhoneNumber,
      'message': message,
    });
  }

  void fetchMessages(String phoneNumber) {
    socket.emit('fetch_messages', {'phone_number': phoneNumber});
  }

  void disconnect() {
    socket.disconnect();
  }
}