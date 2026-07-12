import 'package:cineflow/data/services/tmdb_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('returns decoded json on 200', () async {
    final api = TmdbApiService(
      client: MockClient((_) async => http.Response('{"page":1}', 200)),
    );

    expect(await api.popularMovies(), {'page': 1});
  });

  test(
    'maps a non-200 response to TmdbException with the status code',
    () async {
      final api = TmdbApiService(
        client: MockClient((_) async => http.Response('nope', 404)),
      );

      await expectLater(
        api.popularMovies(),
        throwsA(
          isA<TmdbException>().having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
    },
  );

  test('maps a timeout to TmdbException(408)', () async {
    final api = TmdbApiService(
      client: MockClient((_) async {
        await Future<void>.delayed(const Duration(seconds: 1));
        return http.Response('{}', 200);
      }),
      timeout: const Duration(milliseconds: 20),
    );

    await expectLater(
      api.popularMovies(),
      throwsA(
        isA<TmdbException>().having((e) => e.statusCode, 'statusCode', 408),
      ),
    );
  });

  test('maps a client/connection error to TmdbException(0)', () async {
    final api = TmdbApiService(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );

    await expectLater(
      api.popularMovies(),
      throwsA(
        isA<TmdbException>().having((e) => e.statusCode, 'statusCode', 0),
      ),
    );
  });

  test('userMessage maps known status codes to friendly text', () {
    expect(const TmdbException(0, '').userMessage, contains('internet'));
    expect(const TmdbException(401, '').userMessage, contains('token'));
    expect(const TmdbException(408, '').userMessage, contains('timed out'));
    expect(const TmdbException(500, '').userMessage, contains('TMDB'));
  });
}
