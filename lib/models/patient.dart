class Patient {
  int get installmentMonths => totalMonths;
  final int? id;
  final String name;
  final double totalAmount;
  final int totalMonths;
  final String phoneNumber;
  final String address;
  final String treatmentType;
  final DateTime registrationDate;
  final double paidAmount;
  final int paymentDayOfMonth;
  final String notes;

  Patient({
    this.id,
    required this.name,
    required this.totalAmount,
    required this.totalMonths,
    required this.phoneNumber,
    required this.address,
    required this.treatmentType,
    required this.registrationDate,
    this.paidAmount = 0.0,
    this.paymentDayOfMonth = 1,
    this.notes = '',
  });

  double get monthlyAmount => totalMonths > 0 ? totalAmount / totalMonths : 0;

  double get remainingAmount => totalAmount - paidAmount;

  int get remainingMonths {
    if (monthlyAmount == 0) return 0;
    final paidMonths = (paidAmount / monthlyAmount).floor();
    return totalMonths - paidMonths;
  }

  DateTime get nextPaymentDate {
    if (monthlyAmount == 0) return registrationDate;
    final paidMonths = (paidAmount / monthlyAmount).floor();
    return DateTime(
      registrationDate.year,
      registrationDate.month + paidMonths + 1,
      paymentDayOfMonth,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'totalAmount': totalAmount,
      'totalMonths': totalMonths,
      'phoneNumber': phoneNumber,
      'address': address,
      'treatmentType': treatmentType,
      'registrationDate': registrationDate.millisecondsSinceEpoch,
      'paidAmount': paidAmount,
      'paymentDayOfMonth': paymentDayOfMonth,
      'notes': notes,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      totalAmount: map['totalAmount'],
      totalMonths: map['totalMonths'],
      phoneNumber: map['phoneNumber'],
      address: map['address'] ?? '',
      treatmentType: map['treatmentType'] ?? '',
      registrationDate:
          DateTime.fromMillisecondsSinceEpoch(map['registrationDate']),
      paidAmount: map['paidAmount'] ?? 0.0,
      paymentDayOfMonth: map['paymentDayOfMonth'] ?? 1,
      notes: map['notes'] ?? '',
    );
  }

  Patient copyWith({
    int? id,
    String? name,
    double? totalAmount,
    int? totalMonths,
    String? phoneNumber,
    String? address,
    String? treatmentType,
    DateTime? registrationDate,
    double? paidAmount,
    int? paymentDayOfMonth,
    String? notes,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      totalAmount: totalAmount ?? this.totalAmount,
      totalMonths: totalMonths ?? this.totalMonths,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      treatmentType: treatmentType ?? this.treatmentType,
      registrationDate: registrationDate ?? this.registrationDate,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentDayOfMonth: paymentDayOfMonth ?? this.paymentDayOfMonth,
      notes: notes ?? this.notes,
    );
  }
}
