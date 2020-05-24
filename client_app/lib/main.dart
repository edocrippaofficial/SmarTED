import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:smarted/cognito.dart';
import 'package:smarted/forms/signin.dart';
import 'package:smarted/forms/signup.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        accentColor: Colors.blue,
        buttonColor: Colors.blue,
        brightness: Brightness.dark,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'SmarTED'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _authenticated = false;
  bool _authSignUp = false;
  Cognito _cognito = Cognito();

  void toggleAuthPage() {
    setState(() {
      _authSignUp = !_authSignUp;
    });
  }

  void setAuthenticated(bool auth) {
    setState(() {
      _authenticated = auth;
    });
  }

  void signUp(String name, String surname, String username, String email, String password) async {
    SignUpResult result = await _cognito.signUp(name, surname, username, email, password);
    switch (result) {
      case SignUpResult.USERNAME_ALREADY_IN_USE:
        // TODO: Handle this case.
        break;
      case SignUpResult.NETWORK_ERROR:
        // TODO: Handle this case.
        break;
      case SignUpResult.SUCCESS:
        // TODO: Handle this case.
        break;
    }
  }

  void signIn() {
    //cognito.signIn();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _authSignUp ? SignUpForm(signUp) : SignInForm(signIn),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: new RichText(
                  text: new TextSpan(
                    children: [
                      new TextSpan(
                        text: _authSignUp ? "Already have an account? " : "Need an account? ",
                      ),
                      new TextSpan(
                        text: _authSignUp ? "Sign-in" : "Sign-up",
                        style: new TextStyle(color: Colors.blue),
                        recognizer: new TapGestureRecognizer()
                          ..onTap = () {
                            toggleAuthPage();
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
