// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) {
  return Customer(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String,
    address: json['address'] as String,
    phone: json['phone'] as String,
    email: json['email'] as String,
    logo: json['logo'] as String,
    defaultCustomer: json['defaultCustomer'] as bool,
    apiUrl: json['apiUrl'] as String,
    skyoneCompanyId: json['skyoneCompanyId'] as int,
    skyoneNode: json['skyoneNode'] as int,
    skyoneWebUrl: json['skyoneWebUrl'] as String,
    counter: json['counter'] as int,
  );
}

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'phone': instance.phone,
      'email': instance.email,
      'logo': instance.logo,
      'defaultCustomer': instance.defaultCustomer,
      'apiUrl': instance.apiUrl,
      'skyoneCompanyId': instance.skyoneCompanyId,
      'skyoneNode': instance.skyoneNode,
      'skyoneWebUrl': instance.skyoneWebUrl,
      'counter': instance.counter,
    };
