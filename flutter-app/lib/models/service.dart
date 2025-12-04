class Service {
  final int? id;
  final String? serviceName;
  final double? price;
  final int? durationMinutes;
  final String? description;
  final String? category;
  final String? subCategory;
  final int? salonId;
  final bool? isActive;

  Service({
    this.id,
    this.serviceName,
    this.price,
    this.durationMinutes,
    this.description,
    this.category,
    this.subCategory,
    this.salonId,
    this.isActive,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int?,
      serviceName: json['serviceName'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      durationMinutes: json['durationMinutes'] as int?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      subCategory: json['subCategory'] as String?,
      salonId: json['salonId'] as int?,
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'price': price,
      'durationMinutes': durationMinutes,
      'description': description,
      'category': category,
      'subCategory': subCategory,
      'salonId': salonId,
      'isActive': isActive,
    };
  }
}

