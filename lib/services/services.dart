import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:battery_example/models/battery_level.dart';

final CollectionReference batteryCollection =
    FirebaseFirestore.instance.collection("batteries");

class BatteryService {
  Future<BatteryLevel> create(BatteryLevel batteryLevel) {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(batteryCollection.doc());

      final Map<String, dynamic> data = batteryLevel.toMap();

      await tx.set(ds.reference, data);

      return data;
    };

    return FirebaseFirestore.instance
        .runTransaction(createTransaction)
        .then((mapData) => BatteryLevel.fromMap(mapData))
        .catchError((e) {
      print('error: $e');
      return null;
    });
  }

  Stream<QuerySnapshot> getAll({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = batteryCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Future<DocumentSnapshot> getById(String id) {
    return batteryCollection.doc(id).get();
  }
}