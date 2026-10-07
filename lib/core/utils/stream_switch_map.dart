import 'dart:async';

extension StreamSwitchMap<T> on Stream<T> {
  /// Each event cancels the previous inner stream and starts a new one —
  /// e.g. re-subscribing to Firestore when the signed-in user changes.
  /// (asyncExpand would wait forever on snapshots, which never complete.)
  Stream<R> switchMap<R>(Stream<R> Function(T event) mapper) {
    StreamSubscription<T>? outer;
    StreamSubscription<R>? inner;
    late final StreamController<R> controller;

    controller = StreamController<R>(
      onListen: () => outer = listen((event) {
        inner?.cancel();
        inner = mapper(event).listen(controller.add, onError: controller.addError);
      }, onError: controller.addError),
      onCancel: () async {
        await inner?.cancel();
        await outer?.cancel();
      },
    );
    return controller.stream;
  }
}
