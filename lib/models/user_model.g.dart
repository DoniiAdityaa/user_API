// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  createdAt: DateTime.parse(json['createdAt'] as String),
  name: json['name'] as String,
  avatar: json['avatar'] as String,
  address: json['address'] as String,
  id: json['id'] as String,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'createdAt': instance.createdAt.toIso8601String(),
  'name': instance.name,
  'avatar': instance.avatar,
  'address': instance.address,
  'id': instance.id,
};
