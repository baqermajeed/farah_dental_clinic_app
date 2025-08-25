class Patient {
  final int? id;
  final String name;
  final double totalAmount;
  final int totalMonths;
  final String phoneNumber;
  final DateTime registrationDate;
  final double paidAmount;

  Patient({
    this.id,
    required this.name,
    required this.totalAmount,
    required this.totalMonths,
    required this.phoneNumber,
    required this.registrationDate,
    this.paidAmount = 0.0,
  });

  // الحصول على المبلغ المتبقي
  double get remainingAmount => totalAmount - paidAmount;

  // الحصول على المبلغ الشهري
  double get monthlyAmount => totalAmount / totalMonths;

  // الحصول على عدد الأشهر المتبقية
  int get remainingMonths {
    final paidMonths = (paidAmount / monthlyAmount).floor();
    return totalMonths - paidMonths;
  }

  // الحصول على تاريخ التسديد القادم
  DateTime get nextPaymentDate {
    final paidMonths = (paidAmount / monthlyAmount).floor();
    return registrationDate.add(Duration(days: 30 * (paidMonths + 1)));
  }

  // تحويل إلى Map للحفظ في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'totalAmount': totalAmount,
      'totalMonths': totalMonths,
      'phoneNumber': phoneNumber,
      'registrationDate': registrationDate.millisecondsSinceEpoch,
      'paidAmount': paidAmount,
    };
  }

  // إنشاء من Map
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      totalAmount: map['totalAmount'],
      totalMonths: map['totalMonths'],
      phoneNumber: map['phoneNumber'],
      registrationDate:
          DateTime.fromMillisecondsSinceEpoch(map['registrationDate']),
      paidAmount: map['paidAmount'] ?? 0.0,
    );
  }

  // نسخ مع تحديث البيانات
  Patient copyWith({
    int? id,
    String? name,
    double? totalAmount,
    int? totalMonths,
    String? phoneNumber,
    DateTime? registrationDate,
    double? paidAmount,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      totalAmount: totalAmount ?? this.totalAmount,
      totalMonths: totalMonths ?? this.totalMonths,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      registrationDate: registrationDate ?? this.registrationDate,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }
}
