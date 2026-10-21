import '../lib/layanan/layanan_pengiriman.dart';
import '../lib/layanan/moda.dart';

void main() {
  final List<LayananPengiriman> daftarLayanan = [
    PengirimanTruk(kodeLayanan: 'TRK-REG', jarakKm: 780, beratKg: 1200),
    PengirimanTruk(
      kodeLayanan: 'TRK-EXP',
      jarakKm: 780,
      beratKg: 1200,
      ekspres: true,
    ),
    PengirimanKeretaApi(
      kodeLayanan: 'KA-CARGO',
      jarakKm: 780,
      beratKg: 1200,
      stasiunAsal: 'Kiaracondong',
      stasiunTujuan: 'Pasar Turi',
    ),
    PengirimanKapal(
      kodeLayanan: 'KPL-PETI',
      jarakKm: 1450,
      beratKg: 1200,
      volumeM3: 8.5,
    ),
    PengirimanUdara(
      kodeLayanan: 'UDR-EXP',
      jarakKm: 1450,
      beratKg: 100,
      panjangCm: 100,
      lebarCm: 80,
      tinggiCm: 60,
      beratAktualKg: 100,
    ),
  ];

  print('=== Perbandingan Layanan Pengiriman ===');

  for (final layanan in daftarLayanan) {
    print(layanan.ringkasan());
  }

  daftarLayanan.sort((a, b) => a.hitungTarif().compareTo(b.hitungTarif()));

  print(
    '\nLayanan termurah: '
    '${daftarLayanan.first.kodeLayanan}',
  );

  final tercepat = daftarLayanan.reduce(
    (a, b) => a.estimasiHari() <= b.estimasiHari() ? a : b,
  );

  print('Layanan tercepat: ${tercepat.kodeLayanan}');

  // Pengujian mixin Terlacak
  final truk = daftarLayanan.whereType<PengirimanTruk>().first;

  truk.catatPosisi('Gudang Utama Bandung');
  truk.catatPosisi('Rest Area KM 207');
  truk.catatPosisi('Gudang Transit Semarang');

  print('\nRiwayat posisi ${truk.kodeLayanan}:');

  for (final r in truk.riwayat) {
    print(' $r');
  }

  print('Posisi terakhir: ${truk.posisiTerakhir()}');

  // Pengujian mixin Terasuransi
  final kapal = daftarLayanan.whereType<PengirimanKapal>().first;

  final udara = daftarLayanan.whereType<PengirimanUdara>().first;

  const nilaiBarang = 10000000.0;

  print('\n=== Pengujian Asuransi ===');

  print(
    'Premi kapal: Rp'
    '${kapal.hitungPremi(nilaiBarang).toStringAsFixed(0)}',
  );

  print(
    'Premi udara: Rp'
    '${udara.hitungPremi(nilaiBarang).toStringAsFixed(0)}',
  );

  // Membuktikan truk tidak menggunakan Terasuransi
  print(
    'Truk menggunakan Terasuransi: '
    '${truk is Terasuransi}',
  );
}
