import 'package:flutter/material.dart';
import 'package:smarted/aws/cognito.dart';
import 'package:smarted/pages/auth_pages.dart';
import 'package:smarted/pages/home_pages.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        accentColor: Colors.blue,
        buttonColor: Colors.blue,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _StartPage(),
    );
  }
}

class _StartPage extends StatefulWidget {

  _StartPage({Key key}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<_StartPage> {

  Cognito _cognito = Cognito.getInstance();
  bool _authenticated = false;

  @override
  initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() async {
    bool auth = await _cognito.init();
    setState(() {
      _authenticated = auth;
    });
  }

  void _onSignIn() {
    setState(() {
      _authenticated = true;
    });
  }

  void _onSignOut() {
    setState(() {
      _authenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _authenticated ? HomePage(_onSignOut) : AuthPage(_onSignIn)
    );
  }
}