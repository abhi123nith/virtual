class PhoneNumber {
  final String number;
  final String purchaserName;
  final String purchaserEmail;
  final DateTime purchaseDate;

  PhoneNumber({
    required this.number,
    required this.purchaserName,
    required this.purchaserEmail,
    required this.purchaseDate,
  });

  factory PhoneNumber.fromJson(Map<String, dynamic> json) {
    return PhoneNumber(
      number: json['number'],
      purchaserName: json['purchaserName'],
      purchaserEmail: json['purchaserEmail'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
    );
  }
}
