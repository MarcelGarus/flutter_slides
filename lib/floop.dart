import 'package:flutter/widgets.dart';

/// A [Floop] is a thing that has several states that are usually executed in a
/// particular order. When a [Floop] is created, [isAtStart] should be true. By
/// calling [next] on the [Floop], it should change its state until finally it
/// (maybe) comes to an end, indicated by [isAtEnd] being true.
/// Also, [previous] may be called on the [Floop], causing it to reverse the
/// state changes.
mixin Floop {
  void next();
  void previous();
  bool get isAtStart;
  bool get isAtEnd;
  bool get isNotAtStart => !isAtStart;
  bool get isNotAtEnd => !isAtEnd;
}

/// A [BinaryFloop] is a [Floop] with just two states. By mixing in
/// [BinaryFloop], classes don't need to implement [next], [previous],
/// [isAtStart] and [isAtEnd], but only [toggle], making the code more concise.
mixin BinaryFloop on Floop {
  bool _didExecute = false;

  void toggle(bool didExecute);

  @override
  void next() {
    assert(!_didExecute);
    toggle(true);
    _didExecute = true;
  }

  @override
  void previous() {
    assert(_didExecute);
    toggle(false);
    _didExecute = false;
  }

  @override
  bool get isAtStart => !_didExecute;

  @override
  bool get isAtEnd => _didExecute;
}

/// A helper class for the implementation of [FloopGroup], see below.
class _FloopWithIndex {
  _FloopWithIndex(this.floop, [this.index]);
  final Floop floop;
  final int index;
}

/// A widget that coordinates [Floop]s that are placed inside of it and is
/// itself a [Floop].
class FloopGroup extends StatefulWidget {
  FloopGroup({
    Key key,
    this.index,
    @required this.child,
  }) : super(key: key);

  final int index;
  final Widget child;

  @override
  _FloopGroupState createState() => _FloopGroupState();
}

class _FloopGroupState extends State<FloopGroup> with Floop {
  bool _floopsAtStart = true;
  bool _floopsAtEnd = false;

  @override
  Widget build(BuildContext context) => widget.child;

  /// Returns [Floop]s that are in this tree in the order they are executed.
  /// Does not return [Floop]s that are inside other [FloopGroup]s.
  List<Floop> _getFloops() {
    assert(context != null);

    var floops = <_FloopWithIndex>[];

    void visitor(Element element) {
      if (element is StatefulElement && element.state is Floop) {
        // The element's state is a [Floop], so we save it for later. If the
        // widget is a [FloopGroup], maybe it also provides an index.
        var widget = element.widget;
        floops.add(_FloopWithIndex(
          element.state as Floop,
          (widget is FloopGroup) ? widget.index : null,
        ));
      } else {
        // It's just a regular old widget.
        element.visitChildren(visitor);
      }
    }

    // Fill the list of [Floop]s.
    context.visitChildElements(visitor);

    // [Floop]s that have an index execute before those that don't have one,
    // so let's move them to the front.
    var indexedFloops = floops.where((a) => a.index != null).toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    var unindexedFloops = floops.where((a) => a.index == null);
    floops = indexedFloops.followedBy(unindexedFloops).toList();

    // We just visited all the children, which is quite resource intensive. To
    // avoid doing this for simple calls to [isAtStart] and [isAtEnd], cache
    // both of these values.
    _floopsAtStart = floops.every((f) => f.floop.isAtStart);
    _floopsAtEnd = floops.every((f) => f.floop.isAtEnd);

    // Return just the [Floop]s without their indexes.
    return floops.map((f) => f.floop).toList();
  }

  @override
  bool get isAtStart => _floopsAtStart;

  @override
  bool get isAtEnd => _floopsAtEnd;

  @override
  void next() {
    var floop = _getFloops()
        .firstWhere((floop) => floop.isNotAtEnd, orElse: () => null);
    assert(floop != null);
    floop.next();
    _getFloops();
  }

  @override
  void previous() {
    var floop = _getFloops()
        .lastWhere((floop) => floop.isNotAtStart, orElse: () => null);
    assert(floop != null);
    floop.previous();
    _getFloops();
  }
}
