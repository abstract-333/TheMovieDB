import 'package:themoviedb/configuratoin/configuration.dart';
import 'package:themoviedb/domain/api_client/account_api_client.dart';
import 'package:themoviedb/domain/api_client/movie_api_client.dart';
import 'package:themoviedb/domain/data_providers/session_data_provider.dart';
import 'package:themoviedb/domain/entity/popular_movie_response.dart';
import 'package:themoviedb/domain/local_entity/movie_details_local.dart';

class MovieService {
  final _movieApiClient = MovieApiClient();
  final _accountApiClient = AccountApiClient();
  final _sessionDateProvider = SessionDataProvider();

  Future<PopularMovieResponse> popularMovie(int page, String local) async =>
      _movieApiClient.popularMovie(page, local, Configuration.apiKey);

  Future<PopularMovieResponse> searchMovie(
    int page,
    String local,
    String query,
  ) async =>
      _movieApiClient.searchMovie(page, local, query, Configuration.apiKey);

  Future<MovieDetailsLocal> loadDetails(
      {required int movieId, required String locale}) async {
    final movieDetails = await _movieApiClient.movieDetails(movieId, locale);
    final sessionId = await _sessionDateProvider.getSessionId();
    var isFavorite = false;
    if (sessionId != null) {
      isFavorite = await _movieApiClient.isFavorite(movieId, sessionId);
    }
    return MovieDetailsLocal(details: movieDetails, isFavorite: isFavorite);
  }

  Future<void> updateFavorite(
      {required bool isFavorite, required int movieId}) async {
    final accountId = await _sessionDateProvider.getAccountId();
    final sessionId = await _sessionDateProvider.getSessionId();
    if (accountId == null || sessionId == null) return;
    await _accountApiClient.markAsFavorite(
      accountId: accountId,
      sessionId: sessionId,
      mediaType: MediaType.movie,
      mediaId: movieId,
      isFavorite: isFavorite,
    );
  }
}
