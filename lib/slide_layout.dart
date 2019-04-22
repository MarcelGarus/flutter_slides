import 'package:flutter/widgets.dart';

class SlideLayout extends StatelessWidget {
  SlideLayout({
    Key key,
    this.size,
    @required this.child,
  }) : super(key: key);

  final Size size;
  final Widget child;

  Widget build(BuildContext context) => child;
}
