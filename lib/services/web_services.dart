import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_indorep/web/model/web_model.dart';

class WebServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch operator list
  Future<List<String>> getOperators() async {
    final snapshot = await _firestore.collection('operators').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> setCurrentOperator(String operatorId) async {
    await _firestore.collection('appState').doc('currentOperator').set({
      'operator': operatorId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> getCurrentOperator() async {
    final doc =
        await _firestore.collection('appState').doc('currentOperator').get();
    return doc.exists ? doc['operator'] : null;
  }

  // Fetch PCs
  Stream<QuerySnapshot> getPCsStream() {
    return _firestore.collection('pcs').snapshots();
  }

  // Add PC
  Future<void> addPC(IndorepPcsUpdateModel pc) async {
    await _firestore.collection('pcs').doc(pc.pcId).set(pc.toJson());
  }

  Future<void> addUpdatetoPC(IndorepPcsUpdateModel pc) async {
    await _firestore.collection('pcs').doc(pc.pcId).update({
      'updates':
          FieldValue.arrayUnion(pc.updates.map((e) => e.toJson()).toList()),
    });
  }

  Future<void> removePC(String pcId) async {
    await _firestore.collection('pcs').doc(pcId).delete();
  }

  Future<void> addCashierEntry({
    required IndorepWarnetModel entry,
  }) async {
    await _firestore.collection('cashier').add(entry.toJson());
  }

  // Get cashier entries
  Stream<QuerySnapshot> getCashierEntries() {
    return _firestore.collection('cashier').snapshots();
  }

  Stream<QuerySnapshot> getWarnetEntriesByDate(DateTime date) {
    Timestamp startTimestamp =
        Timestamp.fromDate(DateTime(date.year, date.month, date.day));
    Timestamp endTimestamp =
        Timestamp.fromDate(DateTime(date.year, date.month, date.day + 1));

    return _firestore
        .collection('cashier')
        .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
        .where('timestamp', isLessThan: endTimestamp)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getBeveragesByDate(DateTime date) {
    Timestamp startTimestamp =
        Timestamp.fromDate(DateTime(date.year, date.month, date.day));
    Timestamp endTimestamp =
        Timestamp.fromDate(DateTime(date.year, date.month, date.day + 1));
    return _firestore
        .collection('beverages')
        .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
        .where('timestamp', isLessThan: endTimestamp)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getBeveragesEntries() {
    return _firestore.collection('beverages').snapshots();
  }

  Future<void> addBeveragesEntry({
    required IndorepBeveragesModel entry,
  }) async {
    await _firestore.collection('beverages').add(entry.toJson());
  }
}
