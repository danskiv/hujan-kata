import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Entri leaderboard: nama + skor.
class SkorEntry {
  final String nama;
  final int skor;
  final DateTime waktu;

  const SkorEntry({required this.nama, required this.skor, required this.waktu});

  Map<String, dynamic> toJson() =>
      {'nama': nama, 'skor': skor, 'waktu': waktu.toIso8601String()};

  factory SkorEntry.fromJson(Map<String, dynamic> json) => SkorEntry(
        nama: json['nama'] as String,
        skor: json['skor'] as int,
        waktu: DateTime.parse(json['waktu'] as String),
      );
}

/// Menyimpan & membaca leaderboard lokal (top 10).
class SkorService {
  static const _key = 'leaderboard';

  /// Simpan skor baru, kembalikan daftar top 10 terbaru.
  static Future<List<SkorEntry>> simpanSkor(String nama, int skor) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    final list = <SkorEntry>[];
    if (raw != null) {
      final data = json.decode(raw) as List;
      list.addAll(data.map((e) => SkorEntry.fromJson(e as Map<String, dynamic>)));
    }
    list.add(SkorEntry(nama: nama, skor: skor, waktu: DateTime.now()));
    list.sort((a, b) => b.skor.compareTo(a.skor));
    final top = list.take(10).toList();
    await prefs.setString(
        _key, json.encode(top.map((e) => e.toJson()).toList()));
    return top;
  }

  /// Baca leaderboard saat ini (tanpa menambah).
  static Future<List<SkorEntry>> bacaSkor() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final data = json.decode(raw) as List;
    return data
        .map((e) => SkorEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
