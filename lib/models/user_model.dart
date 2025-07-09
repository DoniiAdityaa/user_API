import 'package:json_annotation/json_annotation.dart';
part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: "createdAt")
  DateTime createdAt;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "avatar")
  String avatar;
  @JsonKey(name: "address")
  String address;
  @JsonKey(name: "id")
  String id;

  UserModel({
    required this.createdAt,
    required this.name,
    required this.avatar,
    required this.address,
    required this.id,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
