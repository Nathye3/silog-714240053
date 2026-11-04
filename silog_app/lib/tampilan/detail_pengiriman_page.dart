import 'package:flutter/material.dart';
import '../model/pengiriman.dart';

class DetailPengirimanPage extends StatelessWidget {
  final Pengiriman pengiriman;

  const DetailPengirimanPage({super.key, required this.pengiriman});

  Widget _baris(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          const Text(': '),
          Expanded(child: Text(nilai)),
        ],
      ),
    );
  }

  Future<void> _konfirmasiHapus(BuildContext context) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Pengiriman?'),
          content: Text(
            'Apakah kamu yakin ingin menghapus pengiriman '
            '${pengiriman.resi}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (konfirmasi == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tgl = pengiriman.tanggalKirim;

    return Scaffold(
      appBar: AppBar(
        title: Text(pengiriman.resi),
        actions: [
          IconButton(
            tooltip: 'Hapus Pengiriman',
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            onPressed: () => _konfirmasiHapus(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Pengiriman',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const Divider(height: 24),

            _baris('Nomor Resi', pengiriman.resi),
            _baris('Status', pengiriman.status),
            _baris('Gudang Asal', pengiriman.asal.nama),
            _baris('Kota Tujuan', pengiriman.kotaTujuan),
            _baris('Tanggal Kirim', '${tgl.day}/${tgl.month}/${tgl.year}'),

            const SizedBox(height: 16),

            Text(
              'Informasi Pelanggan',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const Divider(height: 24),

            _baris('Nama Pelanggan', pengiriman.pelanggan.nama),
            _baris('Kode Pelanggan', pengiriman.pelanggan.kode),
            _baris('Telepon', pengiriman.pelanggan.telepon),
            _baris('Alamat', pengiriman.pelanggan.alamat),

            const SizedBox(height: 16),

            Text(
              'Rincian Barang',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const Divider(height: 24),

            _baris('Kode Barang', pengiriman.barang.kode),
            _baris('Nama Barang', pengiriman.barang.nama),

            _baris(
              'Jumlah',
              '${pengiriman.jumlah} ${pengiriman.barang.satuan}',
            ),

            _baris('Berat Barang', '${pengiriman.barang.beratKg} kg'),

            _baris(
              'Nilai Barang',
              'Rp${pengiriman.nilaiBarang.toStringAsFixed(0)}',
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context, false),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Daftar'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => _konfirmasiHapus(context),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus Pengiriman'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
