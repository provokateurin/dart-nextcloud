import 'dart:io';

import 'package:http/http.dart';
import 'package:nextcloud/src/http_client/http_client.dart';
import 'package:nextcloud/src/network.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

class HttpClientMock extends Mock implements HttpClient {}

void main() {
  group('Network', () {
    final httpClientMock = HttpClientMock();
    final httpRequest = Request('GET', Uri.https('test', ''));
    const authString = 'authString';
    const language = 'language';
    const userAgent = 'dart-nextcloud';

    setUpAll(() {
      when(httpClientMock.send(httpRequest)).thenAnswer(
        (_) async => StreamedResponse(
          Stream.empty(),
          HttpStatus.ok,
        ),
      );
    });

    test('should add defaultHeaders to request', () async {
      final network = NextCloudHttpClient(
        authString,
        language,
        {HttpHeaders.userAgentHeader: userAgent},
        httpClientMock,
      );

      await network.send(httpRequest);

      expect(httpRequest.headers[HttpHeaders.userAgentHeader], userAgent);
    });

    test('should not override library headers', () async {
      final network = NextCloudHttpClient(
        authString,
        language,
        {
          HttpHeaders.authorizationHeader: 'wrong',
        },
        httpClientMock,
      );

      await network.send(httpRequest);

      expect(httpRequest.headers[HttpHeaders.authorizationHeader], authString);
    });

    test('should ignore case-sensitivity of defaultHeader keys', () async {
      const authKey = 'AUTHORIZATION';
      final network = NextCloudHttpClient(
        authString,
        language,
        {
          authKey: 'wrong',
        },
        httpClientMock,
      );

      await network.send(httpRequest);

      expect(httpRequest.headers[HttpHeaders.authorizationHeader], authString);
    });
  });
}
