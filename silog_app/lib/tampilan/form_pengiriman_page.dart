import 'package:flutter/material.dart';

import '../data/data_contoh.dart';
import '../model/barang.dart';
import '../model/gudang.dart';
import '../model/pelanggan.dart';
import '../model/pengiriman.dart';

class FormPengirimanPage extends StatefulWidget {
  const FormPengirimanPage({super.key});

  @override
  State<FormPengirimanPage> createState() => _FormPengirimanPageState();
}

class _FormPengirimanPageState extends State<FormPengirimanPage> {
  final _formKey = GlobalKey<FormState>();
  final _tujuanController = TextEditingController();
  final _jumlahController = TextEditingController();

  late List<Barang> _daftarBarang;

  Gudang? _gudangTerpilih;
  Barang? _barangTerpilih;
  Pelanggan? _pelangganTerpilih;

  @override
  void initState() {
    super.initState();

    _daftarBarang = [];
    final kodeBarang = <String>{};

    // Mengambil barang dari data pengiriman yang sudah tersedia.
    for (final pengiriman in dataPengiriman) {
      if (kodeBarang.add(pengiriman.barang.kode)) {
        _daftarBarang.add(pengiriman.barang);
      }
    }

    _gudangTerpilih = gudangBandung;
    _barangTerpilih = _daftarBarang.isNotEmpty ? _daftarBarang.first : null;
    _pelangganTerpilih = pelanggan1;
  }

  String _buatNomorResi() {
    final tahun = DateTime.now().year;
    var nomorTerbesar = 0;

    for (final pengiriman in dataPengiriman) {
      final bagian = pengiriman.resi.split('-');

      if (bagian.length == 3 && bagian[1] == '$tahun') {
        final nomor = int.tryParse(bagian[2]) ?? 0;
        if (nomor > nomorTerbesar) {
          nomorTerbesar = nomor;
        }
      }
    }

    final nomorBaru = (nomorTerbesar + 1).toString().padLeft(4, '0');
    return 'SLG-$tahun-$nomorBaru';
  }

  void _simpanPengiriman() {
    if (!_formKey.currentState!.validate()) return;

    if (_gudangTerpilih == null ||
        _barangTerpilih == null ||
        _pelangganTerpilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua pilihan terlebih dahulu')),
      );
      return;
    }

    final jumlah = int.parse(_jumlahController.text);

    final pengiriman = Pengiriman.baru(
      resi: _buatNomorResi(),
      asal: _gudangTerpilih!,
      kotaTujuan: _tujuanController.text.trim(),
      barang: _barangTerpilih!,
      jumlah: jumlah,
      pelanggan: _pelangganTerpilih!,
    );

    Navigator.pop(context, pengiriman);
  }

  @override
  void dispose() {
    _tujuanController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengiriman Baru')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Informasi Pengiriman',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Gudang asal
            DropdownButtonFormField<Gudang>(
              initialValue: _gudangTerpilih,
              decoration: const InputDecoration(
                labelText: 'Gudang Asal',
                prefixIcon: Icon(Icons.warehouse_outlined),
                border: OutlineInputBorder(),
              ),
              items: [gudangBandung].map((gudang) {
                return DropdownMenuItem(
                  value: gudang,
                  child: Text('${gudang.nama} - ${gudang.kota}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _gudangTerpilih = value);
              },
              validator: (value) => value == null ? 'Pilih gudang asal' : null,
            ),

            const SizedBox(height: 16),

            // Kota tujuan
            TextFormField(
              controller: _tujuanController,
              decoration: const InputDecoration(
                labelText: 'Kota Tujuan',
                hintText: 'Contoh: Jakarta',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kota tujuan wajib diisi';
                }
                if (value.trim().toLowerCase() ==
                    _gudangTerpilih?.kota.toLowerCase()) {
                  return 'Kota tujuan tidak boleh sama dengan kota asal';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Barang
            DropdownButtonFormField<Barang>(
              initialValue: _barangTerpilih,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Barang',
                prefixIcon: Icon(Icons.inventory_2_outlined),
                border: OutlineInputBorder(),
              ),
              items: _daftarBarang.map((barang) {
                return DropdownMenuItem(
                  value: barang,
                  child: Text(
                    '${barang.nama} (${barang.kode})',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _barangTerpilih = value);
              },
              validator: (value) => value == null ? 'Pilih barang' : null,
            ),

            const SizedBox(height: 16),

            // Jumlah barang
            TextFormField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Barang',
                hintText: 'Masukkan jumlah barang',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Jumlah barang wajib diisi';
                }

                final jumlah = int.tryParse(value);

                if (jumlah == null || jumlah <= 0) {
                  return 'Masukkan jumlah yang valid';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // Pelanggan
            DropdownButtonFormField<Pelanggan>(
              initialValue: _pelangganTerpilih,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Pelanggan',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              items: [pelanggan1, pelanggan2, pelanggan3].map((pelanggan) {
                return DropdownMenuItem(
                  value: pelanggan,
                  child: Text(
                    '${pelanggan.nama} (${pelanggan.kode})',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _pelangganTerpilih = value);
              },
              validator: (value) => value == null ? 'Pilih pelanggan' : null,
            ),

            const SizedBox(height: 24),

            // Ringkasan
            if (_barangTerpilih != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Barang',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Kode: ${_barangTerpilih!.kode}'),
                      Text('Nama: ${_barangTerpilih!.nama}'),
                      Text(
                        'Harga satuan: Rp${_barangTerpilih!.hargaSatuan.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _simpanPengiriman,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Pengiriman'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
