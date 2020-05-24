
import 'package:flutter/material.dart';

// Define a custom Form widget.
class SignUpForm extends StatefulWidget {

  // Function to call after validate process
  final _onValidate;

  SignUpForm(this._onValidate);

  @override
  SignUpFormState createState() {
    return SignUpFormState(_onValidate);
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

  // Function to call after validate process
  final _onValidate;
  static final Pattern _emailPattern = "(?:[a-z0-9!#\$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)])";
  static final RegExp _emailRegex = new RegExp(_emailPattern);
  static final Pattern _passwordPattern = "(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}";
  static final RegExp _passwordRegex = new RegExp(_passwordPattern);
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _surnameCtrl = TextEditingController();
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  SignUpFormState(this._onValidate);

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
              TextFormField( // NAME
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Enter your name',
                  labelText: 'Name',
                ),
                validator: (value) {
                  return value.isEmpty ? 'Please enter your name' : null;
                }
              ),
              TextFormField( // SURNAME
                controller: _surnameCtrl,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Enter your surname',
                  labelText: 'Surname',
                ),
                validator: (value) {
                  return value.isEmpty ? 'Please enter your surname' : null;
                }
              ),
              TextFormField( // USERNAME
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  icon: Icon(Icons.perm_identity),
                  hintText: 'Enter your username',
                  labelText: 'Username',
                ),
                validator: (value) {
                  return value.isEmpty ? 'Please enter your username' : null;
                }
              ),
              TextFormField( // EMAIL
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  icon: Icon(Icons.email),
                  hintText: 'Enter your email address',
                  labelText: 'Email address',
                ),
                validator: (value) {
                  return _emailRegex.hasMatch(value) ? null : 'Please enter a valid email address';
                }
              ),
              TextFormField( // PASSWORD
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  icon: Icon(Icons.vpn_key),
                  hintText: 'Enter your password',
                  labelText: 'Password',
                ),
                validator: (value) {
                  return _passwordRegex.hasMatch(value) ? null : 'Password must contain upper and lower case letters, at least one number and must be at least 8 characters long';
                }
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
                }
              ),
              Padding (
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: RaisedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, otherwise false.
                    if (_formKey.currentState.validate()) {
                      _onValidate(_nameCtrl.text, _surnameCtrl.text, _usernameCtrl.text, _emailCtrl.text, _passCtrl.text);
                    }
                  },
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
