import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:api/models/user_model.dart';

class FirebaseUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // --- CREATE USER ---
  Future<UserModel> createUser(String name, String address) async {
    try {
      final userData = {
        'name': name,
        'address': address,
        'createdAt': FieldValue.serverTimestamp(),
        'avatar': 'https://i.pravatar.cc/150?u=${DateTime.now().millisecondsSinceEpoch}',
      };

      final docRef = await _firestore.collection(_collection).add(userData);
      
      // Get the created document to return with the generated ID
      final doc = await docRef.get();
      final data = doc.data()!;
      
      // Convert Firestore data to UserModel
      final user = UserModel(
        id: doc.id,
        name: data['name'],
        address: data['address'],
        avatar: data['avatar'],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? 
                   DateTime.now(),
      );

      print('✅ User created in Firebase: ${user.name}');
      return user;
    } catch (e) {
      print('❌ Failed to create user in Firebase: $e');
      throw Exception('Failed to create user in Firebase: $e');
    }
  }

  // --- READ ALL USERS ---
  Future<List<UserModel>> getUsers() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      final users = snapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel(
          id: doc.id,
          name: data['name'],
          address: data['address'],
          avatar: data['avatar'],
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? 
                     DateTime.now(),
        );
      }).toList();

      print('✅ Retrieved ${users.length} users from Firebase');
      return users;
    } catch (e) {
      print('❌ Failed to get users from Firebase: $e');
      throw Exception('Failed to get users from Firebase: $e');
    }
  }

  // --- READ ONE USER ---
  Future<UserModel> getUserById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      
      if (!doc.exists) {
        throw Exception('User not found');
      }

      final data = doc.data()!;
      return UserModel(
        id: doc.id,
        name: data['name'],
        address: data['address'],
        avatar: data['avatar'],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? 
                   DateTime.now(),
      );
    } catch (e) {
      print('❌ Failed to get user from Firebase: $e');
      throw Exception('Failed to get user from Firebase: $e');
    }
  }

  // --- UPDATE USER ---
  Future<UserModel> updateUser(String id, String newName, String newAddress) async {
    try {
      final updateData = {
        'name': newName,
        'address': newAddress,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(_collection).doc(id).update(updateData);
      
      // Get the updated document
      final doc = await _firestore.collection(_collection).doc(id).get();
      final data = doc.data()!;

      final user = UserModel(
        id: doc.id,
        name: data['name'],
        address: data['address'],
        avatar: data['avatar'],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? 
                   DateTime.now(),
      );

      print('✅ User updated in Firebase: ${user.name}');
      return user;
    } catch (e) {
      print('❌ Failed to update user in Firebase: $e');
      throw Exception('Failed to update user in Firebase: $e');
    }
  }

  // --- DELETE USER ---
  Future<void> deleteUserById(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      print('✅ User deleted from Firebase: $id');
    } catch (e) {
      print('❌ Failed to delete user from Firebase: $e');
      throw Exception('Failed to delete user from Firebase: $e');
    }
  }

  // --- REAL-TIME STREAM ---
  Stream<List<UserModel>> getUsersStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel(
          id: doc.id,
          name: data['name'],
          address: data['address'],
          avatar: data['avatar'],
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? 
                     DateTime.now(),
        );
      }).toList();
    });
  }
}
