import 'package:flutter/material.dart';

import 'package:flutter_slides/advanceable.dart';
import 'package:flutter_slides/widgets/appear.dart';

void main() => runApp(Presentation());

class Presentation extends StatefulWidget {
  @override
  _PresentationState createState() => _PresentationState();
}

class _PresentationState extends State<Presentation> {
  void _advance() {
    void visitor(Element element) {
      if (element.widget is Advanceable) {
        ((element as StatefulElement).state as AdvanceableMixin).advance();
      } else {
        element.visitChildren(visitor);
      }
    }

    context.visitChildElements(visitor);
  }

  Widget build(BuildContext context) {
    /*return SlidesApp(
      title: 'Test',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Signature',
      ),
      initialSlide: 'intro',
      slides: {
        'intro': () => IntroSlide(),
      },
    );*/

    return MaterialApp(
      title: 'Theme',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: Scaffold(
        body: Column(
          children: <Widget>[
            InkWell(
              onTap: _advance,
              splashColor: Colors.green,
              child: SizedBox(height: 100),
            ),
            Expanded(child: IntroSlide()),
          ],
        ),
      ),
    );
  }
}

class IntroSlide extends StatelessWidget {
  Widget build(_) {
    return Advanceable(
      child: Center(
        child: Column(
          children: [
            AppearText('blub'),
            AppearText('hey'),
            //WriteText('Advancable'),
            Appear(child: FlutterLogo()),
          ],
        ),
      ),
    );
  }
}
