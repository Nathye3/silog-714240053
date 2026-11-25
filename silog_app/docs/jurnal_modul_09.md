# Jurnal Praktikum Modul 09 - Integrasi Layanan Web

> Lengkapi identitas dan tempelkan tangkapan layar asli sebelum mengekspor jurnal ke PDF. Jangan mengisi hasil uji yang belum dilakukan.

## Identitas

| Isian | Nilai |
|---|---|
| Nama | [Isi nama] |
| NIM | [Isi NIM] |
| Kelas | [Isi kelas] |
| Nomor dan judul modul | 09 - Integrasi Layanan Web |
| Tanggal praktikum | [Isi tanggal] |

## Tujuan

1. Mengambil dan menampilkan data order dari layanan web.
2. Mengirim, memperbarui, dan menghapus order melalui HTTP.
3. Menangani respons gagal, koneksi terputus, dan menyediakan aksi coba lagi.
4. Mencari order berdasarkan kata kunci judul pada sisi aplikasi.

## Alat dan versi

| Alat | Versi / keterangan |
|---|---|
| Flutter | 3.14.0 (terlihat di VS Code) |
| Dart | 3.13.0 (terlihat di VS Code) |
| Flutter Web | Chrome |
| Layanan uji | JSONPlaceholder (`https://jsonplaceholder.typicode.com`) |
| Postman | [Isi versi] |

## Langkah kerja

1. Menambahkan paket `http`, `path_provider`, `sembast`, dan `sembast_web` di `pubspec.yaml`, lalu menjalankan `flutter pub get`.
2. Membuat model `Order` untuk mengubah JSON API menjadi objek Dart dan kembali menjadi JSON.
3. Membuat `OrderApi` dengan metode GET, POST, PUT, dan DELETE, batas waktu, serta pesan untuk status HTTP dan kegagalan koneksi.
4. Membuat repository Sembast untuk menyimpan salinan order agar dapat ditampilkan saat koneksi gagal.
5. Menampilkan order pada halaman Flutter, memfilter judul secara lokal, dan menyediakan muat ulang, tambah, ubah, dan hapus.
6. Menjalankan aplikasi dengan `flutter run -d chrome` dari folder `silog_app`.

## Endpoint dan skenario uji

| Skenario | Endpoint | Metode | Contoh badan permintaan | Status yang diharapkan | Perilaku aplikasi |
|---|---|---|---|---|---|
| Ambil 10 order | `/posts?_limit=10` | GET | - | 200 | Menampilkan daftar; menyimpan salinan ke cache lokal. |
| Kirim order | `/posts` | POST | `{"userId":7,"title":"Order Bandung - Surabaya","body":"3 koli, 42 kg, reguler"}` | 201 (JSONPlaceholder) | Menampilkan konfirmasi dan menambahkan hasil ke daftar/cache lokal. |
| Ubah order | `/posts/{id}` | PUT | `{"userId":7,"title":"Order diperbarui","body":"Keterangan terbaru"}` | 200 | Mengganti order pada daftar/cache lokal setelah respons sukses. |
| Hapus order | `/posts/{id}` | DELETE | - | 200 atau 204 | Menghapus order dari daftar/cache lokal setelah respons sukses. |
| URL salah | `/tidak-ada/posts?_limit=10` | GET | - | 404 | Menampilkan pesan data tidak ditemukan; jika ada cache, menampilkan banner data tersimpan. Keduanya menyediakan aksi coba lagi. |
| Koneksi terputus | `/posts?_limit=10` | GET | - | Tidak ada respons HTTP | Menampilkan pesan koneksi gagal; jika cache ada, data tersimpan ditampilkan dengan aksi coba lagi. Tanpa cache, halaman error menyediakan tombol **Coba Lagi**. |

Contoh badan PUT menggunakan nama field API JSONPlaceholder (`userId`, `title`, `body`). Model aplikasi memakai nama `idPelanggan`, `judul`, dan `keterangan`, lalu memetakan keduanya di `Order.toJson()` dan `Order.fromJson()`.

JSONPlaceholder adalah layanan uji: respons POST/PUT/DELETE sukses tidak menyimpan perubahan secara permanen di server. Aplikasi mempertahankan hasil operasi selama data lokal masih digunakan melalui cache.

## Penjelasan program

- `lib/model/order.dart`: model order dan pemetaan JSON.
- `lib/data/order_api.dart`: permintaan HTTP, batas waktu, pemetaan status error, dan alamat API yang dapat diganti melalui `ORDER_API_URL`.
- `lib/data/order_cache_repository.dart`: cache lokal Sembast untuk web dan perangkat.
- `lib/tampilan/order_page.dart`: daftar, pencarian judul pada sisi aplikasi, refresh, POST, PUT, DELETE, tampilan kondisi gagal, dan tombol coba lagi.
- `lib/tampilan/daftar_pengiriman_page.dart`: pintu masuk dari daftar pengiriman ke halaman order layanan web.

## Hasil eksekusi dan analisis

- Daftar 10 order berhasil terlihat pada antarmuka Chrome.
- Pengiriman contoh berhasil mendapat respons dengan ID 101 pada sesi yang ditunjukkan.
- [Catat hasil pengujian PUT dan DELETE beserta ID yang diuji.]
- `flutter pub get` berhasil setelah dependensi ditambahkan.
- `flutter analyze` belum menghasilkan keluaran pada sesi pemeriksaan; jangan menyatakan hasil analisis bersih sebelum menjalankannya kembali dari terminal yang tidak sedang menjalankan proses Dart lain.

## Jawaban tugas praktikum

1. Pencarian judul dilakukan pada daftar hasil GET menggunakan `contains()` dan `toLowerCase()` di aplikasi; setiap perubahan kata kunci langsung memfilter daftar yang sudah dimuat.
2. `perbaruiOrder` mengirim PUT dan mengembalikan model dari respons. `hapusOrder` mengirim DELETE. Keduanya memeriksa status sukses, batas waktu, kegagalan koneksi, dan status HTTP gagal.
3. Tabel endpoint dan perilaku aplikasi tersedia pada bagian **Endpoint dan skenario uji**.

## Bukti yang wajib ditempelkan

Lampirkan tangkapan layar yang memperlihatkan seluruh jendela browser/Postman dan kode/status respons:

1. **Postman GET** - permintaan `GET /posts?_limit=10` dan status respons.
2. **Postman POST** - permintaan `POST /posts`, JSON body, dan status respons.
3. **Antarmuka aplikasi** - daftar order hasil layanan web.
4. **URL salah** - pesan error dan tombol coba lagi.
5. **Koneksi terputus** - pesan error atau banner cache dan tombol coba lagi.
6. **PUT dan DELETE** - bila diminta sebagai bukti tambahan, sertakan request, status, serta daftar setelah perubahan.

## Kesimpulan

[Tuliskan ringkasan hasil, kendala yang ditemui, dan penyelesaiannya setelah seluruh skenario uji selesai.]

## Tautan repositori dan riwayat commit

- Repositori: [Isi tautan repositori]
- Tangkapan layar riwayat commit: [Tempel tangkapan layar]
