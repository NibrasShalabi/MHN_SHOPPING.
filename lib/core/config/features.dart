/// Switches for features that depend on outside services.
abstract final class Features {
  /// Sham Cash payment proof.
  ///
  /// false (now): the customer types the Sham Cash transaction number — no
  ///   image storage needed, and each number can pay for one order only.
  /// true: the customer uploads a receipt photo instead.
  ///
  /// To switch to receipts once image storage is live (R2, see the media
  /// plan): set this to true and point CheckoutService.uploadReceipt at the
  /// media uploader. Nothing else in the checkout needs to change.
  static const bool receiptUploads = false;
}
