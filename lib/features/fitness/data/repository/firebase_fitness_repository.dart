import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/dynamic_form_field.dart';
import '../../domain/entities/health_program.dart';
import 'fitness_repository.dart';

/// Firebase implementation لـ FitnessRepository
///
/// Notes:
/// - للإناث فقط — الـ Security Rules بتمنع الذكور server-side
/// - Answers هي health data — تُحفظ في fitnessProfiles/{uid}/{programId}
/// - Programs تُقرأ من Firestore — Admin يعدّلها بدون update للـ app
class FirebaseFitnessRepository implements FitnessRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  // Cache للـ programs — تتغير نادراً
  List<HealthProgram>? _programsCache;

  FirebaseFitnessRepository(this._db, this._auth);

  /// قراءة كل البرامج — مع cache
  @override
  Future<List<HealthProgram>> getPrograms() async {
    if (_programsCache != null) return _programsCache!;

    try {
      final snap = await _db
          .collection('fitnessPrograms')
          .get();

      _programsCache = snap.docs.map(_programFromDoc).toList();
      return _programsCache!;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  /// قراءة برنامج واحد
  @override
  Future<HealthProgram> getProgram(String programId) async {
    // ابحث في الـ cache أولاً
    final cached = _programsCache?.firstWhere(
          (p) => p.id == programId,
      orElse: () => throw const NotFoundException(),
    );
    if (cached != null) return cached;

    try {
      final doc = await _db.collection('fitnessPrograms').doc(programId).get();
      if (!doc.exists) throw const NotFoundException();
      return _programFromDoc(doc);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  /// حفظ إجابات الفورم
  /// المسار: fitnessProfiles/{uid}/{programId}
  /// لا يقرأها أحد إلا المتخصص والمستخدم نفسه (Security Rules)
  @override
  Future<void> submitProgramForm({
    required String programId,
    required Map<String, dynamic> answers,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const ServerException(message: 'غير مسجّل دخول');

    try {
      await _db
          .collection('fitnessProfiles')
          .doc(uid)
          .collection('submissions')
          .add({
        'programId': programId,
        'answers': answers,
        'submittedAt': FieldValue.serverTimestamp(),
      });
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
      fields: (d['fields'] as List<dynamic>? ?? [])
          .map(_fieldFromMap)
          .toList(),
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
      isRequired: m['isRequired'] as bool? ?? true,
      options: List<String>.from(m['options'] as List? ?? []),
      hint: m['hint'] as String?,
    );
  }
}