class ResiTidakDitemukan implements Exception {
  final String resi;

  ResiTidakDitemukan(this.resi);

  @override
  String toString() => 'Resi $resi tidak ditemukan pada basis data.';
}

// ======================================================
// LATIHAN 3: Future, async, dan await
// ======================================================

Future<String> ambilStatusKiriman(String resi) async {
  // Simulasi jeda jaringan selama 2 detik
  await Future.delayed(const Duration(seconds: 2));

  // Data minimal 5 resi untuk Tugas Praktikum
  final dataKiriman = {
    'SLG-001': 'Bandung',
    'SLG-002': 'Surabaya',
    'SLG-003': 'Jakarta',
    'SLG-004': 'Yogyakarta',
    'SLG-005': 'Semarang',
  };

  final kota = dataKiriman[resi];

  // Jika resi tidak ditemukan
  if (kota == null) {
    throw ResiTidakDitemukan(resi);
  }

  return 'Paket $resi sedang dalam perjalanan menuju $kota.';
}

// Fungsi mengambil ongkos kirim
Future<double> ambilOngkir(String resi) async {
  await Future.delayed(const Duration(seconds: 1));

  return 105400;
}

// ======================================================
// LATIHAN 4: Future.wait
// ======================================================

Future<void> bandingkanWaktu() async {
  final mulai = DateTime.now();

  final hasil = await Future.wait([
    ambilStatusKiriman('SLG-001'),
    ambilOngkir('SLG-001'),
  ]);

  final durasi = DateTime.now().difference(mulai);

  print('Status : ${hasil[0]}');
  print('Ongkir : ${hasil[1]}');
  print('Durasi total: ${durasi.inMilliseconds} ms');
}

// ======================================================
// TUGAS PRAKTIKUM
// Memantau banyak resi secara bersamaan
// ======================================================

Future<void> pantauBanyakResi(List<String> daftarResi) async {
  final hasil = await Future.wait(
    daftarResi.map((resi) async {
      try {
        final status = await ambilStatusKiriman(resi);

        return '$resi -> BERHASIL: $status';
      } on ResiTidakDitemukan catch (e) {
        return '$resi -> GAGAL: $e';
      } catch (e) {
        return '$resi -> GAGAL: $e';
      }
    }),
  );

  for (final hasilResi in hasil) {
    print(hasilResi);
  }
}

// ======================================================
// MAIN PROGRAM
// ======================================================

Future<void> main() async {
  // ----------------------------------------------------
  // LATIHAN 3: async dan await
  // ----------------------------------------------------

  print('1. Permintaan data dikirim...');

  try {
    final status = await ambilStatusKiriman('SLG-002');

    print('2. $status');

    final ongkir = await ambilOngkir('SLG-002');

    print('3. Ongkos kirim: Rp${ongkir.toStringAsFixed(0)}');
  } on FormatException catch (e) {
    print('Kesalahan format: ${e.message}');
  } catch (e) {
    print('Gagal mengambil data: $e');
  }

  print('4. Proses selesai.');

  // ----------------------------------------------------
  // LATIHAN 4: Future.wait
  // ----------------------------------------------------

  print('\n=== PERBANDINGAN FUTURE.WAIT ===');

  await bandingkanWaktu();

  // ----------------------------------------------------
  // TUGAS PRAKTIKUM
  // SKENARIO 1: SEMUA RESI VALID
  // ----------------------------------------------------

  print('\n=== SEMUA RESI VALID ===');

  await pantauBanyakResi([
    'SLG-001',
    'SLG-002',
    'SLG-003',
    'SLG-004',
    'SLG-005',
  ]);

  // ----------------------------------------------------
  // TUGAS PRAKTIKUM
  // SKENARIO 2: TERDAPAT RESI TIDAK VALID
  // ----------------------------------------------------

  print('\n=== TERDAPAT RESI TIDAK VALID ===');

  await pantauBanyakResi([
    'SLG-001',
    'SLG-002',
    'SLG-999',
    'SLG-004',
    'SLG-005',
  ]);

  print('\n=== SEMUA PROSES SELESAI ===');
}
