import 'package:flutter/widgets.dart';

mixin AdvanceableMixin {
  void advance();
  bool get isCompleted;
}

class _AdvanceableMixinWithIndex {
  _AdvanceableMixinWithIndex(this.advanceable, [this.index]);
  final AdvanceableMixin advanceable;
  final int index;
}

class Advanceable extends StatefulWidget {
  Advanceable({
    Key key,
    this.index,
    @required this.child,
  }) : super(key: key);

  final int index;
  final Widget child;

  @override
  _AdvanceableState createState() => _AdvanceableState();
}

class _AdvanceableState extends State<Advanceable> with AdvanceableMixin {
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) => widget.child;

  AdvanceableMixin _getNextAdvanceableMixin() {
    assert(context != null);

    // This will be all [AdvanceableMixin]s that are in this tree as well as
    // their indexes.
    var advanceables = <_AdvanceableMixinWithIndex>[];

    void visitor(Element element) {
      if (element is StatefulElement && element.state is AdvanceableMixin) {
        // The element's state is an [AdvanceableMixin], so we save it for
        // later. If the widget is an [Advanceable], maybe it also provides an
        // index.
        var widget = element.widget;
        advanceables.add(_AdvanceableMixinWithIndex(
          element.state as AdvanceableMixin,
          (widget is Advanceable) ? widget.index : null,
        ));
      } else {
        // It's just a regular old widget.
        element.visitChildren(visitor);
      }
    }

    // Fill the list of advanceables.
    context.visitChildElements(visitor);

    // We don't care about [Advanceable]s that already completed.
    advanceables.removeWhere((a) => a.advanceable.isCompleted);

    // Advanceables that have an index execute before those that don't have one,
    // so let's move them to the front.
    var indexedAdvanceables = advanceables
        .where((a) => a.index != null)
        .toList()
          ..sort((a, b) => a.index.compareTo(b.index));
    var unindexedAdvanceables = advanceables.where((a) => a.index == null);
    advanceables =
        indexedAdvanceables.followedBy(unindexedAdvanceables).toList();

    return advanceables.isEmpty ? null : advanceables.first.advanceable;
  }

  @override
  bool get isCompleted => _getNextAdvanceableMixin() == null;

  @override
  void advance() {
    var advanceable = _getNextAdvanceableMixin();
    assert(advanceable != null);
    print('The advanceable to continue is $advanceable.');
    advanceable.advance();
  }
}
