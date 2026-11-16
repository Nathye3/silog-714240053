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

  List<Stok> _daftar = [];
  String _gudang = 'GD-BDG';
  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() => _memuat = true);

    _gudang = await _pref.ambilGudangTerakhir();

    final data = await _repo.ambilSemua(kodeGudang: _gudang);

    if (!mounted) return;

    setState(() {
      _daftar = data;
      _memuat = false;
    });
  }

  Future<void> _tambahContoh() async {
    await _repo.simpan(
      Stok(
        kodeBarang: 'B-${DateTime.now().millisecondsSinceEpoch % 10000}',
        namaBarang: 'Barang Uji ${_daftar.length + 1}',
        kodeGudang: _gudang,
        jumlah: 25,
        diperbaruiPada: DateTime.now(),
      ),
    );

    await _muat();
  }

  Future<void> _ubahJumlah(Stok stok, int delta) async {
    final baru = stok.jumlah + delta;

    if (baru < 0) return;

    await _repo.perbarui(stok.salinDengan(jumlah: baru));

    await _muat();
  }

  Future<void> _hapus(Stok stok) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus data stok'),
        content: Text('Hapus ${stok.namaBarang} dari gudang $_gudang?'),
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
                  child: Text(
                    'Total stok: $total unit '
                    'dari ${_daftar.length} jenis barang',
                  ),
                ),
                Expanded(
                  child: _daftar.isEmpty
                      ? const Center(child: Text('Belum ada data stok'))
                      : ListView.builder(
                          itemCount: _daftar.length,
                          itemBuilder: (context, i) {
                            final s = _daftar[i];

                            return ListTile(
                              title: Text(s.namaBarang),
                              subtitle: Text(
                                '${s.kodeBarang} - ${s.jumlah} unit',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    onPressed: () => _ubahJumlah(s, -1),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () => _ubahJumlah(s, 1),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _hapus(s),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahContoh,
        child: const Icon(Icons.add),
      ),
    );
  }
}
