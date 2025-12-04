class Salon {
  final int? id;
  final String? salonName;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? contactNumber;
  final String? imageUrl;
  final String? approvalStatus;
  final String? openTime;
  final String? closeTime;
  final int? ownerId;
  final String? category;
  final bool? isLive;
  final double? latitude;
  final double? longitude;
  final String? establishedYear;
  final String? description;
  final int? numberOfStaff;
  final String? specialities;
  final String? languages;
  final String? serviceArea;

  Salon({
    this.id,
    this.salonName,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.contactNumber,
    this.imageUrl,
    this.approvalStatus,
    this.openTime,
    this.closeTime,
    this.ownerId,
    this.category,
    this.isLive,
    this.latitude,
    this.longitude,
    this.establishedYear,
    this.description,
    this.numberOfStaff,
    this.specialities,
    this.languages,
    this.serviceArea,
  });

  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['id'] as int?,
      salonName: json['salonName'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      contactNumber: json['contactNumber'] as String?,
      imageUrl: json['imageUrl'] as String?,
      approvalStatus: json['approvalStatus'] as String?,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      ownerId: json['ownerId'] as int?,
      category: json['category'] as String?,
      isLive: json['isLive'] as bool?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      establishedYear: json['establishedYear'] as String?,
      description: json['description'] as String?,
      numberOfStaff: json['numberOfStaff'] as int?,
      specialities: json['specialities'] as String?,
      languages: json['languages'] as String?,
      serviceArea: json['serviceArea'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salonName': salonName,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'contactNumber': contactNumber,
      'imageUrl': imageUrl,
      'approvalStatus': approvalStatus,
      'openTime': openTime,
      'closeTime': closeTime,
      'ownerId': ownerId,
      'category': category,
      'isLive': isLive,
      'latitude': latitude,
      'longitude': longitude,
      'establishedYear': establishedYear,
      'description': description,
      'numberOfStaff': numberOfStaff,
      'specialities': specialities,
      'languages': languages,
      'serviceArea': serviceArea,
    };
  }
}

