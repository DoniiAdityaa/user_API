import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/product_model.dart'; //

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Fungsi ini akan membuat tabel 'products' saat aplikasi diinstall pertama kali
  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE products (
        id $idType,
        name $textType,
        price $integerType
      )
    ''');
  }

  // --- FUNGSI CRUD UNTUK PRODUK ---

  // CREATE Product
  Future<void> createProduct(ProductModel product) async {
    final db = await instance.database;
    await db.insert(
      'products',
      product.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ All Products
  Future<List<ProductModel>> readAllProducts() async {
    final db = await instance.database;
    final result = await db.query('products', orderBy: 'name ASC');
    return result.map((json) => ProductModel.fromJson(json)).toList();
  }

  // UPDATE Product
  Future<int> updateProduct(ProductModel product) async {
    final db = await instance.database;
    return db.update(
      'products',
      product.toJson(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // DELETE Product
  Future<int> deleteProduct(String id) async {
    final db = await instance.database;
    return db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Fungsi untuk menutup koneksi
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
