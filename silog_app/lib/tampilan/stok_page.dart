import 'package:flutter/material.dart';

import '../data/preferensi.dart';
import '../data/stok_repository.dart';
import '../model/stok.dart';

class StokPage extends StatefulWidget {
  const StokPage({super.key});

  @override
  State<StokPage> createState() => _StokPageState();
}

class _StokPageState extends State<StokPage> {
  final _repo = StokRepository.instance;
  final _pref = Preferensi();

  final _searchController = TextEditingController();

  List<Stok> _daftar = [];

  String _gudang = 'GD-BDG';
  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // MEMUAT DATA
  Future<void> _muat() async {
    setState(() => _memuat = true);

    _gudang = await _pref.ambilGudangTerakhir();

    final data = await _repo.ambilSemua(
      kodeGudang: _gudang,
      kataKunci: _searchController.text,
    );

    if (!mounted) return;

    setState(() {
      _daftar = data;
      _memuat = false;
    });
  }

  // PENCARIAN
  Future<void> _cari(String keyword) async {
    final data = await _repo.ambilSemua(
      kodeGudang: _gudang,
      kataKunci: keyword,
    );

    if (!mounted) return;

    setState(() {
      _daftar = data;
    });
  }

  // FORM TAMBAH STOK
  Future<void> _tambahStok() async {
    final formKey = GlobalKey<FormState>();

    final kodeController = TextEditingController();
    final namaController = TextEditingController();
    final jumlahController = TextEditingController();

    final hasil = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Stok Barang'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: kodeController,
                    decoration: const InputDecoration(
                      labelText: 'Kode Barang',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Kode barang wajib diisi';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Barang',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama barang wajib diisi';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: jumlahController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Stok',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final jumlah = int.tryParse(value ?? '');

                      if (jumlah == null || jumlah <= 0) {
                        return 'Jumlah harus lebih dari 0';
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),

            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (hasil == true) {
      try {
        final stok = Stok(
          kodeBarang: kodeController.text.trim(),
          namaBarang: namaController.text.trim(),
          kodeGudang: _gudang,
          jumlah: int.parse(jumlahController.text),
          diperbaruiPada: DateTime.now(),
        );

        await _repo.simpan(stok);
        await _muat();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stok berhasil ditambahkan')),
          );
        }
      } finally {
        kodeController.dispose();
        namaController.dispose();
        jumlahController.dispose();
      }
    } else {
      kodeController.dispose();
      namaController.dispose();
      jumlahController.dispose();
    }
  }

  // UBAH JUMLAH STOK
  Future<void> _ubahJumlah(Stok stok, int delta) async {
    final baru = stok.jumlah + delta;

    if (baru < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Stok tidak boleh negatif')));
      return;
    }

    await _repo.perbarui(stok.salinDengan(jumlah: baru));

    await _muat();
  }

  // HAPUS STOK
  Future<void> _hapus(Stok stok) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Data Stok'),
          content: Text('Hapus ${stok.namaBarang} dari gudang $_gudang?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (ya == true && stok.id != null) {
      await _repo.hapus(stok.id!);
      await _muat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _daftar.fold<int>(0, (a, s) => a + s.jumlah);

    return Scaffold(
      appBar: AppBar(title: Text('Stok Gudang $_gudang')),

      body: _memuat
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _cari,
                    decoration: InputDecoration(
                      hintText: 'Cari nama barang...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _cari('');
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Total stok: $total unit '
                    'dari ${_daftar.length} jenis barang',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                Expanded(
                  child: _daftar.isEmpty
                      ? const Center(child: Text('Data stok tidak ditemukan'))
                      : ListView.builder(
                          itemCount: _daftar.length,
                          itemBuilder: (context, i) {
                            final s = _daftar[i];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              child: ListTile(
                                title: Text(s.namaBarang),
                                subtitle: Text(
                                  '${s.kodeBarang} - '
                                  '${s.jumlah} unit',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: () {
                                        _ubahJumlah(s, -1);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onPressed: () {
                                        _ubahJumlah(s, 1);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        _hapus(s);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahStok,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Stok'),
      ),
    );
  }
}
