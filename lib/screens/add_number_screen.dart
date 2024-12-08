import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class AddNumbersScreen extends StatefulWidget {
  const AddNumbersScreen({super.key});

  @override
  _AddNumbersScreenState createState() => _AddNumbersScreenState();
}

class _AddNumbersScreenState extends State<AddNumbersScreen> {
  String? selectedCountry;
  String? selectedNumber;
  bool isPurchased = false;
  bool isLoading = false;

  final List<String> countries = [];
  final Map<String, List<String>> availableNumbers = {};

  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    _initSocket();
    _fetchCountries(); // Fetch countries on startup
  }

  void _initSocket() {
    socket = IO.io(
      'https://meta-spirit-441312-g4.ue.r.appspot.com/',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      },
    );

    socket!.connect();

    socket!.onConnect((_) {
      print('Socket connected.');
    });

    socket!.onDisconnect((_) => print('Socket disconnected.'));

    // Listen for available numbers
    socket!.on('get_available_numbers', (data) {
      try {
        setState(() {
          availableNumbers[selectedCountry!] = List<String>.from(data);
          isLoading = false; // Stop loading once data is received
          print(
              'Available numbers received for $selectedCountry: $data'); // Log received numbers
        });
      } catch (e) {
        print('Error processing available numbers: $e');
        setState(() {
          isLoading = false; // Stop loading on error
        });
      }
    });

    // Listen for countries
    socket!.on('get_countries', (data) {
      try {
        setState(() {
          countries.clear();
          countries.addAll(List<String>.from(data));
          isLoading = false; // Stop loading once data is received
          print('Countries received: $data'); // Log received countries
        });
      } catch (e) {
        print('Error processing countries: $e');
        setState(() {
          isLoading = false; // Stop loading on error
        });
      }
    });

    // Optional: Adding an error listener
    socket!.on('error', (data) {
      setState(() {
        isLoading = false; // Stop loading on error
      });
      print('Error event: $data');
    });
  }

  void _fetchCountries() {
    setState(() {
      isLoading = true; // Start loading before the request
    });
    try {
      socket!.emit('get_countries');
    } catch (e) {
      print('Error emitting get_countries: $e');
      setState(() {
        isLoading = false; // Stop loading on error
      });
    }
  }

  void _fetchAvailableNumbers() {
    if (selectedCountry != null) {
      setState(() {
        availableNumbers[selectedCountry!] = []; // Clear previous numbers
        isLoading = true; // Start loading for available numbers
      });
      try {
        socket!.emit('get_available_numbers', selectedCountry);
        print(
            'Requested available numbers for: $selectedCountry'); // Log request for available numbers
      } catch (e) {
        print('Error emitting get_available_numbers: $e');
        setState(() {
          isLoading = false; // Stop loading on error
        });
      }
    }
  }

  void purchaseNumber() {
    if (selectedNumber != null) {
      setState(() {
        isPurchased = true;
      });
      try {
        socket!.emit('buy_number', {
          "user_id": "1",
          'country': selectedCountry,
          'phone_number': selectedNumber,
        });
        print(
            'Attempting to purchase: $selectedNumber'); // Log purchase attempt
      } catch (e) {
        print('Error emitting buy_number: $e');
        setState(() {
          isPurchased = false; // Reset purchased state on error
        });
      }
    } else {
      print('No number selected for purchase.'); // Log if no number is selected
    }
  }

  @override
  void dispose() {
    socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Numbers'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const CircularProgressIndicator()
              : Column(
                  children: [
                    DropdownButton<String>(
                      hint: const Text('Select Country'),
                      value: selectedCountry,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCountry = newValue;
                          selectedNumber = null; // Reset the selected number
                        });
                        _fetchAvailableNumbers(); // Fetch available numbers for this country
                      },
                      items: countries
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    DropdownButton<String>(
                      hint: const Text('Select Available Number'),
                      value: selectedNumber,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedNumber = newValue;
                        });
                      },
                      items: selectedCountry != null &&
                              availableNumbers[selectedCountry] != null
                          ? availableNumbers[selectedCountry]!
                              .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList()
                          : [],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: purchaseNumber,
                      child: const Text('Purchase'),
                    ),
                    const SizedBox(height: 20),
                    if (isPurchased)
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        color: Colors.green,
                        child: const Text(
                          'Number has been purchased!',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
