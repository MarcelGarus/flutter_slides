import 'package:flutter/material.dart';
import 'package:flutter_slides/flutter_slides.dart';

void main() => runApp(TestPresentation());

class TestPresentation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SlidesApp(
      title: 'Test Presentation',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Signature',
      ),
      slides: [
        Slide(
          name: 'intro slide with a really really really looooong title',
          builder: () => IntroSlide(),
        ),
        Slide(name: 'intro', builder: () => IntroSlide()),
        Slide(name: 'mission', builder: () => MissionSlide()),
        Slide(name: 'old frameworks', builder: () => OldFrameworksSlide()),
        Slide(name: 'intro5', builder: () => IntroSlide()),
        Slide(name: 'intro6', builder: () => IntroSlide()),
        Slide(name: 'intro7', builder: () => IntroSlide()),
      ],
    );
  }
}

class IntroSlide extends StatelessWidget {
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Column(
        children: [
          Appear(child: FlutterLogo(size: 200)),
          AppearText('vorgestellt von Marcel'),
        ],
      ),
    );
  }
}

class MissionSlide extends StatelessWidget {
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      alignment: Alignment.center,
      child: Column(
        children: [
          AppearText('UI Framework von Google'),
          AppearText('"Build the best way to develop for mobile."'),
        ],
      ),
    );
  }
}

class OldFrameworksSlide extends StatelessWidget {
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      alignment: Alignment.center,
      child: Column(
        children: [
          AppearText('Bisherige UI frameworks'),
          Row(
            children: <Widget>[
              Appear(child: Icon(Icons.android)),
              Appear(child: Icon(Icons.polymer)),
              Appear(child: Icon(Icons.iso)),
            ],
          ),
        ],
      ),
    );
  }
}
