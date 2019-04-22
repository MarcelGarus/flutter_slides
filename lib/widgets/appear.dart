import 'package:flutter/widgets.dart';

import '../floop.dart';

class Appear extends StatefulWidget {
  Appear({@required this.child});

  final Widget child;

  @override
  _AppearState createState() => _AppearState();
}

class _AppearState extends State<Appear> with Floop, BinaryFloop {
  bool _appeared = false;

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: _appeared ? 1 : 0, child: widget.child);
  }

  @override
  void toggle(val) => setState(() => _appeared = val);
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

class _CounterState extends State<Counter> with Floop {
  int counter = 0;

  Widget build(BuildContext context) {
    return Text('$counter');
  }

  @override
  void next() => setState(() => counter++);

  @override
  void previous() => setState(() => counter--);

  @override
  bool get isAtStart => counter == 0;

  @override
  bool get isAtEnd => counter == 4;
}
