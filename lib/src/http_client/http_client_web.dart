import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

// ignore: public_member_api_docs
class HttpClient extends http.BaseClient {
  // ignore: public_member_api_docs
  HttpClient() : _client = BrowserClient()..withCredentials = true;

  final http.BaseClient _client;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Content-Type'] = 'application/xml; charset=utf-8';
    return _client.send(request);
  }
}
