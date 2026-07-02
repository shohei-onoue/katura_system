import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final CollectionReference _orderCollection =
      FirebaseFirestore.instance.collection('orders');

  Future<void> saveOrder(OrderModel order) async {
    await _orderCollection.doc(order.id).set(order.toMap());
  }

  Future<List<OrderModel>> getAllOrders() async {
    final snapshot = await _orderCollection
        .orderBy('deliveryDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _orderCollection.doc(orderId).update({'status': status});
  }

  Future<void> deleteOrder(String orderId) async {
    await _orderCollection.doc(orderId).delete();
  }
}
