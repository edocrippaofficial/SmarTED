import 'package:amazon_cognito_identity_dart_2/cognito.dart';

enum SignUpResult {
  USERNAME_ALREADY_IN_USE,
  NETWORK_ERROR,
  SUCCESS
}

const _awsUserPoolId = 'us-east-1_Pt6pZrFVJ';
const _awsClientId = '191a3inh64tu4mqhjja3cv9mcp';
final _userPool = new CognitoUserPool(
    _awsUserPoolId,
    _awsClientId
);

class Cognito {

  Future<SignUpResult> signUp(String name, String surname, String userName, String email, String password) async {
    try {
      var data = await _userPool.signUp(
        userName,
        password,
        userAttributes: [
          new AttributeArg(name: 'email', value: email),
          new AttributeArg(name: 'name', value: name),
          new AttributeArg(name: 'family_name', value: surname),
        ]
      );
      print(data);
    } catch (e) {
      print(e);
      return SignUpResult.NETWORK_ERROR;
    }
    return SignUpResult.SUCCESS;
  }
}