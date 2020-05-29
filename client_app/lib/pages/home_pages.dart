
import 'package:flutter/material.dart';
import 'package:smarted/aws/cognito.dart';
import 'package:smarted/aws/lambda.dart';

class HomePage extends StatefulWidget {

  final _onSignOut;

  HomePage(this._onSignOut);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final _cognito = Cognito.getInstance();
  final _txtControllerToken = TextEditingController();
  final _txtControllerNoToken = TextEditingController();

  void _getTalksByTag() async {
    String token = _cognito.getIDToken();
    _txtControllerToken.text = await getTalksByTag('energy', token);
  }

  void _getTalksByTagNoToken() async {
    _txtControllerNoToken.text = await getTalksByTag('energy', null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  children: [
                    RaisedButton(
                      child: Text('GetTalksByTag - ID token'),
                      onPressed: _getTalksByTag,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      height: 500,
                      child: TextField(
                        maxLines: 20,
                        readOnly: true,
                        controller: _txtControllerToken,
                      ),
                    )
                  ]
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    RaisedButton(
                      child: Text('GetTalksByTag - no token'),
                      onPressed: _getTalksByTagNoToken,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      height: 500,
                      child: TextField(
                        maxLines: 20,
                        readOnly: true,
                        controller: _txtControllerNoToken,
                      ),
                    )
                  ]
                )
              ),
            ],
          ),
          Center(
            child: RaisedButton(
              child: Text('Sign-out'),
              onPressed: () async {
                await _cognito.signOut();
                widget._onSignOut();
              }
            ),
          )
        ],
      ),
    );
  }
}