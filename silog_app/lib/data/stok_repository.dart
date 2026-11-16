import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

import '../model/stok.dart';

class StokRepository {
  static final StokRepository instance = StokRepository._();

  StokRepository._();

  Database? _db;

  final _store = intMapStoreFactory.store('stok');

  // DATABASE
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

  // CREATE
  Future<int> simpan(Stok stok) async {
    final db = await _database;
    return await _store.add(db, stok.toMap());
  }

  // READ ALL + SEARCH
  Future<List<Stok>> ambilSemua({String? kodeGudang, String? kataKunci}) async {
    final db = await _database;

    final filters = <Filter>[];

    if (kodeGudang != null && kodeGudang.isNotEmpty) {
      filters.add(Filter.equals('kodeGudang', kodeGudang));
    }

    if (kataKunci != null && kataKunci.trim().isNotEmpty) {
      final pola = RegExp(
        '.*${RegExp.escape(kataKunci.trim())}.*',
        caseSensitive: false,
      );

      filters.add(Filter.matchesRegExp('namaBarang', pola));
    }

    final finder = Finder(
      filter: filters.isEmpty ? null : Filter.and(filters),
      sortOrders: [SortOrder('namaBarang')],
    );

    final records = await _store.find(db, finder: finder);

    return records.map((record) {
      return Stok.fromMap(record.key, record.value);
    }).toList();
  }

  // READ ONE
  Future<Stok?> ambilSatu(int id) async {
    final db = await _database;

    final data = await _store.record(id).get(db);

    if (data == null) return null;

    return Stok.fromMap(id, data);
  }

  // UPDATE
  Future<void> perbarui(Stok stok) async {
    if (stok.id == null) {
      throw ArgumentError('ID stok tidak boleh kosong');
    }

    final db = await _database;

    await _store.record(stok.id!).update(db, stok.toMap());
  }

  // DELETE
  Future<void> hapus(int id) async {
    final db = await _database;

    await _store.record(id).delete(db);
  }

  // TOTAL STOK GUDANG
  Future<int> totalStokGudang(String kodeGudang) async {
    final daftar = await ambilSemua(kodeGudang: kodeGudang);

    return daftar.fold<int>(0, (total, stok) => total + stok.jumlah);
  }

  // DELETE ALL
  Future<void> kosongkan() async {
    final db = await _database;

    await _store.delete(db);
  }

  // CLOSE DATABASE
  Future<void> tutupDatabase() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
