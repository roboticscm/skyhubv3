import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class Services {
  final int id;
  final String imageData;
  final String name;
  final num price;

  Services({this.id, this.imageData, this.name, this.price});

  factory Services.fromJson(Map<String, dynamic> json) => _$ServicesFromJson(json);
  Map<String, dynamic> toJson() => _$ServicesToJson(this);
}




@JsonSerializable()
class Doctor {
  final int id;
  final String imageData;
  final String title;
  final String fullName;
  final String department;
  final String schedule;

  Doctor({this.id, this.imageData, this.title, this.fullName, this.department, this.schedule});


  factory Doctor.fromJson(Map<String, dynamic> json) => _$DoctorFromJson(json);
  Map<String, dynamic> toJson() => _$DoctorToJson(this);
}


@JsonSerializable()
class Booking {
  final int id;
  final int serviceId;
  final int doctorId;
  final DateTime schedule;
  final String note;

  Booking({this.id, this.serviceId, this.doctorId, this.schedule, this.note});


  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
  Map<String, dynamic> toJson() => _$BookingToJson(this);
}