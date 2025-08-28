class Payment {
  final int? id;
  final String patientName;
  final double amount;
  final DateTime paymentDate;
  final String notes;

  Payment({
    this.id,
    required this.patientName,
    required this.amount,
    required this.paymentDate,
    this.notes = '',
  });

  // تحويل إلى Map للحفظ في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientName': patientName,
      'amount': amount,
      'paymentDate': paymentDate.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  // إنشاء من Map
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      patientName: map['patientName'],
      amount: map['amount'],
      paymentDate: DateTime.fromMillisecondsSinceEpoch(map['paymentDate']),
      notes: map['notes'] ?? '',
    );
  }
}
