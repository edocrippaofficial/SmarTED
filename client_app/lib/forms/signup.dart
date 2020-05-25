
import 'package:flutter/material.dart';

import '../cognito.dart';

// Define a custom Form widget.
class SignUpForm extends StatefulWidget {

  // Function to call after validate process
  final _onValidate;
  // Function to call after sign-up process
  final _onSignUp;

  SignUpForm(this._onValidate, this._onSignUp);

  @override
  SignUpFormState createState() {
    return SignUpFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class SignUpFormState extends State<SignUpForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  bool _usernameExists = false;
  static final Pattern _emailPattern = "(?:[a-z0-9!#\$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)])";
  static final RegExp _emailRegex = new RegExp(_emailPattern);
  static final Pattern _passwordPattern = "(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}";
  static final RegExp _passwordRegex = new RegExp(_passwordPattern);
  TextEditingController _passCtrl = TextEditingController();
  String _name;
  String _surname;
  String _username;
  String _email;
  String _password;

  void _signUp() async {
    _usernameExists = false;
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
      SignUpResult result = await widget._onValidate(_name, _surname, _username, _email, _password);
      switch (result) {
        case SignUpResult.USERNAME_EXISTS:
          _usernameExists = true;
          break;
        case SignUpResult.NETWORK_ERROR:
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Network error. Check your internet connection and try again"),
          ));
          break;
        case SignUpResult.UNKNOWN_ERROR:
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Unknown error. Please try again later"),
          ));
          break;
        case SignUpResult.SUCCESS:
          Navigator.pop(context);
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Account created! Please check your email to verify it"),
          ));
          widget._onSignUp();
          return;
      }
      // Dispose progress (and redraw form)
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
              TextFormField( // NAME
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Enter your name',
                  labelText: 'Name',
                ),
                validator: (value) {
                  return value.isEmpty ? 'Please enter your name' : null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                onSaved: (value) => _name = value,
              ),
              TextFormField( // SURNAME
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Enter your surname',
                  labelText: 'Surname',
                ),
                validator: (value) {
                  return value.isEmpty ? 'Please enter your surname' : null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                onSaved: (value) => _surname = value,
              ),
              TextFormField( // USERNAME
                decoration: const InputDecoration(
                  icon: Icon(Icons.perm_identity),
                  hintText: 'Enter your username',
                  labelText: 'Username',
                ),
                validator: (value) {
                  if (_usernameExists) {
                    return "Username already in use. Please enter another one";
                  }
                  return value.isEmpty || value.contains(" ") ? 'Invalid username' : null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                onSaved: (value) => _username = value,
              ),
              TextFormField( // EMAIL
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  icon: Icon(Icons.email),
                  hintText: 'Enter your email address',
                  labelText: 'Email address',
                ),
                validator: (value) {
                  return _emailRegex.hasMatch(value) ? null : 'Please enter a valid email address';
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                onSaved: (value) => _email = value,
              ),
              TextFormField( // PASSWORD
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  icon: Icon(Icons.vpn_key),
                  hintText: 'Enter your password',
                  labelText: 'Password',
                  errorMaxLines: 2,
                ),
                validator: (value) {
                  return _passwordRegex.hasMatch(value) ? null : 'Password must contain upper and lower case letters, at least one number and must be at least 8 characters long';
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                onSaved: (value) => _password = value,
              ),
              TextFormField( // PASSWORD CONFIRM
                obscureText: true,
                decoration: const InputDecoration(
                  icon: Icon(Icons.vpn_key),
                  hintText: 'Confirm your password',
                  labelText: 'Password confirm',
                ),
                validator: (value) {
                  return value == _passCtrl.text ? null : 'The two passwords don\'t match';
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
              ),
              Padding (
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: RaisedButton(
                  onPressed: _signUp,
                  child: Text('Sign-up'),
                ),
              )
            ]
          )
        )
      )
    );
  }
}
