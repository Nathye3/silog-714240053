import 'package:flutter/material.dart';

import '../data/preferensi.dart';
import '../data/stok_repository.dart';
import '../data/tema_controller.dart';
import '../model/stok.dart';
import 'form_stok_page.dart';

class StokPage extends StatefulWidget {
  const StokPage({super.key});

  @override
  State<StokPage> createState() => _StokPageState();
}

class _StokPageState extends State<StokPage> {
  final _repo = StokRepository.instance;
  final _pref = Preferensi();

  final _pencarianC = TextEditingController();

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
    _pencarianC.dispose();
    super.dispose();
  }

  // Memuat data stok dari database
  Future<void> _muat() async {
    if (!mounted) return;

    setState(() {
      _memuat = true;
    });

    try {
      _gudang = await _pref.ambilGudangTerakhir();

      final data = await _repo.ambilSemua(
        kodeGudang: _gudang,
        pencarian: _pencarianC.text,
      );

      if (!mounted) return;

      setState(() {
        _daftar = data;
        _memuat = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _memuat = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    }
  }

  // Mencari barang berdasarkan nama
  Future<void> _cariBarang(String keyword) async {
    await _muat();
  }

  // Menambahkan stok melalui formulir
  Future<void> _tambahStok() async {
    final hasil = await Navigator.push<Stok>(
      context,
      MaterialPageRoute(builder: (_) => FormStokPage(kodeGudang: _gudang)),
    );

    if (!mounted) return;

    if (hasil != null) {
      try {
        await _repo.simpan(hasil);

        await _muat();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${hasil.namaBarang} berhasil ditambahkan')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan stok: $e')));
      }
    }
  }

  // Mengubah jumlah stok
  Future<void> _ubahJumlah(Stok stok, int delta) async {
    final baru = stok.jumlah + delta;

    if (baru < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah stok tidak boleh negatif')),
      );
      return;
    }

    try {
      await _repo.perbarui(stok.salinDengan(jumlah: baru));

      await _muat();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengubah stok: $e')));
    }
  }

  // Menghapus data stok
  Future<void> _hapus(Stok stok) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus data stok'),

        content: Text('Hapus ${stok.namaBarang} dari gudang $_gudang?'),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Batal'),
          ),

          FilledButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ya == true && stok.id != null) {
      try {
        await _repo.hapus(stok.id!);

        await _muat();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data stok berhasil dihapus')),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _daftar.fold<int>(0, (a, s) => a + s.jumlah);

    final tema = TemaController.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('Stok Gudang $_gudang'),

        actions: [
          IconButton(
            tooltip: tema.modeGelap
                ? 'Aktifkan mode terang'
                : 'Aktifkan mode gelap',

            icon: Icon(tema.modeGelap ? Icons.light_mode : Icons.dark_mode),

            onPressed: () {
              tema.toggle();
            },
          ),

          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _muat,
          ),
        ],
      ),

      body: Column(
        children: [
          // Kolom pencarian
          Padding(
            padding: const EdgeInsets.all(12),

            child: TextField(
              controller: _pencarianC,

              onChanged: _cariBarang,

              decoration: InputDecoration(
                hintText: 'Cari nama barang...',

                prefixIcon: const Icon(Icons.search),

                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),

                  onPressed: () {
                    _pencarianC.clear();
                    _muat();
                  },
                ),

                border: const OutlineInputBorder(),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Ringkasan stok
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: [
                  Column(
                    children: [
                      const Icon(Icons.inventory_2, size: 28),

                      const SizedBox(height: 6),

                      const Text('Total Unit'),

                      Text(
                        '$total',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      const Icon(Icons.category, size: 28),

                      const SizedBox(height: 6),

                      const Text('Jenis Barang'),

                      Text(
                        '${_daftar.length}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Daftar stok
          Expanded(
            child: _memuat
                ? const Center(child: CircularProgressIndicator())
                : _daftar.isEmpty
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
                            'Kode: ${s.kodeBarang}\n'
                            'Gudang: ${s.kodeGudang}\n'
                            'Jumlah: ${s.jumlah} unit',
                          ),

                          isThreeLine: true,

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              IconButton(
                                tooltip: 'Kurangi stok',
                                icon: const Icon(Icons.remove_circle_outline),

                                onPressed: () {
                                  _ubahJumlah(s, -1);
                                },
                              ),

                              IconButton(
                                tooltip: 'Tambah stok',
                                icon: const Icon(Icons.add_circle_outline),

                                onPressed: () {
                                  _ubahJumlah(s, 1);
                                },
                              ),

                              IconButton(
                                tooltip: 'Hapus stok',
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

      // Tombol tambah stok
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahStok,

        icon: const Icon(Icons.add),

        label: const Text('Tambah Stok'),
      ),
    );
  }
}
