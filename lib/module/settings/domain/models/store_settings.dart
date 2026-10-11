class StoreSettings {
  final String id;
  final String storeName;
  final String? address;
  final String? phoneNumber;
  final String? headerFooterNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StoreSettings({
    required this.id,
    required this.storeName,
    this.address,
    this.phoneNumber,
    this.headerFooterNote,
    this.createdAt,
    this.updatedAt,
  });

  factory StoreSettings.fromJson(Map<String, dynamic> json) {
    return StoreSettings(
      id: json['id'] as String? ?? '',
      storeName: json['store_name'] as String? ?? 'Warung Saya',
      address: json['address'] as String?,
      phoneNumber: json['phone_number'] as String?,
      headerFooterNote: json['header_footer_note'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_name': storeName,
      'address': address,
      'phone_number': phoneNumber,
      'header_footer_note': headerFooterNote,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  StoreSettings copyWith({
    String? id,
    String? storeName,
    String? address,
    String? phoneNumber,
    String? headerFooterNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoreSettings(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      headerFooterNote: headerFooterNote ?? this.headerFooterNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
