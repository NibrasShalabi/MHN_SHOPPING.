import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/data/rate_limit.dart';
import '../../../account/data/repositories/account_repository.dart';
import '../../domain/entities/dynamic_form_field.dart';
import '../../domain/entities/health_program.dart';
import 'fitness_repository.dart';

/// Fitness is women-only — the security rules enforce it server-side.
/// Answers are health data: stored under the customer
/// (fitnessProfiles/{uid}/submissions), readable by her and the admin only.
class FirebaseFitnessRepository implements FitnessRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final AccountRepository _account;

  // Programs and the specialist number change rarely — one read per session.
  List<HealthProgram>? _programsCache;
  String? _specialistCache;

  FirebaseFitnessRepository(this._db, this._auth, this._account);

  @override
  Future<List<HealthProgram>> getPrograms() async {
    if (_programsCache != null) return _programsCache!;
    try {
      final snap = await _db.collection('fitnessPrograms').get();
      final docs = [...snap.docs]
        ..sort((a, b) => ((a.data()['order'] as num?) ?? 1 << 30).compareTo((b.data()['order'] as num?) ?? 1 << 30));
      return _programsCache = docs.map(_programFromDoc).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  @override
  Future<HealthProgram> getProgram(String programId) async {
    final cached = _programsCache?.where((p) => p.id == programId).firstOrNull;
    if (cached != null) return cached;
    try {
      final doc = await _db.collection('fitnessPrograms').doc(programId).get();
      if (!doc.exists) throw const NotFoundException();
      return _programFromDoc(doc);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  /// Carries who sent it (from her profile) and every question with its
  /// answer, so the admin sees the whole request without another lookup.
  @override
  Future<void> submitProgramForm({
    required HealthProgram program,
    required Map<String, dynamic> answers,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const ServerException(message: AppStrings.notSignedIn);

    try {
      final user = await _account.profile();
      String? text(String v) => v.trim().isEmpty ? null : v.trim();

      final name = user.displayName;
      final batch = _db.batch();
      RateLimit.stamp(_db, batch, uid, RateLimited.fitness);
      batch.set(_db.collection('fitnessProfiles').doc(uid).collection('submissions').doc(), {
        'userId': uid,
        'programId': program.id,
        'programTitle': program.title,
        if (name.isNotEmpty) 'customerName': name,
        'customerPhone': ?text(user.phone),
        'governorate': ?text(user.governorate),
        'answers': [
          for (final f in program.fields) {'id': f.id, 'label': f.label, 'value': _display(answers[f.id])},
        ],
        'status': 'new',
        'submittedAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
      RateLimit.sent(RateLimited.fitness);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  static String _display(dynamic v) => switch (v) {
        null => '',
        bool b => b ? AppStrings.yes : AppStrings.no,
        List l => l.join('، '),
        _ => '$v'.trim(),
      };

  @override
  Future<String> getSpecialistWhatsapp() async {
    if (_specialistCache != null) return _specialistCache!;
    try {
      final doc = await _db.collection('config').doc('fitness').get();
      return _specialistCache = (doc.data()?['specialistWhatsapp'] as String? ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  // ===== Mapper =====

  HealthProgram _programFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return HealthProgram(
      id: doc.id,
      title: d['title'] as String? ?? '',
      intro: d['intro'] as String? ?? '',
      coachWhatsappUrl: d['coachWhatsappUrl'] as String? ?? '',
      suggestedPrograms: List<String>.from(d['suggestedPrograms'] as List? ?? []),
      fields: (d['fields'] as List<dynamic>? ?? []).map(_fieldFromMap).toList(),
    );
  }

  DynamicFormField _fieldFromMap(dynamic map) {
    final m = map as Map<String, dynamic>;
    return DynamicFormField(
      id: m['id'] as String? ?? '',
      label: m['label'] as String? ?? '',
      type: FormFieldType.values.firstWhere(
        (t) => t.name == (m['type'] as String? ?? 'text'),
        orElse: () => FormFieldType.text,
      ),
      // Same default as the dashboard's form builder.
      isRequired: m['isRequired'] as bool? ?? false,
      options: List<String>.from(m['options'] as List? ?? []),
      hint: m['hint'] as String?,
    );
  }
}
