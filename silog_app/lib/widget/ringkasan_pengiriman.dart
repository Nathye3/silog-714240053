import 'package:flutter/material.dart';
import '../data/data_contoh.dart';

class RingkasanPengiriman extends StatelessWidget {
  const RingkasanPengiriman({super.key});

  @override
  Widget build(BuildContext context) {
    final jumlahPengiriman = dataPengiriman.length;

    final totalNilai = dataPengiriman.fold<double>(
      0,
      (total, item) => total + item.nilaiBarang,
    );

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jumlah Pengiriman',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$jumlahPengiriman',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Nilai Barang',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp${totalNilai.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
