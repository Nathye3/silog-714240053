import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../model/order.dart';

class GagalApi implements Exception {
  final String pesan;
  final int? kode;

  const GagalApi(this.pesan, {this.kode});

  @override
  String toString() => pesan;
}

class OrderApi {
  static const String alamatBawaan = String.fromEnvironment(
    'ORDER_API_URL',
    defaultValue: 'https://jsonplaceholder.typicode.com',
  );
  static const Duration _batasWaktu = Duration(seconds: 12);

  final http.Client _client;
  final Uri _basis;

  OrderApi({http.Client? client, String baseUrl = alamatBawaan})
    : _client = client ?? http.Client(),
      _basis = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/');

  Future<List<Order>> ambilDaftar({int limit = 10}) async {
    final url = _basis
        .resolve('posts')
        .replace(queryParameters: {'_limit': '$limit'});

    try {
      final res = await _client.get(url).timeout(_batasWaktu);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        return data
            .map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      _lemparError(res.statusCode);
    } on SocketException {
      throw const GagalApi('Tidak ada koneksi internet');
    } on http.ClientException {
      throw const GagalApi(
        'Tidak dapat terhubung ke layanan web. Periksa alamat server dan koneksi internet.',
      );
    } on TimeoutException {
      throw const GagalApi('Waktu tunggu habis, periksa jaringan Anda');
    } on FormatException {
      throw const GagalApi('Format data dari server tidak sesuai');
    }
    throw const GagalApi('Gagal mengambil data order');
  }

  Future<Order> kirimOrder(Order order) async {
    final url = _basis.resolve('posts');
    try {
      final res = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(order.toJson()),
          )
          .timeout(_batasWaktu);

      if (res.statusCode == 201 || res.statusCode == 200) {
        return Order.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      }
      _lemparError(res.statusCode);
    } on SocketException {
      throw const GagalApi('Tidak ada koneksi internet');
    } on http.ClientException {
      throw const GagalApi(
        'Tidak dapat mengirim order. Periksa alamat server dan koneksi internet.',
      );
    } on TimeoutException {
      throw const GagalApi('Waktu tunggu habis saat mengirim order');
    } on FormatException {
      throw const GagalApi('Format respons server tidak sesuai');
    }
    throw const GagalApi('Gagal mengirim order');
  }

  Future<Order> perbaruiOrder(Order order) async {
    if (order.id == null) {
      throw const GagalApi('Order tidak memiliki ID');
    }

    final url = _basis.resolve('posts/${order.id}');
    try {
      final res = await _client
          .put(
            url,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(order.toJson()),
          )
          .timeout(_batasWaktu);

      if (res.statusCode == 200) {
        return Order.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      }
      _lemparError(res.statusCode);
    } on SocketException {
      throw const GagalApi('Tidak ada koneksi internet');
    } on http.ClientException {
      throw const GagalApi(
        'Tidak dapat memperbarui order. Periksa alamat server dan koneksi internet.',
      );
    } on TimeoutException {
      throw const GagalApi('Waktu tunggu habis saat memperbarui order');
    } on FormatException {
      throw const GagalApi('Format respons server tidak sesuai');
    }
    throw const GagalApi('Gagal memperbarui order');
  }

  Future<void> hapusOrder(int id) async {
    final url = _basis.resolve('posts/$id');
    try {
      final res = await _client.delete(url).timeout(_batasWaktu);
      if (res.statusCode == 200 || res.statusCode == 204) return;
      _lemparError(res.statusCode);
    } on SocketException {
      throw const GagalApi('Tidak ada koneksi internet');
    } on http.ClientException {
      throw const GagalApi(
        'Tidak dapat menghapus order. Periksa alamat server dan koneksi internet.',
      );
    } on TimeoutException {
      throw const GagalApi('Waktu tunggu habis saat menghapus order');
    }
  }

  Never _lemparError(int statusCode) {
    if (statusCode == 400) {
      throw GagalApi(
        'Permintaan tidak valid. Periksa data input.',
        kode: statusCode,
      );
    } else if (statusCode == 401) {
      throw GagalApi(
        'Anda perlu memiliki hak akses untuk tindakan ini.',
        kode: statusCode,
      );
    } else if (statusCode == 404) {
      throw GagalApi('Data order tidak ditemukan.', kode: statusCode);
    } else if (statusCode >= 500) {
      throw GagalApi(
        'Server sedang bermasalah, coba beberapa saat lagi.',
        kode: statusCode,
      );
    }
    throw GagalApi('Permintaan ditolak server.', kode: statusCode);
  }

  void tutup() => _client.close();
}
