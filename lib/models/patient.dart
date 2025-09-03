class Patient {
  int get installmentMonths => totalMonths;
  final String? id; // تغيير من int إلى String لـ MongoDB ObjectId
  final String name;
  final double totalAmount;
  final int totalMonths;
  final String phoneNumber;
  final String address;
  final String treatmentType;
  final DateTime? registrationDate;
  final double paidAmount;
  final int paymentDayOfMonth;
  final String notes;
  final double? monthlyAmount; // إضافة للتوافق مع API
  final DateTime? nextPaymentDate; // إضافة للتوافق مع API

  Patient({
    this.id,
    required this.name,
    required this.totalAmount,
    required this.totalMonths,
    required this.phoneNumber,
    this.address = '',
    this.treatmentType = '',
    this.registrationDate,
    this.paidAmount = 0.0,
    this.paymentDayOfMonth = 1,
    this.notes = '',
    this.monthlyAmount,
    this.nextPaymentDate,
  });

  // حساب الدفعة الشهرية
  double get calculatedMonthlyAmount => 
      monthlyAmount ?? (totalMonths > 0 ? totalAmount / totalMonths : 0);

  double get remainingAmount => totalAmount - paidAmount;

  int get remainingMonths {
    if (calculatedMonthlyAmount == 0) return 0;
    final paidMonths = (paidAmount / calculatedMonthlyAmount).floor();
    return totalMonths - paidMonths;
  }

  // حساب تاريخ الدفعة القادمة
  DateTime get calculatedNextPaymentDate {
    if (nextPaymentDate != null) return nextPaymentDate!;
    
    if (calculatedMonthlyAmount == 0 || registrationDate == null) {
      return registrationDate ?? DateTime.now();
    }
    
    final paidMonths = (paidAmount / calculatedMonthlyAmount).floor();
    return DateTime(
      registrationDate!.year,
      registrationDate!.month + paidMonths + 1,
      paymentDayOfMonth,
    );
  }

  // التحقق من التأخير في الدفع
  bool get isOverdue {
    if (remainingAmount <= 0) return false;
    final nextDate = nextPaymentDate ?? calculatedNextPaymentDate;
    return DateTime.now().isAfter(nextDate);
  }

  // عدد الأيام المتأخرة
  int get daysOverdue {
    if (!isOverdue) return 0;
    final nextDate = nextPaymentDate ?? calculatedNextPaymentDate;
    return DateTime.now().difference(nextDate).inDays;
  }

  // تحويل إلى JSON للإرسال إلى API
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone_number': phoneNumber,
      'total_amount': totalAmount,
      'total_months': totalMonths,
      'address': address,
      'treatment_type': treatmentType,
      'registration_date': registrationDate?.toIso8601String().split('T')[0],
      'paid_amount': paidAmount,
      'payment_day_of_month': paymentDayOfMonth,
      'notes': notes,
    };
  }

  // إنشاء من JSON response من API
  factory Patient.fromJson(Map<String, dynamic> json) {
    // حساب المبلغ المدفوع الصحيح
    double calculatedPaidAmount = (json['paid_amount'] as num?)?.toDouble() ?? 0.0;
    
    // إذا كان هناك remaining_amount في الاستجابة، استخدمه لحساب paid_amount
    if (json['remaining_amount'] != null) {
      double totalAmt = (json['total_amount'] as num).toDouble();
      double remainingAmt = (json['remaining_amount'] as num).toDouble();
      calculatedPaidAmount = totalAmt - remainingAmt;
    }
    
    return Patient(
      id: json['_id'] as String?,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      totalMonths: json['total_months'] as int,
      address: json['address'] as String? ?? '',
      treatmentType: json['treatment_type'] as String? ?? '',
      registrationDate: json['registration_date'] != null 
          ? DateTime.parse(json['registration_date']) 
          : null,
      paidAmount: calculatedPaidAmount,
      paymentDayOfMonth: json['payment_day_of_month'] as int? ?? 1,
      notes: json['notes'] as String? ?? '',
      monthlyAmount: (json['monthly_amount'] as num?)?.toDouble(),
      nextPaymentDate: json['next_payment_date'] != null 
          ? DateTime.parse(json['next_payment_date']) 
          : null,
    );
  }

  // الطرق القديمة للتوافق مع الكود الموجود
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'totalAmount': totalAmount,
      'totalMonths': totalMonths,
      'phoneNumber': phoneNumber,
      'address': address,
      'treatmentType': treatmentType,
      'registrationDate': registrationDate?.millisecondsSinceEpoch,
      'paidAmount': paidAmount,
      'paymentDayOfMonth': paymentDayOfMonth,
      'notes': notes,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id']?.toString(),
      name: map['name'],
      totalAmount: map['totalAmount'],
      totalMonths: map['totalMonths'],
      phoneNumber: map['phoneNumber'],
      address: map['address'] ?? '',
      treatmentType: map['treatmentType'] ?? '',
      registrationDate: map['registrationDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['registrationDate'])
          : null,
      paidAmount: map['paidAmount'] ?? 0.0,
      paymentDayOfMonth: map['paymentDayOfMonth'] ?? 1,
      notes: map['notes'] ?? '',
    );
  }

  Patient copyWith({
    String? id,
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
    double? monthlyAmount,
    DateTime? nextPaymentDate,
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
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
    );
  }
}
