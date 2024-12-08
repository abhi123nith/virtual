import 'package:flutter/material.dart';

class AddNumbersScreen extends StatefulWidget {
  const AddNumbersScreen({super.key});

  @override
  _AddNumbersScreenState createState() => _AddNumbersScreenState();
}

class _AddNumbersScreenState extends State<AddNumbersScreen> {
  String? selectedCountry;
  String? selectedNumber;
  bool isPurchased = false;

  final List<String> countries = ['USA', 'Canada', 'UK'];
  final Map<String, List<String>> availableNumbers = {
    'USA': ['+1-234-567-8901', '+1-321-654-0987'],
    'Canada': ['+1-123-456-7890', '+1-987-654-3210'],
    'UK': ['+44-123-456-7890', '+44-098-765-4321'],
  };

  void purchaseNumber() {
    if (selectedNumber != null) {
      setState(() {
        isPurchased = true;
      });
    }
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
          child: Column(
            children: [
              // Dropdown for selecting country
              DropdownButton<String>(
                hint: const Text('Select Country'),
                value: selectedCountry,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCountry = newValue;
                    selectedNumber = null; // Reset selected number when country changes
                  });
                },
                items: countries.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
        
              const SizedBox(height: 20),
        
              // Dropdown for selecting available numbers
              DropdownButton<String>(
                hint: const Text('Select Available Number'),
                value: selectedNumber,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedNumber = newValue;
                  });
                },
                items: selectedCountry != null
                    ? availableNumbers[selectedCountry]!.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList()
                    : [],
              ),
        
              const SizedBox(height: 20),
        
              // Purchase button
              ElevatedButton(
                onPressed: purchaseNumber,
                child: const Text('Purchase'),
              ),
        
              const SizedBox(height: 20),
        
              // Message box showing that the number has been purchased
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