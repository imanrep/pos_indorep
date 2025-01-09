import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_indorep/model/model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Menu Firebase
  Future<List<Menu>> getAllMenus() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('menus').get();
      List<Menu> menus = querySnapshot.docs
          .map((e) => Menu.fromMap(e.data() as Map<String, dynamic>))
          .toList();
      return menus;
    } catch (e) {
      rethrow;
    }
  }

  Future<Menu> addMenu(Menu menu) async {
    try {
      DocumentReference docRef =
          _firestore.collection('menus').doc(menu.menuId);
      await docRef.set(menu.toMap());
      DocumentSnapshot docSnap = await docRef.get();
      return Menu.fromMap(docSnap.data() as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pushExampleData(List<Menu> exampleMenu) async {
    try {
      for (var menu in exampleMenu) {
        DocumentReference docRef =
            _firestore.collection('menus').doc(menu.menuId);
        await docRef.set(menu.toMap());
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMenu(Menu menu) async {
    try {
      DocumentReference docRef = _firestore
          .collection('menus')
          .doc(menu.category.categoryId)
          .collection(menu.menuId)
          .doc(menu.menuId);
      await docRef.update(menu.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMenu(Menu menu) async {
    try {
      DocumentReference docRef =
          _firestore.collection('menus').doc(menu.menuId);
      await docRef.delete();
    } catch (e) {
      rethrow;
    }
  }

  // Category Firebase
  Future<List<Category>> getAllCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('categories').get();
      List<Category> categories = querySnapshot.docs
          .map((e) => Category.fromMap(e.data() as Map<String, dynamic>))
          .toList();
      return categories;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addCategory(String category) async {
    try {
      DocumentReference docRef =
          _firestore.collection('categories').doc(category);
      await docRef.set({
        'categoryId': category,
        'createdAt': DateTime.now().millisecondsSinceEpoch
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(String category) async {
    try {
      DocumentReference docRef =
          _firestore.collection('categories').doc(category);
      await docRef.delete();
    } catch (e) {
      rethrow;
    }
  }

  // Transaction Firebase
  Future<void> addTransaction(TransactionModel transaction) {
    try {
      DocumentReference docRef =
          _firestore.collection('transactions').doc(transaction.transactionId);
      return docRef.set(transaction.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TransactionModel>> getAllTransaction() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('transactions').get();
      List<TransactionModel> transactions = querySnapshot.docs
          .map(
              (e) => TransactionModel.fromMap(e.data() as Map<String, dynamic>))
          .toList();
      return transactions;
    } catch (e) {
      rethrow;
    }
  }
}
