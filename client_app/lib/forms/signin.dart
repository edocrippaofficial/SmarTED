
import 'package:flutter/material.dart';

// Define a custom Form widget.
class SignInForm extends StatefulWidget {

  // Function to call after validate process
  final _onValidate;

  SignInForm(this._onValidate);

  @override
  SignInFormState createState() {
    return SignInFormState(_onValidate);
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

  // Function to call after validate process
  final _onValidate;
  static final Pattern _passwordPattern = "(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}";
  static final RegExp _passwordRegex = new RegExp(_passwordPattern);
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  SignInFormState(this._onValidate);

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: <Widget>[
              TextFormField( // USERNAME OR EMAIL
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.perm_identity),
                    labelText: 'Username/Email address',
                  ),
                  validator: (value) {
                    return value.isEmpty ? 'Please enter your username or email' : null;
                  }
              ),
              TextFormField( // PASSWORD
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.vpn_key),
                    labelText: 'Password',
                  ),
                  validator: (value) {
                    return _passwordRegex.hasMatch(value) ? null : 'Invalid password';
                  }
              ),
              Padding (
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: RaisedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, otherwise false.
                    if (_formKey.currentState.validate()) {
                      _onValidate( _usernameCtrl.text, _passCtrl.text);
                    }
                  },
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
