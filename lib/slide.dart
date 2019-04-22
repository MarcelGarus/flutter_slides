import 'package:flutter/widgets.dart';

@immutable
class Slide {
  Slide({
    this.name = '',
    this.size = const Size(null, null),
    @required this.builder,
  })  : assert(name != null),
        assert(size != null),
        assert(builder != null);

  final String name;
  final Size size;
  final Widget Function() builder;
}
