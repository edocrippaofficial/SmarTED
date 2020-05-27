import 'dart:convert';

import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:http/http.dart' as http;

enum SignUpResult {
  USERNAME_EXISTS,
  NETWORK_ERROR,
  UNKNOWN_ERROR,
  SUCCESS
}

enum SignInResult {
  ACCOUNT_NOT_CONFIRMED,
  WRONG_PASSWORD,
  NETWORK_ERROR,
  UNKNOWN_ERROR,
  SUCCESS
}

const _awsUserPoolId = 'us-east-1_Pt6pZrFVJ';
const _awsClientId = '191a3inh64tu4mqhjja3cv9mcp';
final _userPool = new CognitoUserPool(
  _awsUserPoolId,
  _awsClientId,
);

class Cognito {

  CognitoUserSession _session;
  CognitoUser _user;

  bool isAuthenticated() {
    return _session?.isValid() ?? false;
  }

  Future<void> signOut() async {
    return _user?.signOut();
  }

  Future<SignUpResult> signUp(String name, String surname, String username, String email, String password) async {
    try {
      await _userPool.signUp(
        username,
        password,
        userAttributes: [
          new AttributeArg(name: 'email', value: email),
          new AttributeArg(name: 'name', value: name),
          new AttributeArg(name: 'family_name', value: surname),
        ]
      );
    } catch (e) {
      switch (e.code) {
        case "NetworkError":
          return SignUpResult.NETWORK_ERROR;
        case "UsernameExistsException":
          return SignUpResult.USERNAME_EXISTS;
        default:
          return SignUpResult.UNKNOWN_ERROR;
      }
    }
    return SignUpResult.SUCCESS;
  }

  Future<SignInResult> signIn(String username, String password) async {
    _user = new CognitoUser(username, _userPool);
    _user.setAuthenticationFlowType('USER_PASSWORD_AUTH');
    final authDetails = new AuthenticationDetails(
      username: username,
      password: password,
    );
    try {
      _session = await _user.authenticateUser(authDetails);
      print(_session);
    } on CognitoClientException catch (e) {
      switch (e.code) {
        case "NetworkError":
          return SignInResult.NETWORK_ERROR;
        case "UserNotConfirmedException":
          return SignInResult.ACCOUNT_NOT_CONFIRMED;
        case "NotAuthorizedException":
          return SignInResult.WRONG_PASSWORD;
        default:
          return SignInResult.UNKNOWN_ERROR;
      }
    } on CognitoUserConfirmationNecessaryException {
      return SignInResult.ACCOUNT_NOT_CONFIRMED;
    } catch (e) {
      return SignInResult.UNKNOWN_ERROR;
    }
    return SignInResult.SUCCESS;
  }

  Future<String> getTalksByTag(bool token) async {
    const endpoint = 'https://l85hlnhue2.execute-api.us-east-1.amazonaws.com/default';
    const path = '/GetFollowers';
    Map headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': token ? _session.getIdToken().getJwtToken() : '',
    };
    String body = jsonEncode(<String, Object>{
      'username': 'edocrippaofficial',
      'doc_per_page': 2,
      'page': 1
    });
    try {
      http.Response response = await http.post(
        endpoint + path,
        headers: headers,
        body: body,
      );
      return response.body;
    } catch (e) {
      print(e);
      return null;
    }
  }
}