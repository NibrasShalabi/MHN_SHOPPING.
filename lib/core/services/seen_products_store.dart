/// Tracks which "new" products the user has already seen, so the جديد badge
/// shows once and then stops following them around.
///
/// The admin marks a product as new; this store decides whether the badge
/// is still worth rendering for THIS user. Kept behind an interface so the
/// UI phase can run purely in memory and the logic phase can swap in a
/// SharedPreferences/Firestore-backed implementation without touching any
/// widget.
abstract class SeenProductsStore {
  bool hasSeen(String productId);

  Future<void> markSeen(String productId);
}

/// UI-phase implementation — resets on app restart, which is fine while
/// there is no persistence layer yet.
class InMemorySeenProductsStore implements SeenProductsStore {
  final Set<String> _seen = {};

  @override
  bool hasSeen(String productId) => _seen.contains(productId);

  @override
  Future<void> markSeen(String productId) async {
    _seen.add(productId);
  }
}