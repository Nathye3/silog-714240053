import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/stok.dart';

class FormStokPage extends StatefulWidget {
  final String kodeGudang;

  const FormStokPage({super.key, required this.kodeGudang});

  @override
  State<FormStokPage> createState() => _FormStokPageState();
}

class _FormStokPageState extends State<FormStokPage> {
  final _formKey = GlobalKey<FormState>();

  final _kodeBarangC = TextEditingController();
  final _namaBarangC = TextEditingController();
  final _kodeGudangC = TextEditingController();
  final _jumlahC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _kodeGudangC.text = widget.kodeGudang;
  }

  @override
  void dispose() {
    _kodeBarangC.dispose();
    _namaBarangC.dispose();
    _kodeGudangC.dispose();
    _jumlahC.dispose();
    super.dispose();
  }

  // Validasi wajib diisi
  String? _wajib(String? v, String label) {
    if (v == null || v.trim().isEmpty) {
      return '$label wajib diisi';
    }

    return null;
  }

  // Validasi jumlah stok
  String? _validasiJumlah(String? v) {
    final dasar = _wajib(v, 'Jumlah stok');

    if (dasar != null) return dasar;

    final angka = int.tryParse(v!.trim());

    if (angka == null) {
      return 'Jumlah stok harus berupa angka bulat';
    }

    if (angka <= 0) {
      return 'Jumlah stok harus lebih dari 0';
    }

    return null;
  }

  // Menyimpan data stok
  void _simpan() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final stok = Stok(
      kodeBarang: _kodeBarangC.text.trim().toUpperCase(),
      namaBarang: _namaBarangC.text.trim(),
      kodeGudang: _kodeGudangC.text.trim().toUpperCase(),
      jumlah: int.parse(_jumlahC.text.trim()),
      diperbaruiPada: DateTime.now(),
    );

    Navigator.pop(context, stok);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Stok Barang')),

      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,

        child: ListView(
          padding: const EdgeInsets.all(16),

          children: [
            TextFormField(
              controller: _kodeBarangC,
              decoration: const InputDecoration(
                labelText: 'Kode Barang',
                hintText: 'Contoh: BRG-001',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (v) => _wajib(v, 'Kode barang'),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _namaBarangC,
              decoration: const InputDecoration(
                labelText: 'Nama Barang',
                hintText: 'Contoh: Laptop Asus',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory_2),
              ),
              validator: (v) => _wajib(v, 'Nama barang'),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _kodeGudangC,
              decoration: const InputDecoration(
                labelText: 'Kode Gudang',
                hintText: 'GD-BDG',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.warehouse),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (v) => _wajib(v, 'Kode gudang'),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _jumlahC,
              decoration: const InputDecoration(
                labelText: 'Jumlah Stok',
                hintText: 'Contoh: 25',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validasiJumlah,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,

              child: FilledButton.icon(
                onPressed: _simpan,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Stok'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
