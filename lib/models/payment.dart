class Payment {
  final int? id;
  final String patientName;
  final double amount;
  final DateTime paymentDate;
  final String notes; // <-- أضفنا هذا

  Payment({
    this.id,
    required this.patientName,
    required this.amount,
    required this.paymentDate,
    this.notes = '', // نخليها اختيارية (افتراضي فارغ)
  });

  // تحويل إلى Map للحفظ في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientName': patientName,
      'amount': amount,
      'paymentDate': paymentDate.millisecondsSinceEpoch,
      'notes': notes, // <-- أضفنا هذا
    };
  }

  // إنشاء من Map
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      patientName: map['patientName'],
      amount: (map['amount'] as num).toDouble(),
      paymentDate: DateTime.fromMillisecondsSinceEpoch(map['paymentDate']),
      notes: map['notes'] ?? '', // <-- أضفنا هذا
    );
  }
}
