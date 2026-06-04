import 'package:flutter/widgets.dart';

class Provider {
  static T of<T extends ChangeNotifier>(BuildContext context, {bool listen = true}) {
    if (listen) {
      final inheritedWidget = context.dependOnInheritedWidgetOfExactType<_InheritedChangeNotifierProvider<T>>();
      assert(inheritedWidget != null, 'No MyChangeNotifierProvider<$T> found in context');
      return inheritedWidget!.notifier!;
    } else {
      final element = context.getElementForInheritedWidgetOfExactType<_InheritedChangeNotifierProvider<T>>();
      assert(element != null, 'No MyChangeNotifierProvider<$T> found in context');
      final inheritedWidget = element!.widget as _InheritedChangeNotifierProvider<T>;
      return inheritedWidget.notifier!;
    }
  }
}

class ChangeNotifierProvider<T extends ChangeNotifier> extends StatefulWidget {
  final T Function(BuildContext) create;
  final Widget child;

  const ChangeNotifierProvider({
    Key? key,
    required this.create,
    required this.child,
  }) : super(key: key);

  @override
  State<ChangeNotifierProvider<T>> createState() => _ChangeNotifierProviderState<T>();
}

class _ChangeNotifierProviderState<T extends ChangeNotifier> extends State<ChangeNotifierProvider<T>> {
  late T _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.create(context);
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedChangeNotifierProvider<T>(
      notifier: _notifier,
      child: widget.child,
    );
  }
}

class _InheritedChangeNotifierProvider<T extends ChangeNotifier> extends InheritedNotifier<T> {
  const _InheritedChangeNotifierProvider({
    Key? key,
    required T notifier,
    required Widget child,
  }) : super(key: key, notifier: notifier, child: child);
}
