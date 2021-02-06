import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class Customer {
  final int id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String email;
  final String logo;
  final bool defaultCustomer;
  final String apiUrl;
  final int skyoneCompanyId;
  final int skyoneNode;
  final String skyoneWebUrl;
  final int counter;

  Customer({this.id, this.name, this.description, this.address, this.phone, this.email, this.logo, this.defaultCustomer, this.apiUrl, this.skyoneCompanyId, this.skyoneNode, this.skyoneWebUrl, this.counter});

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}


