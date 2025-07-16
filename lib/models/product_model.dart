class ProductModel {
  // ini namanya property yang di miliki product
  final String id;
  final String name;
  final int price;
  // namanya membuat constructor
  ProductModel({required this.id, required this.name, required this.price});
  // membuat objek mnjadi format map/json untuk di save ke database
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price};
  }

  // membuat objek dari data yang di atas yaitu map/json
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
    );
  }
}
