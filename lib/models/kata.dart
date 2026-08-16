/// Model kosakata — satu kata dalam game.
class Kata {
  final String en; // nama Bahasa Inggris (jawaban benar)
  final String id; // arti Bahasa Indonesia (petunjuk)
  final String image; // nama aset gambar (tanpa ekstensi)

  const Kata({required this.en, required this.id, required this.image});

  factory Kata.fromJson(Map<String, dynamic> json) => Kata(
        en: json['en'] as String,
        id: json['id'] as String,
        image: json['image'] as String,
      );

  Map<String, dynamic> toJson() => {'en': en, 'id': id, 'image': image};
}

/// Kategori kosakata (Hewan, Buah, ...).
class Kategori {
  final String id;
  final String name;
  final List<Kata> words;

  const Kategori({required this.id, required this.name, required this.words});

  factory Kategori.fromJson(Map<String, dynamic> json) => Kategori(
        id: json['id'] as String,
        name: json['name'] as String,
        words: (json['words'] as List)
            .map((e) => Kata.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
