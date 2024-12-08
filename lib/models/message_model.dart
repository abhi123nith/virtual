class Message {
  final String from;
  final String to;
  final String body;
  final String status;
  final DateTime dateSent;

  Message({
    required this.from,
    required this.to,
    required this.body,
    required this.status,
    required this.dateSent,
  });
}