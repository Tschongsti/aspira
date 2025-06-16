import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:aspira/theme/color_schemes.dart';

final _firebase = FirebaseAuth.instance;

class StartScreen extends StatefulWidget {
  const StartScreen ({super.key});

  @override
  State<StartScreen> createState() {
    return _StartScreenState();
  }
}

class _StartScreenState extends State<StartScreen> {
  final _form = GlobalKey<FormState>();
  
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _isAuthenticating = false;

  String? _authStatus;

  @override
  void initState() {
    super.initState();
    _testAnonymousSignIn(); // 👉 Hier direkt beim Start ausführen
  }

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      // show error message..
      return;
    }

    _form.currentState!.save();
    
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword);
      } else {
        await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword);

      } 
    } on FirebaseAuthException catch (error) {
        print('🔥 Firebase Auth Error: ${error.code} - ${error.message}');
        String message = 'Authentifizierung fehlgeschlagen';

        if (error.code == 'user-not-found') {
          message = 'Kein Benutzer für diese E-Mail gefunden';
        } else if (error.code == 'wrong-password') {
          message = 'Ungültiges Passwort';
        } else if (error.code == 'email-already-in-use') {
          message = 'Diese E-Mail wird bereits verwendet';
        } else if (error.code == 'invalid-email') {
          message = 'Ungültige E-Mail';
        } else if (error.code == 'weak-password') {
          message = 'Zu schwaches Passwort';
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message),
          ),
        );
        
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAspiraBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/logo-aspira.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'E-Mail'
                            ),
                            keyboardType: TextInputType.emailAddress,
                            maxLength: 60,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Bitte eine gültige E-Mail Adresse eingeben';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Passwort'
                            ),
                            maxLength: 60,
                            obscureText: true,
                            validator: (value) {
                              if (value == null ||
                                 value.trim().length < 6) {
                                return 'Passwort muss mindestes 6 Zeichen lang sein';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              child: Text (
                                _isLogin
                                  ? 'Einloggen'
                                  : 'Anmelden',
                              ),
                            ),
                          ),
                          if (!_isAuthenticating)
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                ? 'Erstelle ein Benutzerkonto'
                                : 'Ich habe schon ein Benutzerkonto'),
                            ),
                          ),
                          if (_authStatus != null)
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                _authStatus!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Future<void> _testAnonymousSignIn() async {
  try {
    final result = await FirebaseAuth.instance.signInAnonymously();
    setState(() {
      _authStatus = '✅ Anonymer Login erfolgreich: ${result.user?.uid}';
    });
  } on FirebaseAuthException catch (e) {
    setState(() {
      _authStatus = '🔴 Firebase Auth Error (anon): ${e.code} - ${e.message}';
    });
  } catch (e) {
    setState(() {
      _authStatus = '❌ Unerwarteter Fehler (anon): $e';
    });
  }
}

}



