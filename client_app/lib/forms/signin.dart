
import 'package:flutter/material.dart';
import 'package:smarted/cognito.dart';

// Define a custom Form widget.
class SignInForm extends StatefulWidget {

  // Function to call after validate process
  final _onValidate;
  // Function to call after sign-in process
  final _onSignIn;

  SignInForm(this._onValidate, this._onSignIn);

  @override
  SignInFormState createState() {
    return SignInFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class SignInFormState extends State<SignInForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  bool _wrongPassword = false, _userNotConfirmed = false;
  static final Pattern _passwordPattern = "(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}";
  static final RegExp _passwordRegex = new RegExp(_passwordPattern);
  String _username;
  String _password;

  void _signIn() async {
    _wrongPassword = _userNotConfirmed = false;
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      FocusScope.of(context).requestFocus(new FocusNode());

      // Display progress
      Navigator.of(context).push(PageRouteBuilder(
        barrierDismissible: false,
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
                child: CircularProgressIndicator()
            ),
          );
        }
      ));

      // Start sign up call
      SignInResult result = await widget._onValidate(_username, _password);
      switch (result) {
        case SignInResult.ACCOUNT_NOT_CONFIRMED:
          _userNotConfirmed = true;
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Your account is not confirmed yet. Please check your email"),
          ));
          break;
        case SignInResult.WRONG_PASSWORD:
          _wrongPassword = true;
          break;
        case SignInResult.NETWORK_ERROR:
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Network error. Check your internet connection and try again"),
          ));
          break;
        case SignInResult.UNKNOWN_ERROR:
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Unknown error. Please try again later"),
          ));
          break;
        case SignInResult.SUCCESS:
          Navigator.pop(context);
          widget._onSignIn(true);
          return;
      }
      // Dismiss progress
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    _formKey.currentState?.validate();
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: <Widget>[
              TextFormField( // USERNAME OR EMAIL
                  decoration: const InputDecoration(
                    icon: Icon(Icons.perm_identity),
                    labelText: 'Username/Email address',
                  ),
                  validator: (value) {
                    if (_userNotConfirmed) {
                      return "Account not confirmed";
                    }
                    return value.isEmpty || value.contains(" ") ? 'Invalid username' : null;
                  },
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  onSaved: (value) => _username = value,
              ),
              TextFormField( // PASSWORD
                  obscureText: true,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.vpn_key),
                    labelText: 'Password',
                  ),
                  validator: (value) {
                    if (_wrongPassword) {
                      return "Password not correct";
                    }
                    return _passwordRegex.hasMatch(value) ? null : 'Invalid password';
                  },
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  onSaved: (value) => _password = value,
              ),
              Padding (
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: RaisedButton(
                  onPressed: _signIn,
                  child: Text('Sign-in'),
                ),
              )
            ]
          )
        )
      )
    );
  }
}
