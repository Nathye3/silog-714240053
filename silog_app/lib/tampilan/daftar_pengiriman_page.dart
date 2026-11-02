import 'package:flutter/material.dart';

import '../data/data_contoh.dart';
import '../model/pengiriman.dart';
import '../widget/kartu_pengiriman.dart';
import '../widget/ringkasan_pengiriman.dart';
import 'detail_pengiriman_page.dart';

class DaftarPengirimanPage extends StatelessWidget {
  const DaftarPengirimanPage({super.key});

  Widget _daftarPengiriman(List<Pengiriman> daftar) {
    if (daftar.isEmpty) {
      return const Center(child: Text('Tidak ada pengiriman'));
    }

    return ListView.builder(
      itemCount: daftar.length,
      itemBuilder: (context, index) {
        final item = daftar[index];

        return KartuPengiriman(
          pengiriman: item,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailPengirimanPage(pengiriman: item),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dalamPerjalanan = dataPengiriman
        .where((item) => item.status == 'Dalam Perjalanan')
        .toList();

    final diterima = dataPengiriman
        .where((item) => item.status == 'Diterima')
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Pengiriman'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
              tooltip: 'Cari resi',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Dalam Perjalanan'),
              Tab(text: 'Diterima'),
            ],
          ),
        ),

        body: Column(
          children: [
            const RingkasanPengiriman(),

            Expanded(
              child: TabBarView(
                children: [
                  _daftarPengiriman(dataPengiriman),
                  _daftarPengiriman(dalamPerjalanan),
                  _daftarPengiriman(diterima),
                ],
              ),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Pengiriman Baru'),
        ),
      ),
    );
  }
}
