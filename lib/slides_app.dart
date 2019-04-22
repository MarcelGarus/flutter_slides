import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'advanceable.dart';
import 'slide.dart';

/// A [SlidesApp] is the root of every presentation.
class SlidesApp extends StatelessWidget {
  /// The slides to display.
  final List<Slide> slides;

  /// Optional navigator observers.
  final List<NavigatorObserver> navigatorObservers;

  /// The title of the presentation.
  final String title;
  final Color color;
  final ThemeData theme;

  SlidesApp({
    Key key,
    this.slides = const [],
    this.navigatorObservers = const [],
    @required this.title,
    this.color,
    this.theme,
  })  : assert(slides != null),
        assert(navigatorObservers != null),
        assert(title != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: navigatorObservers,
      title: title,
      color: color,
      theme: theme,
      home: Scaffold(
        backgroundColor: Colors.yellow[200],
        body: Presenter(title: title, slides: slides),
      ),
    );
  }
}

/// A widget that handles the presenting of the slides.
class Presenter extends StatefulWidget {
  Presenter({
    @required this.title,
    @required this.slides,
  });

  final String title;
  final List<Slide> slides;

  @override
  _PresenterState createState() => _PresenterState();

  /// This method allows subtree widgets to access this presenter.
  static _PresenterState of(BuildContext context) {
    assert(context != null);
    final state = context.ancestorStateOfType(TypeMatcher<Presenter>());
    assert(state != null,
        'There is no Presenter widget above this tree. Make sure you used a SlidesApp');
    return state;
  }
}

class _PresenterState extends State<Presenter> {
  String get _title => widget.title;
  List<Slide> get _slides => widget.slides;
  int _currentIndex;

  @override
  void initState() {
    super.initState();
    _updateIndex();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateIndex();
  }

  void advance() {
    void visitor(Element element) {
      if (element.widget is Advanceable) {
        AdvanceableMixin slide =
            (element as StatefulElement).state as AdvanceableMixin;
        if (slide.isCompleted) {
          setState(() => _currentIndex++);
        } else {
          slide.advance();
        }
      } else {
        // It's just a regular old widget.
        element.visitChildren(visitor);
      }
    }

    context.visitChildElements(visitor);
  }

  void _updateIndex() {
    if (_slides.isEmpty) {
      _currentIndex = null;
    } else {
      _currentIndex ??= 0;
      _currentIndex = _currentIndex.clamp(0, _slides.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Current slide is at index $_currentIndex');
    var slide = _slides[_currentIndex ?? 0];

    return GestureDetector(
      onLongPress: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SlidesPreviewPage(presenter: this),
        ));
      },
      child: _buildSlideContent(context, slide),
    );
  }
}

/// A page that allows for quickly selecting a slide from many previews.
class SlidesPreviewPage extends StatelessWidget {
  SlidesPreviewPage({@required this.presenter});

  final _PresenterState presenter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0),
      body: ListView(
        children: <Widget>[
          _buildTitle(),
          _buildPreviewSlides(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return AppBar(
      title: Text(
        presenter._title,
        style: TextStyle(color: Colors.black),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Widget _buildPreviewSlides() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: LayoutBuilder(builder: (context, constraints) {
        // The default size of the preview slides is 200. So let's see how many
        // of them fit next to each other with a padding of 8 between them.
        var previewsPerRow = ((constraints.maxWidth + 8) / 208.0)
            .clamp(1.0, double.infinity)
            .round();
        var previewWidth = (constraints.maxWidth + 8) / previewsPerRow - 8.0;

        var previews = <Widget>[];
        for (int i = 0; i < presenter._slides.length; i++) {
          previews.add(SizedBox(
            width: previewWidth,
            child: SlidePreview(
              index: i,
              slide: presenter._slides[i],
              isActive: i == presenter._currentIndex,
            ),
          ));
        }

        return Wrap(spacing: 8, runSpacing: 16, children: previews);
      }),
    );
  }
}

/// Builds a small preview for a slide. A small border is painted around the
/// slide to indicate whether the slide is the active slide.
class SlidePreview extends StatelessWidget {
  SlidePreview({
    @required this.index,
    @required this.slide,
    this.isActive = false,
  });

  final int index;
  final Slide slide;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(
              color: isActive ? Theme.of(context).primaryColor : Colors.black12,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: _buildSlideContent(context, slide),
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            slide.name.isEmpty ? '${index + 1}' : '${index + 1}: ${slide.name}',
          ),
        ),
      ],
    );
  }
}

/// Builds the slide content, ready to be displayed in large on the screen as
/// well as in a small preview. The resulting widget expects tight constraints.
Widget _buildSlideContent(BuildContext context, Slide slide) {
  assert(context != null);
  assert(slide != null);

  // Choose a width and height for the slide. The slide has an inherent [size],
  // but its width and height may be null. If both width and height are set,
  // choose them. If both are null, just pick the screen size. If only one of
  // them is set, try to choose the other so as to retain the screen aspect
  // ratio.
  var screen = MediaQuery.of(context).size;
  var size = slide.size;
  assert(screen != null);
  assert(size != null);

  if (size == Size(null, null)) size = screen;
  var aspectRatio = screen.aspectRatio;
  var width = size.width ?? size.height * aspectRatio;
  var height = size.height ?? size.width / aspectRatio;

  assert(width != null);
  assert(height != null);

  return Hero(
    tag: slide,
    child: Material(
      child: FittedBox(
        child: SizedBox(
          width: width,
          height: height,
          child: RepaintBoundary(child: slide.builder()),
        ),
      ),
    ),
  );
}
