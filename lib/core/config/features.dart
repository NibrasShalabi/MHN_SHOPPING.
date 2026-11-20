/// Switches for features that depend on outside services.
abstract final class Features {
  /// Sham Cash payment proof.
  ///
  /// true (now): the customer uploads a receipt photo (R2, through the
  ///   media Worker — see ReceiptUploader).
  /// false: the customer types the Sham Cash transaction number instead —
  ///   the fallback if image uploads are ever down.
  static const bool receiptUploads = true;
}
