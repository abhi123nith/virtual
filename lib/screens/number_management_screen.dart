import 'package:flutter/material.dart';
import 'package:virtual/models/number_model.dart';
import 'package:virtual/services/local_db_services.dart';

class ManageNumbersScreen extends StatefulWidget {
  const ManageNumbersScreen({super.key});

  @override
  _ManageNumbersScreenState createState() => _ManageNumbersScreenState();
}

class _ManageNumbersScreenState extends State<ManageNumbersScreen> {
  late SocketService socketService;
  List<PhoneNumber> phoneNumbers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    socketService = SocketService();
    socketService.init();
    socketService.connect();
    socketService.fetchPhoneNumbers();

    // Listen to fetch responses
    socketService.socket.on('fetch_phone_numbers_response', (data) {
      setState(() {
        isLoading = false;
        // Parse incoming data and create PhoneNumber instances
        phoneNumbers = (data as List)
            .map((numberData) => PhoneNumber.fromJson(numberData))
            .toList();
      });
    });
  }

  void deleteNumber(int index) {
    setState(() {
      phoneNumbers.removeAt(index);
    });
  }

  void viewDetails(PhoneNumber number) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Details for ${number.number}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Purchased by: ${number.purchaserName}'),
              Text('Email: ${number.purchaserEmail}'),
              Text('Purchase Date: ${number.purchaseDate.toLocal()}'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Numbers')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: phoneNumbers.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(phoneNumbers[index].number),
                    subtitle: Text('Purchased by: ${phoneNumbers[index].purchaserName}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.info),
                          onPressed: () => viewDetails(phoneNumbers[index]),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteNumber(index),
                        ),
                      ],
                    ),
                    onTap: () => viewDetails(phoneNumbers[index]),
                  ),
                );
              },
            ),
    );
  }
}