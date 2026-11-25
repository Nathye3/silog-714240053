class Order {
  final int? id;
  final int idPelanggan;
  final String judul;
  final String keterangan;

  const Order({
    this.id,
    required this.idPelanggan,
    required this.judul,
    required this.keterangan,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int?,
      idPelanggan: json['userId'] as int? ?? 0,
      judul: json['title'] as String? ?? '(tanpa judul)',
      keterangan: json['body'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': idPelanggan,
    'title': judul,
    'body': keterangan,
  };

  Map<String, dynamic> toMap() => {'id': id, ...toJson()};

  @override
  String toString() => 'Order#$id $judul';
}
