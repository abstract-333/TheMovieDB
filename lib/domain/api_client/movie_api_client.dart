import 'package:themoviedb/configuration/configuration.dart';
import 'package:themoviedb/domain/api_client/network_client.dart';
import 'package:themoviedb/domain/entity/movie_details.dart';
import 'package:themoviedb/domain/entity/popular_movie_response.dart';

class MovieApiClient {
  final _networkClient = NetworkClient();

  Future<PopularMovieResponse> popularMovie(
      int page, String local, String apiKey) async {
    PopularMovieResponse parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final response = PopularMovieResponse.fromJson(jsonMap);
      return response;
    }

    final result =
        _networkClient.get('/movie/popular', parser, <String, dynamic>{
      'api_key': apiKey,
      'page': page.toString(),
      'language': local,
    });
    return result;
  }

  Future<PopularMovieResponse> searchMovie(
    int page,
    String local,
    String query,
    String apiKey,
  ) async {
    PopularMovieResponse parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final response = PopularMovieResponse.fromJson(jsonMap);
      return response;
    }

    final result =
        _networkClient.get('/search/movie', parser, <String, dynamic>{
      'api_key': apiKey,
      'page': page.toString(),
      'language': local,
      'query': query,
      'include_adult': true.toString(),
    });
    return result;
  }

  Future<MovieDetails> movieDetails(
    int movieId,
    String local,
  ) async {
    MovieDetails parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final response = MovieDetails.fromJson(jsonMap);
      return response;
    }

    final result =
        _networkClient.get('/movie/$movieId', parser, <String, dynamic>{
      'append_to_response': 'credits,videos',
      'api_key': Configuration.apiKey,
      'language': local,
    });
    return result;
  }

  Future<bool> isFavorite(
    int movieId,
    String sessionId,
  ) async {
    bool parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final result = jsonMap['favorite'] as bool;
      return result;
    }

    final result = _networkClient
        .get('/movie/$movieId/account_states', parser, <String, dynamic>{
      'api_key': Configuration.apiKey,
      'session_id': sessionId,
    });
    return result;
  }
}
