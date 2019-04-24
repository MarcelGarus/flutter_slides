import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'floop.dart';
import 'slide.dart';

/// Returns the next [FloopGroup] below the context. Assumes there is only one.
Floop _getFloopGroup(BuildContext context) {
  Floop result;

  void visitor(Element element) {
    if (element.widget is FloopGroup)
      result = (element as StatefulElement).state as Floop;
    else
      element.visitChildren(visitor);
  }

  context.visitChildElements(visitor);
  return result;
}

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
      debugShowCheckedModeBanner: false,
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

  void next() {
    var slide = _getFloopGroup(context);
    if (slide.isAtEnd)
      setState(() => _currentIndex++);
    else
      slide.next();
  }

  void previous() {
    var slide = _getFloopGroup(context);
    if (slide.isAtStart) {
      // We go to the previous slide. Because it should seem like the slide was
      // already clicked through, spam it with [next] calls until it's at the
      // end.
      setState(() => _currentIndex--);
      Future.delayed(Duration.zero, () {
        var slide = _getFloopGroup(context);
        while (slide.isNotAtEnd) slide.next();
      });
    } else
      slide.previous();
  }

  void _updateIndex() {
    if (_slides.isEmpty) {
      _currentIndex = null;
    } else {
      _currentIndex ??= 0;
      _currentIndex = _currentIndex.clamp(0, _slides.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_slides.isEmpty) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Text(
          'Add slides, please!',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    print('Current slide is at index $_currentIndex');
    var slide = _slides[_currentIndex];

    return WillPopScope(
      onWillPop: () async {
        previous();
        return false;
      },
      child: GestureDetector(
        onTap: next,
        onHorizontalDragStart: (_) {},
        onHorizontalDragUpdate: (_) {},
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity < -100) previous();
        },
        onLongPress: () {
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) => _SlidesPreviewPage(presenter: this),
            transitionsBuilder: (_, __, ___, child) => child,
          ));
        },
        child: slide.buildWidget(context),
      ),
    );
  }
}

/// A page that allows for quickly selecting a slide from many previews.
class _SlidesPreviewPage extends StatelessWidget {
  _SlidesPreviewPage({@required this.presenter});

  final _PresenterState presenter;

  @override
  Widget build(BuildContext context) {
    var content = <Widget>[];
    content.add(_buildTitle(context));
    assert(() {
      content.add(_buildDebugWarning());
      content.add(SizedBox(height: 16));
      return true;
    }());
    content.add(_buildPreviewSlides());

    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0),
      body: ListView(
        padding: MediaQuery.of(context).padding + EdgeInsets.all(16),
        children: content,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        presenter._title,
        style: Theme.of(context)
            .textTheme
            .headline
            .copyWith(fontWeight: FontWeight.bold, fontSize: 32),
      ),
    );
  }

  Widget _buildDebugWarning() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        border: Border.all(color: Colors.black12, width: 2),
      ),
      padding: const EdgeInsets.all(16),
      child: Text("You're currently running in debug mode. To get the best "
          "performance, remember to build the presentation in release mode once "
          "you're done."),
    );
  }

  Widget _buildPreviewSlides() {
    return Center(
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
            child: _SlidePreview(
              index: i,
              slide: presenter._slides[i],
              isActive: i == presenter._currentIndex,
              onPressed: () {
                presenter._currentIndex = i;
                Navigator.of(context).pop();
              },
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
class _SlidePreview extends StatefulWidget {
  _SlidePreview({
    @required this.index,
    @required this.slide,
    this.isActive = false,
    this.onPressed,
  });

  final int index;
  final Slide slide;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  _SlidePreviewState createState() => _SlidePreviewState();
}

class _SlidePreviewState extends State<_SlidePreview> {
  @override
  Widget build(BuildContext context) {
    // In the small preview slide, the slide should display everything, just
    // like it was already clicked through. Sadly, there's no more elegant way
    // to achieve that than spamming [next] on the slide floop until it's at the
    // end.
    Future.delayed(Duration.zero, () {
      var floop = _getFloopGroup(context);
      while (floop.isNotAtEnd) floop.next();
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.isActive
                    ? Theme.of(context).primaryColor
                    : Colors.black12,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: widget.slide.buildWidget(context),
            ),
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            widget.slide.name.isEmpty
                ? '${widget.index + 1}'
                : '${widget.index + 1}: ${widget.slide.name}',
          ),
        ),
      ],
    );
  }
}
