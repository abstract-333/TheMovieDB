import 'package:flutter/material.dart';
import 'package:themoviedb/domain/factories/screen_factory.dart';

abstract class MainNavigationNames {
  static const loaderWidget = '/';
  static const auth = '/auth';
  static const mainScreen = '/main_screen';
  static const movieDetails = '/main_screen/movie_details';
  static const movieTrailerWidget = '/main_screen/movie_details/trailer';
}

class MainNavigation {
  static final _screenFactory = ScreenFactory();
  final routes = <String, Widget Function(BuildContext context)>{
    MainNavigationNames.loaderWidget: (_) => _screenFactory.makeLoader(),
    MainNavigationNames.auth: (_) => _screenFactory.makeAuth(),
    MainNavigationNames.mainScreen: (_) => _screenFactory.makeMainScreen(),
  };
  Route<Object> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MainNavigationNames.movieDetails:
        final arguments = settings.arguments;
        final movieId = arguments is int ? arguments : 0;
        return MaterialPageRoute(
          builder: ((_) => _screenFactory.makeMovieDetails(movieId)),
        );
      case MainNavigationNames.movieTrailerWidget:
        final arguments = settings.arguments;
        final youtubeKey = arguments is String ? arguments : '';
        return MaterialPageRoute(
          builder: ((_) => _screenFactory.makeMovieTrailer(youtubeKey)),
        );

      default:
        const widget = Text('Navigation Error!!!');
        return MaterialPageRoute(builder: ((_) => widget));
    }
  }

  static void resetNavigation(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
        MainNavigationNames.loaderWidget, (route) => false);
  }
}
