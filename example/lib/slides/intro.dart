import 'package:flutter/material.dart';
import 'package:flutter_slides/flutter_slides.dart';

class IntroSlide extends StatelessWidget {
  Widget build(BuildContext context) {
    return SlideLayout(
      child: Container(
        color: Colors.yellow,
        child: Center(
          child: Column(
            children: [
              FloopGroup(index: 1, child: AppearText('blub')),
              FloopGroup(index: 0, child: AppearText('hey')),
              //WriteText('Advancable'),
              Appear(child: FlutterLogo()),
              Counter(),
            ],
          ),
        ),
      ),
    );
  }
}
