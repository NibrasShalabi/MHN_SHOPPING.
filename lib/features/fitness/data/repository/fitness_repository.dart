import '../../domain/entities/dynamic_form_field.dart';
import '../../domain/entities/health_program.dart';

abstract class FitnessRepository {
  Future<List<HealthProgram>> getPrograms();

  Future<HealthProgram> getProgram(String programId);

  /// Submits one program form.
  ///
  /// Takes the answers as a map keyed by field id rather than a typed
  /// model — the fields are defined by the admin at runtime, so there is
  /// no fixed shape to type against.
  Future<void> submitProgramForm({
    required String programId,
    required Map<String, dynamic> answers,
  });
}

/// UI-phase implementation.
///
/// NOTE(logic-phase): three things must hold server-side, none of which
/// the client can guarantee:
///   1. Female-only access — enforced in the Firestore rule on
///      fitnessProfiles/{uid} and in the submit function, not by the route
///      guard, which only hides the screen.
///   2. Answers are health data. They should be readable by the
///      supervising specialist and the owning user only — no broad admin
///      read, no listing across users.
///   3. Rate limit submissions per user so the collection can't be
///      flooded.
///
/// Supplements are not here: they're ordinary catalog categories scoped to
/// fitness, served by CatalogRepository like everything else.
class FakeFitnessRepository implements FitnessRepository {
  static const _whatsapp = 'https://wa.me/000000000';

  // Shared health questions. Declared once because every program asks
  // them; per-program fields are appended after these.
  static const List<DynamicFormField> _baseHealthFields = [
    DynamicFormField(id: 'age', label: 'العمر', type: FormFieldType.number, hint: 'بالسنوات'),
    DynamicFormField(id: 'height', label: 'الطول', type: FormFieldType.number, hint: 'سم'),
    DynamicFormField(id: 'weight', label: 'الوزن', type: FormFieldType.number, hint: 'كغ'),
    DynamicFormField(
      id: 'chronic',
      label: 'الأمراض المزمنة',
      type: FormFieldType.multiline,
      isRequired: false,
      hint: 'اكتبي لا يوجد إن لم توجد',
    ),
    DynamicFormField(
      id: 'hereditary',
      label: 'الأمراض الوراثية',
      type: FormFieldType.multiline,
      isRequired: false,
    ),
  ];

  static final List<HealthProgram> _programs = [
    HealthProgram(
      id: 'body_management',
      title: 'إدارة الجسم',
      intro: 'تقييم شامل لحالتك الجسدية لاختيار النشاط الأنسب لك.',
      coachWhatsappUrl: _whatsapp,
      suggestedPrograms: const ['yoga', 'pilates'],
      fields: [
        ..._baseHealthFields,
        const DynamicFormField(
          id: 'current_illness',
          label: 'الأمراض الحالية',
          type: FormFieldType.multiline,
          isRequired: false,
        ),
        const DynamicFormField(
          id: 'activity_level',
          label: 'مستوى النشاط الحالي',
          type: FormFieldType.dropdown,
          options: ['قليل', 'متوسط', 'مرتفع'],
        ),
      ],
    ),
    HealthProgram(
      id: 'yoga',
      title: 'يوجا',
      intro: 'تمارين تركّز على المرونة والتنفّس وتخفيف التوتر.',
      coachWhatsappUrl: _whatsapp,
      fields: [
        const DynamicFormField(id: 'name', label: 'الاسم', type: FormFieldType.text),
        ..._baseHealthFields,
        const DynamicFormField(
          id: 'neuro',
          label: 'الأمراض العصبية',
          type: FormFieldType.multiline,
          isRequired: false,
        ),
        const DynamicFormField(
          id: 'muscular',
          label: 'الأمراض العضلية',
          type: FormFieldType.multiline,
          isRequired: false,
        ),
        const DynamicFormField(
          id: 'skeletal',
          label: 'الأمراض العظمية',
          type: FormFieldType.multiline,
          isRequired: false,
        ),
        const DynamicFormField(
          id: 'other_health',
          label: 'معلومات صحية أخرى',
          type: FormFieldType.multiline,
          isRequired: false,
        ),
      ],
    ),
    HealthProgram(
      id: 'pilates',
      title: 'بيلاتس',
      intro: 'تقوية عضلات الجذع وتحسين وضعية الجسم تحت إشراف مختص.',
      coachWhatsappUrl: _whatsapp,
      fields: [
        const DynamicFormField(id: 'name', label: 'الاسم', type: FormFieldType.text),
        ..._baseHealthFields,
        const DynamicFormField(
          id: 'back_pain',
          label: 'هل تعانين من آلام الظهر؟',
          type: FormFieldType.boolean,
          isRequired: false,
        ),
        const DynamicFormField(
          id: 'skeletal',
          label: 'الأمراض العظمية',
          type: FormFieldType.multiline,
          isRequired: false,
        ),
      ],
    ),
    HealthProgram(
      id: 'nutrition',
      title: 'التغذية',
      intro: 'برنامج غذائي يُصمَّم لحالتك من طبيب التغذية المشرف.',
      coachWhatsappUrl: _whatsapp,
      fields: [
        ..._baseHealthFields,
        const DynamicFormField(
          id: 'goal',
          label: 'الهدف',
          type: FormFieldType.dropdown,
          options: ['إنقاص الوزن', 'زيادة الوزن', 'الحفاظ على الوزن', 'تحسين الصحة العامة'],
        ),
        const DynamicFormField(
          id: 'restrictions',
          label: 'حساسية أو أطعمة ممنوعة',
          type: FormFieldType.multiline,
          isRequired: false,
        ),
      ],
    ),
  ];

  @override
  Future<List<HealthProgram>> getPrograms() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return _programs;
  }

  @override
  Future<HealthProgram> getProgram(String programId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _programs.firstWhere((p) => p.id == programId);
  }

  @override
  Future<void> submitProgramForm({
    required String programId,
    required Map<String, dynamic> answers,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }
}