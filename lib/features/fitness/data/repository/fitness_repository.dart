import '../../domain/entities/health_program.dart';

abstract class FitnessRepository {
  Future<List<HealthProgram>> getPrograms();

  Future<HealthProgram> getProgram(String programId);

  /// Submits one program form.
  ///
  /// Takes the answers as a map keyed by field id — the fields are defined
  /// by the admin at runtime. They're stored with each question's text so
  /// the admin reads them as asked, even after the form changes.
  Future<void> submitProgramForm({
    required HealthProgram program,
    required Map<String, dynamic> answers,
  });

  /// The specialist's WhatsApp number (digits with country code), set by
  /// the admin. Empty when not set yet.
  Future<String> getSpecialistWhatsapp();
}
