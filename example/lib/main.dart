import 'package:flutter/material.dart';
import 'package:flutter_slides/flutter_slides.dart';
import 'slides/intro.dart';

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
        Slide(name: 'intro2', builder: () => IntroSlide()),
        Slide(name: 'intro3', builder: () => IntroSlide()),
        Slide(name: 'intro4', builder: () => IntroSlide()),
        Slide(name: 'intro5', builder: () => IntroSlide()),
        Slide(name: 'intro6', builder: () => IntroSlide()),
        Slide(name: 'intro7', builder: () => IntroSlide()),
      ],
    );
  }
}
