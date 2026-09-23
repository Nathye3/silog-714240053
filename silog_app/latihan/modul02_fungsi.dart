double beratVolumetrik(double p, double l, double t, {double faktor = 6000}) =>
    (p * l * t) / faktor;

double beratTertagih({required double aktual, required double volumetrik}) =>
    aktual > volumetrik ? aktual : volumetrik;

double hitungOngkir({
  required double berat,
  required double tarifPerKg,
  bool asuransi = false,
  double persenAsuransi = 0.005,
  double nilaiBarang = 0,
}) {
  double biaya = berat * tarifPerKg;

  if (asuransi) {
    biaya += nilaiBarang * persenAsuransi;
  }

  return biaya;
}

String rupiah(double nilai) => 'Rp${nilai.toStringAsFixed(0)}';

// Fungsi baru untuk No. 3
String estimasiHariSampai(String kota) {
  switch (kota.toLowerCase()) {
    case 'bandung':
      return '1 hari';
    case 'surabaya':
      return '2 hari';
    case 'makassar':
      return '3 hari';
    case 'jayapura':
      return '5 hari';
    default:
      return 'Estimasi tidak tersedia';
  }
}

void main() {
  final volumetrik = beratVolumetrik(45, 30, 25);

  final tertagih = beratTertagih(aktual: 12.4, volumetrik: volumetrik);

  // No. 2: asuransi diubah menjadi false
  final ongkir = hitungOngkir(
    berat: tertagih,
    tarifPerKg: 8500,
    asuransi: false,
    nilaiBarang: 2500000,
  );

  print('Berat tertagih : ${tertagih.toStringAsFixed(2)} kg');
  print('Ongkos kirim : ${rupiah(ongkir)}');

  // No. 3: menggunakan fungsi estimasiHariSampai
  print('Estimasi sampai Bandung : ${estimasiHariSampai('Bandung')}');
  print('Estimasi sampai Surabaya : ${estimasiHariSampai('Surabaya')}');
  print('Estimasi sampai Makassar : ${estimasiHariSampai('Makassar')}');
  print('Estimasi sampai Jayapura : ${estimasiHariSampai('Jayapura')}');
}
