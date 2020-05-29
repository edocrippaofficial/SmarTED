
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:smarted/aws/cognito.dart';

void displayProgressDialog(final context) {
  Navigator.of(context).push(PageRouteBuilder(
    barrierDismissible: false,
    opaque: false,
    pageBuilder: (BuildContext context, _, __) {
      return WillPopScope(
        // Ignore back button press
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
              child: CircularProgressIndicator()
          ),
        )
      );
    }
  ));
}

class AuthPage extends StatefulWidget {

  final _onSignIn;

  AuthPage(this._onSignIn);

  @override
  State<StatefulWidget> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  final _formKey = GlobalKey<FormState>();

  static final Pattern _passwordPattern = "(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}";
  static final RegExp _passwordRegex = new RegExp(_passwordPattern);
  String _username, _password;
  bool _wrongPassword = false, _userNotConfirmed = false;
  final _cognito = Cognito.getInstance();

  void _showSignUpSnackBar() {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(
          "Account created! Please check your email to verify it"),
    ));
  }

  void _signIn() async {

    _wrongPassword = _userNotConfirmed = false;

    // Fields local validation
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      // Dispose keyboard
      FocusScope.of(context).requestFocus(new FocusNode());

      // Display progress
      displayProgressDialog(context);

      // Start sign up call
      SignInResult result = await _cognito.signIn(_username, _password);
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

          // Callback function
          widget._onSignIn();
          return;
      }
      // Dismiss progress
      Navigator.pop(context);
      // Show errors
      _formKey.currentState.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image(
                  width: MediaQuery.of(context).size.width / 2,
                  image: AssetImage('assets/images/dark_icon.png')
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                  child: Column(
                    children: <Widget>[
                      TextFormField( // USERNAME OR EMAIL
                        decoration: const InputDecoration(
                          icon: Icon(Icons.perm_identity),
                          labelText: 'Username/Email address',
                        ),
                        validator: (value) {
                          return _userNotConfirmed
                              ? 'Account not confirmed'
                              : value.isEmpty || value.contains(" ")
                              ? 'Invalid username'
                              : null;
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
                          return _wrongPassword
                              ? 'Password not correct'
                              : _passwordRegex.hasMatch(value)
                              ? null
                              : 'Invalid password';
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                        onSaved: (value) => _password = value,
                      ),
                      Padding (
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: RaisedButton(
                          onPressed: _signIn,
                          child: Text('Sign-in'),
                        ),
                      )
                    ]
                  )
                )
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Need an account? ",
                      ),
                      TextSpan(
                        text: "Sign-up",
                        style: TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Push sign-up page
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => _SignUpPage(_showSignUpSnackBar)
                            ));
                          },
                      ),
                    ],
                  ),
                ),
              )
            ],
          )
        )
      )
    );
  }
}

class _SignUpPage extends StatefulWidget {

  final _onSignUp;

  _SignUpPage(this._onSignUp);

  @override
  State<StatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<_SignUpPage> {

  final _formKey = GlobalKey<FormState>();

  static final Pattern _emailPattern = "(?:[a-z0-9!#\$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)])";
  static final RegExp _emailRegex = new RegExp(_emailPattern);
  static final Pattern _passwordPattern = "(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}";
  static final RegExp _passwordRegex = new RegExp(_passwordPattern);
  TextEditingController _passCtrl = TextEditingController();
  String _name, _surname, _username, _email, _password;
  bool _usernameExists = false;
  final _cognito = Cognito.getInstance();

  void _signUp() async {
    _usernameExists = false;

    // Fields local validation
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      // Dispose keyboard
      FocusScope.of(context).requestFocus(new FocusNode());

      // Display progress
      displayProgressDialog(context);

      // Start sign up call
      SignUpResult result = await _cognito.signUp(
          _name, _surname, _username, _email, _password);
      switch (result) {
        case SignUpResult.USERNAME_EXISTS:
          _usernameExists = true;
          break;
        case SignUpResult.NETWORK_ERROR:
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(
              "Network error. Check your internet connection and try again"),
          ));
          break;
        case SignUpResult.UNKNOWN_ERROR:
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Unknown error. Please try again later"),
          ));
          break;
        case SignUpResult.SUCCESS:

          // Dismiss progress
          Navigator.pop(context);
          // SignUp successful, return to sign-in page
          Navigator.pop(context);
          widget._onSignUp();
          return;
      }
      // Dismiss progress
      Navigator.pop(context);
      // Show errors
      _formKey.currentState.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Build sign-up form
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
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
                          return value.isEmpty
                              ? 'Please enter your name'
                              : null;
                        },
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).nextFocus(),
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
                          return value.isEmpty
                              ? 'Please enter your surname'
                              : null;
                        },
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).nextFocus(),
                        onSaved: (value) => _surname = value,
                      ),
                      TextFormField( // USERNAME
                        decoration: const InputDecoration(
                          icon: Icon(Icons.perm_identity),
                          hintText: 'Enter your username',
                          labelText: 'Username',
                        ),
                        validator: (value) {
                          return _usernameExists
                              ? "Username already in use. Please enter another one"
                              : value.isEmpty || value.contains(" ")
                              ? 'Invalid username'
                              : null;
                        },
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).nextFocus(),
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
                          return _emailRegex.hasMatch(value)
                              ? null
                              : 'Please enter a valid email address';
                        },
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).nextFocus(),
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
                          return _passwordRegex.hasMatch(value)
                              ? null
                              : 'Password must contain upper and lower case letters, at least one number and must be at least 8 characters long';
                        },
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).nextFocus(),
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
                          return value == _passCtrl.text
                              ? null
                              : 'The two passwords don\'t match';
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).unfocus(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: RaisedButton(
                          onPressed: _signUp,
                          child: Text('Sign-up'),
                        ),
                      )
                    ]
                  )
                )
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Already have an account? ",
                      ),
                      TextSpan(
                        text: "Sign-in",
                        style: TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Return to sign-in screen
                            Navigator.pop(context);
                          },
                      ),
                    ],
                  ),
                ),
              )
            ],
          )
        )
      )
    );
  }
}