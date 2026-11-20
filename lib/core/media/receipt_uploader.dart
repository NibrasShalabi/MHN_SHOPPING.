import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../constants/app_strings.dart';
import '../error/exceptions.dart';
import 'media_config.dart';

/// Sends a payment receipt to the media Worker, which lets a customer write
/// only under receipts/<own uid>/, once per file. Returns the bucket path
/// stored on the order.
class ReceiptUploader {
  /// The Worker's limit for receipts.
  static const int maxBytes = 3 * 1024 * 1024;

  final FirebaseAuth _auth;
  final http.Client _http;

  ReceiptUploader(this._auth, [http.Client? client]) : _http = client ?? http.Client();

  Future<String> upload({required String name, required Uint8List bytes, required String extension}) async {
    final user = _auth.currentUser;
    if (user == null) throw const ServerException(message: AppStrings.signInAgain, code: 'unauthenticated');
    if (bytes.length > maxBytes) throw const ServerException(message: AppStrings.receiptTooLarge);

    final ext = extension.toLowerCase() == 'png' ? 'png' : 'jpg';
    final path = 'receipts/${user.uid}/$name.$ext';
    try {
      final res = await _http.put(
        Uri.parse('${MediaConfig.uploadUrl}/$path'),
        headers: {
          'Authorization': 'Bearer ${await user.getIdToken()}',
          'Content-Type': ext == 'png' ? 'image/png' : 'image/jpeg',
        },
        body: bytes,
      );
      if (res.statusCode >= 300) {
        throw ServerException(
          message: res.statusCode == 413 ? AppStrings.receiptTooLarge : AppStrings.uploadUnavailable,
          code: 'upload-${res.statusCode}',
        );
      }
      return path;
    } on http.ClientException {
      throw const ServerException(message: AppStrings.noInternetConnection, code: 'network-request-failed');
    }
  }
}
