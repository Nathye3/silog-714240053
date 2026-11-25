import 'package:flutter/material.dart';

import '../data/order_api.dart';
import '../data/order_cache_repository.dart';
import '../model/order.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _api = OrderApi();
  final _cache = OrderCacheRepository.instance;
  final _pencarianController = TextEditingController();

  late Future<List<Order>> _future;
  String _kataKunci = '';
  String? _pesanPeringatan;

  @override
  void initState() {
    super.initState();
    _future = _ambilDenganCadangan();
  }

  Future<List<Order>> _ambilDenganCadangan() async {
    try {
      final daring = await _api.ambilDaftar();
      await _cache.simpanSemua(daring);
      _pesanPeringatan = null;
      return daring;
    } on GagalApi catch (e) {
      final lokal = await _cache.ambilSemua();
      if (lokal.isEmpty) rethrow;
      _pesanPeringatan =
          'Menampilkan data tersimpan. Data mungkin belum terbaru. $e';
      return lokal;
    }
  }

  Future<void> _muatUlang() async {
    setState(() => _future = _ambilDenganCadangan());
  }

  Future<List<Order>> _daftarSaatIni() async {
    try {
      return await _future;
    } catch (_) {
      return _cache.ambilSemua();
    }
  }

  Future<void> _simpanPerubahanLokal(List<Order> daftar) async {
    await _cache.simpanSemua(daftar);
    if (!mounted) return;
    setState(() => _future = Future.value(daftar));
  }

  void _tampilkanPesan(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _kirimContoh() async {
    try {
      final hasil = await _api.kirimOrder(
        const Order(
          idPelanggan: 7,
          judul: 'Order pengiriman Bandung - Surabaya',
          keterangan: '3 koli, berat total 42 kg, layanan reguler',
        ),
      );
      final daftar = await _daftarSaatIni();
      daftar.removeWhere((order) => order.id == hasil.id);
      daftar.insert(0, hasil);
      await _simpanPerubahanLokal(daftar);
      _tampilkanPesan('Order terkirim dengan ID ${hasil.id}');
    } on GagalApi catch (e) {
      _tampilkanPesan('Gagal: $e');
    }
  }

  Future<void> _editOrder(Order order) async {
    final judul = TextEditingController(text: order.judul);
    final keterangan = TextEditingController(text: order.keterangan);

    final hasil = await showDialog<Order>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ubah Order #${order.id}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: judul,
                decoration: const InputDecoration(labelText: 'Judul'),
              ),
              TextField(
                controller: keterangan,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Keterangan'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (judul.text.trim().isEmpty) return;
              Navigator.pop(
                context,
                Order(
                  id: order.id,
                  idPelanggan: order.idPelanggan,
                  judul: judul.text.trim(),
                  keterangan: keterangan.text.trim(),
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    judul.dispose();
    keterangan.dispose();

    if (hasil == null) return;
    try {
      await _api.perbaruiOrder(hasil);
      final daftar = await _daftarSaatIni();
      final index = daftar.indexWhere((item) => item.id == hasil.id);
      if (index == -1) {
        daftar.insert(0, hasil);
      } else {
        daftar[index] = hasil;
      }
      await _simpanPerubahanLokal(daftar);
      _tampilkanPesan('Order #${hasil.id} berhasil diperbarui di layanan uji');
    } on GagalApi catch (e) {
      _tampilkanPesan('Gagal memperbarui: $e');
    }
  }

  Future<void> _hapusOrder(Order order) async {
    if (order.id == null) return;

    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus order?'),
        content: Text('Order "${order.judul}" akan dihapus dari layanan uji.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin != true) return;

    try {
      await _api.hapusOrder(order.id!);
      final daftar = await _daftarSaatIni();
      daftar.removeWhere((item) => item.id == order.id);
      await _simpanPerubahanLokal(daftar);
      _tampilkanPesan('Permintaan hapus order #${order.id} berhasil');
    } on GagalApi catch (e) {
      _tampilkanPesan('Gagal menghapus: $e');
    }
  }

  @override
  void dispose() {
    _api.tutup();
    _pencarianController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order dari Layanan Web'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _muatUlang,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _pencarianController,
              decoration: InputDecoration(
                labelText: 'Cari judul order',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Hapus pencarian',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _pencarianController.clear();
                    setState(() => _kataKunci = '');
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _kataKunci = value),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Order>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            size: 56,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _muatUlang,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final semua = snapshot.data ?? <Order>[];
                final data = semua
                    .where(
                      (order) => order.judul.toLowerCase().contains(
                        _kataKunci.trim().toLowerCase(),
                      ),
                    )
                    .toList();

                return Column(
                  children: [
                    if (_pesanPeringatan != null)
                      MaterialBanner(
                        content: Text(_pesanPeringatan!),
                        leading: const Icon(Icons.info_outline),
                        actions: [
                          TextButton(
                            onPressed: _muatUlang,
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Menampilkan ${data.length} dari ${semua.length} order',
                        ),
                      ),
                    ),
                    Expanded(
                      child: data.isEmpty
                          ? const Center(
                              child: Text('Tidak ada order yang cocok'),
                            )
                          : RefreshIndicator(
                              onRefresh: _muatUlang,
                              child: ListView.separated(
                                itemCount: data.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final order = data[index];

                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text('${order.id ?? '-'}'),
                                    ),
                                    title: Text(
                                      order.judul,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      '${order.keterangan}\nPelanggan ${order.idPelanggan}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    isThreeLine: true,
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (aksi) {
                                        if (aksi == 'edit') {
                                          _editOrder(order);
                                        }
                                        if (aksi == 'hapus') {
                                          _hapusOrder(order);
                                        }
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Ubah'),
                                        ),
                                        PopupMenuItem(
                                          value: 'hapus',
                                          child: Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _kirimContoh,
        icon: const Icon(Icons.cloud_upload),
        label: const Text('Kirim Order'),
      ),
    );
  }
}
