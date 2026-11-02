import '../model/barang.dart';
import '../model/gudang.dart';
import '../model/pelanggan.dart';
import '../model/pengiriman.dart';

final gudangBandung = Gudang(
  kode: 'GD-BDG',
  nama: 'Gudang Utama Bandung',
  kota: 'Bandung',
);

final pelanggan1 = Pelanggan(
  kode: 'PL-001',
  nama: 'Andi Pratama',
  telepon: '081234567890',
  alamat: 'Jl. Asia Afrika No. 10, Bandung',
);

final pelanggan2 = Pelanggan(
  kode: 'PL-002',
  nama: 'Budi Santoso',
  telepon: '081298765432',
  alamat: 'Jl. Sudirman No. 25, Makassar',
);

final pelanggan3 = Pelanggan(
  kode: 'PL-003',
  nama: 'Citra Amelia',
  telepon: '085712345678',
  alamat: 'Jl. Gatot Subroto No. 15, Medan',
);

final List<Pengiriman> dataPengiriman = [
  Pengiriman(
    resi: 'SLG-2026-0001',
    asal: gudangBandung,
    kotaTujuan: 'Surabaya',
    barang: Barang(
      kode: 'B-1024',
      nama: 'Sepatu Lari Pria',
      hargaSatuan: 450000,
    ),
    pelanggan: pelanggan1,
    jumlah: 10,
    tanggalKirim: DateTime(2026, 9, 8),
    status: 'Dalam Perjalanan',
  ),

  Pengiriman(
    resi: 'SLG-2026-0002',
    asal: gudangBandung,
    kotaTujuan: 'Makassar',
    barang: Barang(kode: 'B-2048', nama: 'Kaos Katun', hargaSatuan: 85000),
    pelanggan: pelanggan2,
    jumlah: 120,
    tanggalKirim: DateTime(2026, 9, 9),
    status: 'Menunggu Pickup',
  ),

  Pengiriman(
    resi: 'SLG-2026-0003',
    asal: gudangBandung,
    kotaTujuan: 'Medan',
    barang: Barang(kode: 'B-3072', nama: 'Tas Ransel', hargaSatuan: 275000),
    pelanggan: pelanggan3,
    jumlah: 35,
    tanggalKirim: DateTime(2026, 9, 10),
    status: 'Diterima',
  ),
];
