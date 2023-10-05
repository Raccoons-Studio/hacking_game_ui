import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginOrRegister extends StatefulWidget {
  @override
  _LoginOrRegisterState createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/images/penny_single_fans_logo.jpg',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: TextField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: TextField(
                  controller: _passwordController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _registerUser();
              },
              child: Text("S'enregistrer", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                _loginUser();
              },
              child: Text('Se connecter', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                _resetPassword();
              },
              child: Text('Mot de passe oublié', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            Text(
              _message,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registerUser() async {
    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (newUser != null) {
        setState(() {
          _message = 'User registered successfully';
        });
        Navigator.of(context).pop();
      }
      
    } catch (e) {
      setState(() {
        _message = e.toString();
      });
    }
  }

  Future<void> _loginUser() async {
    try {
      final user = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (user != null) {
        setState(() {
          _message = 'User logged in successfully';
        });
        Navigator.of(context).pop();
      }
      
    } catch (e) {
      setState(() {
        _message = e.toString();
      });
    }
  }

  Future<void> _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      setState(() {
        _message = 'Reset password mail sent';
      });
      
    } catch (e) {
      setState(() {
        _message = e.toString();
      });
    }
  }
}