import 'package:flutter/material.dart';
import 'Content.dart';
import 'products_page.dart';
import 'registration_page.dart';
import 'utility.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(title: 'Login'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _userID = TextEditingController(), _password = TextEditingController();
  String? _userIDErrorText, _passwordErrorText;
  final _userIDError = ValueNotifier<bool>(false),
      _passwordError = ValueNotifier<bool>(false),
      _isPasswordObscure = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _userID.dispose();
    _password.dispose();
    _userIDError.dispose();
    _passwordError.dispose();
    _isPasswordObscure.dispose();
    super.dispose();
  }

  void validate(BuildContext context) {
    _userIDError.value = true;
    _userIDErrorText = _setUserIDErrorText(_userID.text);
    _passwordError.value = true;
    _passwordErrorText = _setPasswordErrorText(_password.text);

    if (_userIDErrorText == null && _passwordErrorText == null) {
      if (Utility.validateCredentials(
        userId: _userID.text.trim(),
        password: _password.text.trim(),
      )) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text("SUCCESS")),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                "Invalid Credentials",
                style: TextStyle(fontSize: 20),
              ),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text("Try Sign Up", style: TextStyle(fontSize: 20)),
            ),
            backgroundColor: Colors.deepOrange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String? _setUserIDErrorText(String value) {
    if (value.isEmpty) return 'Please enter email ID';
    if (!Utility.validateEmail(value)) return 'Please enter valid email ID';
    return null;
  }

  String? _setPasswordErrorText(String value) {
    if (value.isEmpty) return 'Please enter Password';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ValueListenableBuilder<bool>(
                valueListenable: _userIDError,
                builder: (context, value, child) {
                  return ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _userID,
                    builder: (context, value, child) {
                      _userIDErrorText = _userIDError.value
                          ? _setUserIDErrorText(value.text)
                          : null;
                      return TextField(
                        controller: _userID,
                        onChanged: !_userIDError.value
                            ? (value) {
                                _userIDError.value = true;
                              }
                            : null,
                        decoration: InputDecoration(
                          labelText: 'User ID',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          errorText: _userIDErrorText,
                          hintText: 'dhiraj.jadhav@vit.edu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ValueListenableBuilder<bool>(
                valueListenable: _passwordError,
                builder: (context, value, child) {
                  return ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _password,
                    builder: (context, value, child) {
                      _passwordErrorText = _passwordError.value
                          ? _setPasswordErrorText(value.text)
                          : null;
                      return ValueListenableBuilder<bool>(
                        valueListenable: _isPasswordObscure,
                        builder: (context, value, child) {
                          return TextField(
                            obscureText: _isPasswordObscure.value,
                            controller: _password,
                            onChanged: !_passwordError.value
                                ? (value) {
                                    _passwordError.value = true;
                                  }
                                : null,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  _isPasswordObscure.value =
                                      !_isPasswordObscure.value;
                                },
                                icon: Icon(
                                  _isPasswordObscure.value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                              label: Text(
                                'Password',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              errorText: _passwordErrorText,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                validate(context);
              },
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text('Sign Up'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return Content();
                    },
                  ),
                );
              },
              child: Text("content"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return ProductsPage();
                    },
                  ),
                );
              },
              child: Text("Products"),
            ),
          ],
        ),
      ),
    );
  }
}
