import 'package:actly/app/actly_controller.dart';
import 'package:flutter/widgets.dart';

class AppScope extends InheritedNotifier<ActlyController> {
  const AppScope({
    required ActlyController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static ActlyController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree.');
    return scope!.notifier!;
  }

  static ActlyController read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AppScope>();
    final scope = element?.widget as AppScope?;
    assert(scope != null, 'AppScope not found in widget tree.');
    return scope!.notifier!;
  }
}
