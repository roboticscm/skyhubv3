// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Services _$ServicesFromJson(Map<String, dynamic> json) {
  return Services(
    id: json['id'] as int,
    imageData: json['imageData'] as String,
    name: json['name'] as String,
    price: json['price'] as num,
  );
}

Map<String, dynamic> _$ServicesToJson(Services instance) => <String, dynamic>{
      'id': instance.id,
      'imageData': instance.imageData,
      'name': instance.name,
      'price': instance.price,
    };

Doctor _$DoctorFromJson(Map<String, dynamic> json) {
  return Doctor(
    id: json['id'] as int,
    imageData: json['imageData'] as String,
    title: json['title'] as String,
    fullName: json['fullName'] as String,
    department: json['department'] as String,
    schedule: json['schedule'] as String,
  );
}

Map<String, dynamic> _$DoctorToJson(Doctor instance) => <String, dynamic>{
      'id': instance.id,
      'imageData': instance.imageData,
      'title': instance.title,
      'fullName': instance.fullName,
      'department': instance.department,
      'schedule': instance.schedule,
    };

Booking _$BookingFromJson(Map<String, dynamic> json) {
  return Booking(
    id: json['id'] as int,
    serviceId: json['serviceId'] as int,
    doctorId: json['doctorId'] as int,
    schedule: json['schedule'] == null
        ? null
        : DateTime.parse(json['schedule'] as String),
    note: json['note'] as String,
  );
}

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
      'id': instance.id,
      'serviceId': instance.serviceId,
      'doctorId': instance.doctorId,
      'schedule': instance.schedule?.toIso8601String(),
      'note': instance.note,
    };
