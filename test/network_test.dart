import 'dart:io';

import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:nextcloud/src/http_client/http_client.dart';
import 'package:nextcloud/src/network.dart';
import 'package:test/test.dart';

class HttpClientMock extends Mock implements HttpClient {}

void main() {
  group('Network', () {
    final httpClientMock = HttpClientMock();
    final httpRequest = Request('GET', Uri.https('test', ''));
    const authString = 'authString';
    const userAgent = 'dart-nextcloud';

    setUpAll(() {
      when(httpClientMock.send(httpRequest)).thenAnswer(
        (_) async => StreamedResponse(
          const Stream.empty(),
          HttpStatus.ok,
        ),
      );
    });

    setUp(httpRequest.headers.clear);

    test('should add defaultHeaders to request', () async {
      final network = NextCloudHttpClient(
        authString,
        {
          HttpHeaders.userAgentHeader: userAgent,
        },
        httpClientMock,
      );

      await network.send(httpRequest);

      expect(httpRequest.headers[HttpHeaders.userAgentHeader], userAgent);
    });

    test('should not override library headers', () async {
      final network = NextCloudHttpClient(
        authString,
        {
          HttpHeaders.authorizationHeader: 'wrong',
        },
        httpClientMock,
      );

      expect(
        () async => network.send(httpRequest),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should ignore case-sensitivity of defaultHeader keys', () async {
      final authKey = HttpHeaders.userAgentHeader.toUpperCase();
      final network = NextCloudHttpClient(
        authString,
        {
          authKey: 'wrong',
        },
        httpClientMock,
      );

      httpRequest.headers[HttpHeaders.userAgentHeader] = userAgent;

      await network.send(httpRequest);

      //default implementation of map is not case sensitive
      //this test will catch if someone replaces map with a case sensitve map
      expect(httpRequest.headers[authKey], userAgent);
    });
  });
}
