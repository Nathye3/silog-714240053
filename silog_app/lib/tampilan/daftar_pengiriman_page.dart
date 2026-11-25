import 'package:flutter/material.dart';

import '../data/data_contoh.dart';
import '../data/tema_controller.dart';
import '../model/pengiriman.dart';
import '../widget/kartu_pengiriman.dart';
import '../widget/ringkasan_pengiriman.dart';
import 'detail_pengiriman_page.dart';
import 'form_pengiriman_page.dart';
import 'order_page.dart';

class DaftarPengirimanPage extends StatefulWidget {
  const DaftarPengirimanPage({super.key});

  @override
  State<DaftarPengirimanPage> createState() => _DaftarPengirimanPageState();
}

class _DaftarPengirimanPageState extends State<DaftarPengirimanPage> {
  final _pencarianController = TextEditingController();
  String _kataKunci = '';

  List<Pengiriman> _filter(List<Pengiriman> daftar) {
    final kataKunci = _kataKunci.trim().toLowerCase();
    if (kataKunci.isEmpty) return daftar;
    return daftar.where((item) => [
      item.resi,
      item.barang.nama,
      item.pelanggan.nama,
      item.asal.kota,
      item.kotaTujuan,
      item.status,
    ].any((teks) => teks.toLowerCase().contains(kataKunci))).toList();
  }

  Widget _daftarPengiriman(List<Pengiriman> daftar) {
    final hasil = _filter(daftar);
    if (hasil.isEmpty) {
      return Center(
        child: Text(_kataKunci.isEmpty ? 'Tidak ada pengiriman' : 'Tidak ada hasil yang cocok'),
      );
    }

    return ListView.builder(
      itemCount: hasil.length,
      itemBuilder: (context, index) {
        final item = hasil[index];
        return KartuPengiriman(
          pengiriman: item,
          onTap: () => Navigator.push<void>(
            context,
            MaterialPageRoute(builder: (_) => DetailPengirimanPage(pengiriman: item)),
          ).then((_) { if (mounted) setState(() {}); }),
        );
      },
    );
  }

  Future<void> _tambahPengiriman() async {
    final hasil = await Navigator.push<Pengiriman>(
      context,
      MaterialPageRoute(builder: (_) => const FormPengirimanPage()),
    );
    if (hasil == null || !mounted) return;
    setState(() => dataPengiriman.insert(0, hasil));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pengiriman ${hasil.resi} berhasil ditambahkan')),
    );
  }

  @override
  void dispose() {
    _pencarianController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dalamPerjalanan = dataPengiriman.where((item) => item.status == 'Dalam Perjalanan').toList();
    final diterima = dataPengiriman.where((item) => item.status == 'Diterima').toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Pengiriman'),
          actions: [
            IconButton(
              tooltip: Theme.of(context).brightness == Brightness.dark
                  ? 'Aktifkan mode terang'
                  : 'Aktifkan mode gelap',
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              onPressed: TemaController.toggle,
            ),
            IconButton(
              tooltip: 'Order dari layanan web',
              icon: const Icon(Icons.cloud_outlined),
              onPressed: () => Navigator.push<void>(context, MaterialPageRoute(builder: (_) => const OrderPage())),
            ),
          ],
          bottom: const TabBar(tabs: [
            Tab(text: 'Semua'),
            Tab(text: 'Dalam Perjalanan'),
            Tab(text: 'Diterima'),
          ]),
        ),
        body: Column(
          children: [
            const RingkasanPengiriman(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: TextField(
                controller: _pencarianController,
                decoration: InputDecoration(
                  labelText: 'Cari resi, barang, pelanggan, atau kota',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _kataKunci.isEmpty ? null : IconButton(
                    tooltip: 'Hapus pencarian',
                    icon: const Icon(Icons.clear),
                    onPressed: () { _pencarianController.clear(); setState(() => _kataKunci = ''); },
                  ),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _kataKunci = value),
              ),
            ),
            Expanded(
              child: TabBarView(children: [
                _daftarPengiriman(dataPengiriman),
                _daftarPengiriman(dalamPerjalanan),
                _daftarPengiriman(diterima),
              ]),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _tambahPengiriman,
          icon: const Icon(Icons.add),
          label: const Text('Pengiriman Baru'),
        ),
      ),
    );
  }
}
