import '../lib/model/barang.dart';
import '../lib/model/gudang.dart';
import '../lib/model/pengiriman.dart';
import '../lib/model/pelanggan.dart';

void main() {
  final pelanggan = Pelanggan(
    kode: 'P-001',
    nama: 'Maulana Febrian',
    telepon: '081234567890',
    alamat: 'Jl. Contoh No. 10, Bandung',
  );

  print('=== DATA PELANGGAN ===');
  print(pelanggan);
  print('Alamat ringkas: ${pelanggan.alamatRingkas()}');
  print('');

  final sepatu = Barang(
    kode: 'B-1024',
    nama: 'Sepatu Lari Pria',
    hargaSatuan: 450000,
    beratKg: 0.9,
  );

  final kaos = Barang.dariPemindaian('B-2048;Kaos Katun;85000');

  print('=== DATA BARANG ===');
  print(sepatu);
  print(kaos);
  print('');

  // 4. Membuat objek gudang
  final gudangBandung = Gudang(
    kode: 'GD-BDG',
    nama: 'Gudang Utama Bandung',
    kota: 'Bandung',
    kapasitas: 500,
  );

  // 5. Menerima barang ke gudang
  gudangBandung.terimaBarang(sepatu, 120);
  gudangBandung.terimaBarang(kaos, 300);

  print('=== DATA GUDANG ===');
  print(gudangBandung);
  print('Rincian stok: ${gudangBandung.stok}');
  print('Total stok: ${gudangBandung.totalStok}');
  print('Gudang penuh: ${gudangBandung.penuh}');
  print('');

  // 6. Membuat objek pengiriman dengan data pelanggan
  final kirim = Pengiriman.baru(
    resi: 'SLG-2026-0007',
    asal: gudangBandung,
    kotaTujuan: 'Surabaya',
    barang: sepatu,
    jumlah: 10,
    pelanggan: pelanggan,
  );

  // 7. Mengeluarkan barang sesuai jumlah pengiriman
  gudangBandung.keluarkanBarang(sepatu, kirim.jumlah);

  print('=== DATA PENGIRIMAN ===');
  print(kirim);
  print('Nilai barang: Rp${kirim.nilaiBarang.toStringAsFixed(0)}');
  print('Status awal: ${kirim.status}');
  print('Sisa stok sepatu: ${gudangBandung.stok[sepatu.kode]}');
  print('');

  // 8. Mengubah status pengiriman
  kirim.ubahStatus('Dalam Perjalanan');
  print('Status terbaru: ${kirim.status}');

  // 9. Menguji penolakan perubahan status mundur
  try {
    kirim.ubahStatus('Draft');
  } on StateError catch (e) {
    print('Ditolak: ${e.message}');
  }

  // 10. Menguji penolakan pengeluaran stok berlebihan
  try {
    gudangBandung.keluarkanBarang(sepatu, 9999);
  } on StateError catch (e) {
    print('Ditolak: ${e.message}');
  }
}
