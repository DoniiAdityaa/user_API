// lib/service/database_service.dart

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL DEFAULT 0';
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        name $textType,
        avatar $textType,
        address $textType,
        createdAt $textType,
        isLocalOnly $boolType,
        needsSync $boolType,
        syncAction $textType,
        lastModified $textType
      )
    ''');
  }

  // Create User
  Future<void> createUser(UserModel user) async {
    try {
      final db = await instance.database;
      print('[DB] Creating user: ${user.name} with ID: ${user.id}');
      await db.insert(
        'users',
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('[DB] User created successfully in local database');
    } catch (e) {
      print('[DB] Error creating user: $e');
      rethrow;
    }
  }

  // Read User
  Future<List<UserModel>> readAllUsers() async {
    final db = await instance.database;
    final result = await db.query('users', orderBy: 'name ASC');
    return result.map((json) => UserModel.fromJson(json)).toList();
  }

  // Read User by ID
  Future<UserModel?> getUserById(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isEmpty) {
      return null;
    }
    
    return UserModel.fromJson(result.first);
  }

  // Update User
  Future<int> updateUser(UserModel user) async {
    final db = await instance.database;
    return db.update(
      'users',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Delete User
  Future<int> deleteUser(String id) async {
    final db = await instance.database;
    return db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Cache Users
  Future<void> cacheAllUsers(List<UserModel> users) async {
    final db = await instance.database;
    final batch = db.batch();

    // Clear existing users
    batch.delete('users');

    // Insert all users
    for (var user in users) {
      batch.insert('users', user.toJson());
    }

    // Commit all operations at once
    await batch.commit(noResult: true);
  }
}
