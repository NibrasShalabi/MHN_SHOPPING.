import '../../domain/entities/notifications_entity.dart';

class NotificationsModel extends NotificationsEntity {
  const NotificationsModel() : super();

  // TODO: add fields here (and pass them to super() above) once this model needs data

  factory NotificationsModel.fromJson(Map<String, dynamic> json) {
    return const NotificationsModel();
  }

  Map<String, dynamic> toJson() => {};
}
