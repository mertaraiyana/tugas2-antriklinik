import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client, this.timeout = const Duration(seconds: 10)})
      : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  Future<Map<String, dynamic>> getJson(Uri uri) async {
    try {
      final res = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(timeout);
      if (res.statusCode >= 400 && res.statusCode < 500) {
        throw ApiException(
          ApiErrorKind.badRequest,
          'Permintaan tidak valid (${res.statusCode}).',
        );
      }
      if (res.statusCode >= 500) {
        throw ApiException(
          ApiErrorKind.serverError,
          'Server klinik sedang sibuk (${res.statusCode}).',
        );
      }
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } on TimeoutException {
      throw const ApiException(
        ApiErrorKind.timeout,
        'Koneksi habis waktu. Coba lagi.',
      );
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException(
        ApiErrorKind.invalidData,
        'Format data dari server tidak sesuai.',
      );
    } catch (_) {
      throw const ApiException(
        ApiErrorKind.noConnection,
        'Tidak ada koneksi internet. Periksa jaringan Anda.',
      );
    }
  }

  Future<Map<String, dynamic>> postJson(
    Uri uri,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(body),
          )
          .timeout(timeout);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ApiException(
          ApiErrorKind.serverError,
          'Gagal mengirim antrean (${res.statusCode}).',
        );
      }
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } on TimeoutException {
      throw const ApiException(
        ApiErrorKind.timeout,
        'Waktu habis saat mengambil nomor antrean.',
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        ApiErrorKind.noConnection,
        'Gagal terhubung ke server antrean.',
      );
    }
  }
}
