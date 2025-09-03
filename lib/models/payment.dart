class Payment {
  final String? id; // تغيير من int إلى String لـ MongoDB ObjectId
  final String patientName;
  final double amount;
  final DateTime? paymentDate;
  final String notes;

  Payment({
    this.id,
    required this.patientName,
    required this.amount,
    this.paymentDate,
    this.notes = '',
  });

  // تحويل إلى JSON للإرسال إلى API
  Map<String, dynamic> toJson() {
    return {
      'patient_name': patientName,
      'amount': amount,
      'payment_date': paymentDate?.toIso8601String().split('T')[0],
      'notes': notes,
    };
  }

  // إنشاء من JSON response من API
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['_id'] as String?,
      patientName: json['patient_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: json['payment_date'] != null 
          ? DateTime.parse(json['payment_date']) 
          : null,
      notes: json['notes'] as String? ?? '',
    );
  }

  // الطرق القديمة للتوافق مع الكود الموجود
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientName': patientName,
      'amount': amount,
      'paymentDate': paymentDate?.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id']?.toString(),
      patientName: map['patientName'],
      amount: map['amount'],
      paymentDate: map['paymentDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['paymentDate'])
          : null,
      notes: map['notes'] ?? '',
    );
  }
}
