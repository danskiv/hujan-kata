import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/kata.dart';

/// Memuat semua kosakata dari assets/data/kosakata.json dengan dukungan filter kategori.
class KosakataService {
  static List<Kategori>? _categoriesCache;

  /// Mengambil semua daftar kategori yang tersedia.
  static Future<List<Kategori>> loadCategories() async {
    if (_categoriesCache != null) return _categoriesCache!;
    final raw = await rootBundle.loadString('assets/data/kosakata.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    final categories = (data['categories'] as List)
        .map((e) => Kategori.fromJson(e as Map<String, dynamic>))
        .toList();
    _categoriesCache = categories;
    return categories;
  }

  /// Mengembalikan kata berdasarkan filter kategori (atau semua kata jika null/'all').
  static Future<List<Kata>> loadKata({String? categoryId}) async {
    final categories = await loadCategories();
    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
      final match = categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => categories.first,
      );
      return List<Kata>.from(match.words);
    }
    final all = <Kata>[];
    for (final c in categories) {
      all.addAll(c.words);
    }
    return all;
  }

  /// Memuat semua kata (campur semua kategori).
  static Future<List<Kata>> loadAll() => loadKata();

  /// Mengacak daftar kata.
  static List<Kata> shuffle(List<Kata> kata) {
    final list = List<Kata>.from(kata);
    list.shuffle();
    return list;
  }
}
