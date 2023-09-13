import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:themoviedb/Library/Widgets/inherited/localized_model.dart';
import 'package:themoviedb/domain/api_client/api_client_exception.dart';
import 'package:themoviedb/domain/entity/movie_details.dart';
import 'package:themoviedb/domain/services/auth_service.dart';
import 'package:themoviedb/domain/services/movie_service.dart';
import 'package:themoviedb/ui/navigation/main_navigation.dart';

class MovieDetailsPeopleData {
  final String name;
  final String job;
  MovieDetailsPeopleData({
    required this.name,
    required this.job,
  });
}

class MovieDetailsScoreData {
  final String? trailerKey;
  final double voteAverage;
  MovieDetailsScoreData({
    this.trailerKey,
    required this.voteAverage,
  });
}

class MovieDetailNameData {
  final String name;
  final String year;
  MovieDetailNameData({
    required this.name,
    required this.year,
  });
}

class MovieDetailsPosterData {
  final String? backdropPath;
  final String? posterPath;
  final bool isFavorite;

  MovieDetailsPosterData({
    this.backdropPath,
    this.posterPath,
    this.isFavorite = false,
  });

  MovieDetailsPosterData copyWith({
    String? backdropPath,
    String? posterPath,
    bool? isFavorite,
  }) {
    return MovieDetailsPosterData(
      backdropPath: backdropPath ?? this.backdropPath,
      posterPath: posterPath ?? this.posterPath,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class MovieDetailsActorData {
  final String name;
  final String character;
  final String? profilePath;
  MovieDetailsActorData({
    required this.name,
    required this.character,
    this.profilePath,
  });
}

class MovieDetailsData {
  String title = '';
  bool isLoading = true;
  String overview = '';
  MovieDetailsPosterData posterData = MovieDetailsPosterData(isFavorite: false);
  MovieDetailNameData nameData = MovieDetailNameData(name: '', year: '');
  MovieDetailsScoreData scoreData = MovieDetailsScoreData(voteAverage: 0);
  String summary = '';
  List<List<MovieDetailsPeopleData>> peopleData =
      const <List<MovieDetailsPeopleData>>[];
  List<MovieDetailsActorData> actorsData = const <MovieDetailsActorData>[];
}

class MovieDetailsModel extends ChangeNotifier {
  final _autService = AuthService();
  final _movieService = MovieService();

  final int movieId;
  final data = MovieDetailsData();
  final _localeStorage = LocalizedModelStorage();
  late DateFormat _dateFormat;

  MovieDetailsModel({required this.movieId});

  Future<void> setupLocale(BuildContext context, Locale locale) async {
    if (!_localeStorage.updateLocale(locale)) return;
    _dateFormat = DateFormat.yMMMMd(_localeStorage.localeTag);
    updataData(null, false);
    await loadDetails(context);
  }

  void updataData(MovieDetails? details, bool isFavorite) {
    data.title = details?.title ?? 'Loading...';
    data.isLoading = details == null;
    if (details == null) {
      notifyListeners();
      return;
    }
    data.overview = details.overview ?? '';
    data.posterData = MovieDetailsPosterData(
      backdropPath: details.backdropPath,
      posterPath: details.posterPath,
      isFavorite: isFavorite,
    );
    var year = details.releaseDate?.year.toString();
    year = year != null ? ' ($year)' : '';
    data.nameData = MovieDetailNameData(name: details.title, year: year);
    final videos = details.videos.results
        .where((video) => video.site == 'YouTube' && video.type == 'Trailer');
    final trailerKey = videos.isNotEmpty == true ? videos.first.key : null;
    data.scoreData = MovieDetailsScoreData(
      voteAverage: details.voteAverage * 10,
      trailerKey: trailerKey,
    );
    data.summary = makeSummery(details);
    data.peopleData = makePeopleData(details);
    data.actorsData = makeActorsData(details);
    notifyListeners();
  }

  String makeSummery(MovieDetails details) {
    var texts = <String>[];
    final releaseDate = details.releaseDate;
    final productionCountries = details.productionCountries;
    if (releaseDate != null) {
      texts.add(_dateFormat.format(releaseDate));
    }
    if (productionCountries.isNotEmpty) {
      texts.add('(${productionCountries.first.iso})');
    }
    final runtime = details.runtime ?? 0;
    final duration = Duration(minutes: runtime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    texts.add('${hours}h ${minutes}m');
    final genres = details.genres;
    if (genres.isNotEmpty) {
      var genresNames = <String>[];
      for (var genre in genres) {
        genresNames.add(genre.name);
      }
      texts.add(genresNames.join(', '));
    }
    return texts.join(' ');
  }

  List<List<MovieDetailsPeopleData>> makePeopleData(MovieDetails details) {
    var crew = details.credits.crew
        .map((e) => MovieDetailsPeopleData(name: e.name, job: e.job))
        .toList();
    crew = crew.length > 4 ? crew = crew.sublist(0, 4) : crew;
    var crewChunks = <List<MovieDetailsPeopleData>>[];
    for (var i = 0; i < crew.length; i += 2) {
      crewChunks.add(
        crew.sublist(i, i + 2 > crew.length ? crew.length : i + 2),
      );
    }
    return crewChunks;
  }

  List<MovieDetailsActorData> makeActorsData(MovieDetails details) {
    final actorsData = details.credits.cast
        .map((e) => MovieDetailsActorData(
            name: e.name, character: e.character, profilePath: e.profilePath))
        .toList();
    return actorsData;
  }

  Future<void> loadDetails(BuildContext context) async {
    try {
      final details = await _movieService.loadDetails(
        movieId: movieId,
        locale: _localeStorage.localeTag,
      );
      updataData(details.details, details.isFavorite);
    } on ApiClientException catch (e) {
      _handleApiClientException(e, context);
    }
  }

  Future<void> toggleFavorite(BuildContext context,
      [bool mounted = true]) async {
    data.posterData =
        data.posterData.copyWith(isFavorite: !data.posterData.isFavorite);
    notifyListeners();
    try {
      await _movieService.updateFavorite(
          isFavorite: data.posterData.isFavorite, movieId: movieId);
    } on ApiClientException catch (e) {
      if (!mounted) return;
      _handleApiClientException(e, context);
    }
  }

  void _handleApiClientException(
      ApiClientException exception, BuildContext context) {
    switch (exception.type) {
      case ApiClientExceptionType.sessionExpired:
        _autService.logout();
        MainNavigation.resetNavigation(context);
        break;
      default:
    }
  }
}
