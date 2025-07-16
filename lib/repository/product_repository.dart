import 'package:api/models/product_model.dart';
import 'package:api/service/database_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class ProductRepository {
  // panggilan untuk database service
  final DatabaseService _databaseService = DatabaseService.instance;
  // Read all mengambil semua data dari database lokal
  Future<List<ProductModel>> getProducts() async {
    return await _databaseService.readAllProducts();
  }

  // create langsung di simpan di database lokal
  Future<void> createProduct(String name, int price) async {
    final newProduct = ProductModel(
      id: const Uuid().v4(),
      name: name,
      price: price,
    );
    await _databaseService.createProduct(newProduct);
  }

  // Update langsung di simpan di database lokal
  Future<void> updateProduct(ProductModel product) async {
    await _databaseService.updateProduct(product);
  }

  // Delete langsung di hapus dari database lokal
  Future<void> deleteProduct(String id) async {
    await _databaseService.deleteProduct(id);
  }
}
