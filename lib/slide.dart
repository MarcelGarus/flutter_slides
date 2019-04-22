import 'package:flutter/material.dart';

import 'floop.dart';

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

  /// Builds the slide content, ready to be displayed in large on the screen as
  /// well as in a small preview. The resulting widget expects tight constraints.
  Widget buildWidget(BuildContext context) {
    assert(context != null);

    // Choose a width and height for the slide. The slide has an inherent [size],
    // but its width and height may be null. If both width and height are set,
    // choose them. If both are null, just pick the screen size. If only one of
    // them is set, try to choose the other so as to retain the screen aspect
    // ratio.
    var screen = MediaQuery.of(context).size;
    assert(screen != null);

    var size = this.size;
    if (size == Size(null, null)) size = screen;

    var aspectRatio = screen.aspectRatio;
    var width = size.width ?? size.height * aspectRatio;
    var height = size.height ?? size.width / aspectRatio;

    assert(width != null);
    assert(height != null);

    return Hero(
      key: Key('${this.hashCode}'),
      tag: this,
      child: Material(
        child: FittedBox(
          child: SizedBox(
            width: width,
            height: height,
            child: RepaintBoundary(child: FloopGroup(child: builder())),
          ),
        ),
      ),
    );
  }
}
