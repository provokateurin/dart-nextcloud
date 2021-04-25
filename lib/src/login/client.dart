import 'dart:convert';
import 'dart:typed_data';

import '../network.dart';

// ignore: public_member_api_docs
class LoginClient {
  // ignore: public_member_api_docs
  LoginClient(
    String baseUrl,
    this._network,
  ) : _baseUrl = '$baseUrl/index.php/login/v2';

  final String _baseUrl;

  final Network _network;

  /// Initiate a login flow
  ///
  /// The login URL returned must be opened in a browser
  /// and then the [pollLogin] method should be used to continuously check
  /// if the user has logged in.
  Future<LoginFlowInit> initLoginFlow() async {
    final response = await _network.send(
      'POST',
      _baseUrl,
      [200],
    );
    final data = json.decode(response.body);
    return LoginFlowInit(
      data['poll']['token'] as String,
      data['poll']['endpoint'] as String,
      data['login'] as String,
    );
  }

  /// Poll the login endpoint
  ///
  /// Errors with 404 until the user has logged in
  Future<LoginFlowResult> pollLogin(LoginFlowInit init) async {
    final response = await _network.send(
      'POST',
      init.endpoint, // Should be the same as '$_baseUrl/poll'
      [200],
      data: Uint8List.fromList(
        utf8.encode(
          json.encode({
            'token': init.token,
          }),
        ),
      ),
    );
    final data = json.decode(response.body);
    return LoginFlowResult(
      data['server'] as String,
      data['loginName'] as String,
      data['appPassword'] as String,
    );
  }
}

// ignore: public_member_api_docs
class LoginFlowInit {
  // ignore: public_member_api_docs
  LoginFlowInit(this.token, this.endpoint, this.login);

  // ignore: public_member_api_docs
  final String token;

  // ignore: public_member_api_docs
  final String endpoint;

  // ignore: public_member_api_docs
  final String login;
}

// ignore: public_member_api_docs
class LoginFlowResult {
  // ignore: public_member_api_docs
  LoginFlowResult(this.server, this.loginName, this.appPassword);

  // ignore: public_member_api_docs
  final String server;

  // ignore: public_member_api_docs
  final String loginName;

  // ignore: public_member_api_docs
  final String appPassword;
}
