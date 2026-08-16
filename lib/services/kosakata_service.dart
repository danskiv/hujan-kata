import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/kata.dart';

/// Memuat semua kosakata dari assets/data/kosakata.json.
class KosakataService {
  static List<Kata>? _cache;

  /// Mengembalikan semua kata (campur semua kategori).
  static Future<List<Kata>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/kosakata.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    final categories = (data['categories'] as List)
        .map((e) => Kategori.fromJson(e as Map<String, dynamic>))
        .toList();
    final all = <Kata>[];
    for (final c in categories) {
      all.addAll(c.words);
    }
    _cache = all;
    return all;
  }

  /// Mengacak daftar kata.
  static List<Kata> shuffle(List<Kata> kata) {
    final list = List<Kata>.from(kata);
    list.shuffle();
    return list;
  }
}
