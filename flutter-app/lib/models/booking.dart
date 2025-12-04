class Booking {
  final int? bookingId;
  final int? queueNumber;
  final String? status;
  final String? salonName;
  final String? serviceName;
  final double? servicePrice;
  final int? serviceDurationMinutes;
  final String? scheduledAt;
  final int? userId;
  final String? userName;
  final String? userMobile;
  final int? staffId;
  final String? staffName;
  final String? rejectionReason;

  Booking({
    this.bookingId,
    this.queueNumber,
    this.status,
    this.salonName,
    this.serviceName,
    this.servicePrice,
    this.serviceDurationMinutes,
    this.scheduledAt,
    this.userId,
    this.userName,
    this.userMobile,
    this.staffId,
    this.staffName,
    this.rejectionReason,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: json['bookingId'] as int?,
      queueNumber: json['queueNumber'] as int?,
      status: json['status'] as String?,
      salonName: json['salonName'] as String?,
      serviceName: json['serviceName'] as String?,
      servicePrice: (json['servicePrice'] as num?)?.toDouble(),
      serviceDurationMinutes: json['serviceDurationMinutes'] as int?,
      scheduledAt: json['scheduledAt'] as String?,
      userId: json['userId'] as int?,
      userName: json['userName'] as String?,
      userMobile: json['userMobile'] as String?,
      staffId: json['staffId'] as int?,
      staffName: json['staffName'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'queueNumber': queueNumber,
      'status': status,
      'salonName': salonName,
      'serviceName': serviceName,
      'servicePrice': servicePrice,
      'serviceDurationMinutes': serviceDurationMinutes,
      'scheduledAt': scheduledAt,
      'userId': userId,
      'userName': userName,
      'userMobile': userMobile,
      'staffId': staffId,
      'staffName': staffName,
      'rejectionReason': rejectionReason,
    };
  }
}

