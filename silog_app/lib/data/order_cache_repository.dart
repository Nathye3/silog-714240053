import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

import '../model/order.dart';

class OrderCacheRepository {
  OrderCacheRepository._();

  static final OrderCacheRepository instance = OrderCacheRepository._();

  Database? _db;
  final _store = intMapStoreFactory.store('order_api');

  Future<Database> get _database async {
    if (_db != null) return _db!;

    if (kIsWeb) {
      _db = await databaseFactoryWeb.openDatabase('silog.db');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      _db = await databaseFactoryIo.openDatabase('${dir.path}/silog.db');
    }
    return _db!;
  }

  Future<void> simpanSemua(List<Order> daftar) async {
    final db = await _database;
    await _store.delete(db);
    for (final order in daftar) {
      await _store.add(db, order.toMap());
    }
  }

  Future<List<Order>> ambilSemua() async {
    final db = await _database;
    final records = await _store.find(db);
    return records.map((record) => Order.fromJson(record.value)).toList();
  }
}
