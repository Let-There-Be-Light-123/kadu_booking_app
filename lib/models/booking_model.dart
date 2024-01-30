class Booking {
  final String? bookingReference;
  final List<Map<String, dynamic>>? rooms;
  final List<Map<String, dynamic>>? property;
  final List<Map<String, dynamic>>? files;
  final List<Map<String, dynamic>>? roomDetails;
  final List<Map<String, dynamic>>? guests;
  final String? checkInDate;
  final String? checkOutDate;
  final String? status;
  final Map<String, dynamic>? bookedBy;
  final List<Map<String, dynamic>>? signatures;
  final String? updatedAt;
  final String? createdAt;

  Booking({
    this.bookingReference,
    this.rooms,
    this.property,
    this.files,
    this.roomDetails,
    this.guests,
    this.checkInDate,
    this.checkOutDate,
    this.status,
    this.bookedBy,
    this.signatures,
    this.updatedAt,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingReference: json['booking_reference'],
      rooms: List<Map<String, dynamic>>.from(json['rooms']),
      property: List<Map<String, dynamic>>.from(json['property']),
      files: List<Map<String, dynamic>>.from(json['files']),
      roomDetails: List<Map<String, dynamic>>.from(json['room_details']),
      guests: List<Map<String, dynamic>>.from(json['guests']),
      checkInDate: json['check_in_date'],
      checkOutDate: json['check_out_date'],
      status: json['status'],
      bookedBy: Map<String, dynamic>.from(json['booked_by']),
      signatures: List<Map<String, dynamic>>.from(json['signatures']),
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
    );
  }
}
