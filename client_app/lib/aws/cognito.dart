import 'dart:convert';

import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
final _userPool = CognitoUserPool(
  _awsUserPoolId,
  _awsClientId,
);

class Cognito {

  static final _instance = Cognito._();
  CognitoUserSession _session;
  CognitoUser _user;

  Cognito._();

  static Cognito getInstance() {
    return _instance;
  }

  String getIDToken() {
    return _session?.getIdToken()?.getJwtToken();
  }

  String getUsername() {
    return _user?.getUsername();
  }

  Future<bool> init() async {
    // Check in shared preferences
    if (_user == null) {
      final prefs = await SharedPreferences.getInstance();
      final storage = _Storage(prefs);
      _userPool.storage = storage;
      _user = await _userPool.getCurrentUser();
      // Still null, not valid sessions
      if (_user == null) {
        return false;
      }
    }
    _session = await _user.getSession();
    return _session.isValid();
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
    _user = CognitoUser(username, _userPool, storage: _userPool.storage);
    _user.setAuthenticationFlowType('USER_PASSWORD_AUTH');
    final authDetails = AuthenticationDetails(
      username: username,
      password: password,
    );
    try {
      _session = await _user.authenticateUser(authDetails);
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
}

class _Storage extends CognitoStorage {
  SharedPreferences _prefs;

  _Storage(this._prefs);

  @override
  Future getItem(String key) async {
    String item;
    try {
      item = json.decode(_prefs.getString(key));
    } catch (e) {
      return null;
    }
    return item;
  }

  @override
  Future setItem(String key, value) async {
    await _prefs.setString(key, json.encode(value));
    return getItem(key);
  }

  @override
  Future removeItem(String key) async {
    final item = getItem(key);
    if (item != null) {
      await _prefs.remove(key);
      return item;
    }
    return null;
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}