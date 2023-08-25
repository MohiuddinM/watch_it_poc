import 'package:flutter/widgets.dart';

typedef Selector<R> = dynamic Function(R model);

class ListenerEntry<R extends Listenable> {
  final VoidCallback callback;
  final dynamic selection;

  const ListenerEntry(this.callback, this.selection);
}

class ListenerKey<T extends Listenable> {
  const ListenerKey(this.model, this.code);

  final T model;
  final int code;

  @override
  bool operator ==(Object other) {
    return other is ListenerKey && other.model == model && other.code == code;
  }

  @override
  int get hashCode => Object.hash(model, code);
}

mixin WatchElement on ComponentElement {
  final _listeners = <ListenerKey, ListenerEntry>{};

  void watch<R extends Listenable>(R model, {Selector<R>? selector}) {
    final key = ListenerKey(model, selector.hashCode);

    void callback() {
      if (!mounted) {
        return;
      }

      if (selector == null) {
        unwatch();
        return markNeedsBuild();
      }

      final selection = selector(model);
      final oldSelection = _listeners[key]?.selection;

      assert(selection is! Map || selection is! Set || selection is! List);
      assert(
        oldSelection is! Map || oldSelection is! Set || oldSelection is! List,
      );

      if (selection != oldSelection) {
        unwatch();
        markNeedsBuild();
      }

      _listeners[key] = ListenerEntry(callback, selection);
    }

    final selection = selector?.call(model);
    final entry = ListenerEntry(callback, selection);
    _listeners[key] = entry;
    model.addListener(entry.callback);
  }

  void unwatch<R extends Listenable>() {
    for (final MapEntry(:key, :value) in _listeners.entries) {
      key.model.removeListener(value.callback);
    }

    _listeners.clear();
  }

  @override
  void unmount() {
    unwatch();
    super.unmount();
  }
}

class StatelessWatchElement extends StatelessElement with WatchElement {
  StatelessWatchElement(StatelessWidget widget) : super(widget);
}

class StatefulWatchElement extends StatefulElement with WatchElement {
  StatefulWatchElement(StatefulWidget widget) : super(widget);
}

abstract class WatchingWidget extends StatelessWidget with Watchable {
  const WatchingWidget({Key? key}) : super(key: key);

  @override
  StatelessElement createElement() => StatelessWatchElement(this);
}

abstract class WatchingStatefulWidget extends StatefulWidget with Watchable {
  const WatchingStatefulWidget({Key? key}) : super(key: key);

  @override
  StatefulElement createElement() => StatefulWatchElement(this);
}

mixin Watchable {
  R watch<R extends Listenable>(
    BuildContext context,
    R model, {
    Selector<R>? selector,
  }) {
    if (context is! WatchElement) {
      throw ArgumentError('watch can only be called inside WatchingWidget');
    }

    context.watch(model, selector: selector);
    return model;
  }
}
