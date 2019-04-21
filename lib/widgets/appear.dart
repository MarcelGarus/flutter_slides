import 'package:flutter/widgets.dart';

import '../advanceable.dart';

class Appear extends StatefulWidget {
  Appear({@required this.child});

  final Widget child;

  @override
  _AppearState createState() => _AppearState();
}

class _AppearState extends State<Appear> with AdvanceableMixin {
  bool _appeared = false;

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: _appeared ? 1 : 0, child: widget.child);
  }

  @override
  void advance() => _appeared = true;

  @override
  bool get isCompleted => _appeared;
}

class AppearText extends StatelessWidget {
  AppearText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Appear(child: Text(text));
}

class Counter extends StatefulWidget {
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter> with AdvanceableMixin {
  int counter = 0;

  Widget build(BuildContext context) {
    return Text('$counter');
  }

  @override
  void advance() => counter++;

  @override
  bool get isCompleted => counter == 4;
}
