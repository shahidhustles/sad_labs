import 'package:flutter/material.dart';
import 'configurations.dart';
import 'utility.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final TextEditingController useridcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController confirmpasswordcontroller =
      TextEditingController();

  String? userIdErrorText;
  String? passwordErrorText;
  String? confirmPasswordErrorText;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    useridcontroller.dispose();
    passwordcontroller.dispose();
    confirmpasswordcontroller.dispose();
    super.dispose();
  }

  String? _setUserIdErrorText(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return 'Please enter email ID';
    }
    if (!Utility.validateEmail(trimmedValue)) {
      return 'Please enter valid email ID';
    }
    if (!Utility.validateUniqueUserId(trimmedValue)) {
      return 'User ID already exists';
    }
    return null;
  }

  String? _setPasswordErrorText(String value) {
    if (value.isEmpty) return 'Please enter password';
    if (!Utility.validatePasswordLength(value)) {
      return 'Password length should be more than 3';
    }
    if (!Utility.validateLowerCase(value)) {
      return 'Password must contain 1 lowercase letter';
    }
    if (!Utility.validateUpperCase(value)) {
      return 'Password must contain 1 uppercase letter';
    }
    if (!Utility.validateDigit(value)) {
      return 'Password must contain 1 digit';
    }
    if (!Utility.validateSymbol(value)) {
      return 'Password must contain 1 symbol';
    }
    return null;
  }

  String? _setConfirmPasswordErrorText(String value) {
    if (value.isEmpty) return 'Please confirm password';
    if (value != passwordcontroller.text) return 'Passwords do not match';
    return null;
  }

  void _checkUserIdAvailability() {
    setState(() {
      userIdErrorText = _setUserIdErrorText(useridcontroller.text);
    });

    final isAvailable = userIdErrorText == null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isAvailable ? 'User ID is available' : userIdErrorText!),
        backgroundColor: isAvailable ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void validate() {
    setState(() {
      userIdErrorText = _setUserIdErrorText(useridcontroller.text);
      passwordErrorText = _setPasswordErrorText(passwordcontroller.text);
      confirmPasswordErrorText = _setConfirmPasswordErrorText(
        confirmpasswordcontroller.text,
      );
    });

    if (userIdErrorText == null &&
        passwordErrorText == null &&
        confirmPasswordErrorText == null) {
      Configurations.credentials.add({
        'userid': useridcontroller.text.trim(),
        'password': passwordcontroller.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Register'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: useridcontroller,
                onChanged: (_) {
                  setState(() {
                    userIdErrorText = _setUserIdErrorText(
                      useridcontroller.text,
                    );
                  });
                },
                decoration: InputDecoration(
                  suffixIcon: InkWell(
                    onTap: _checkUserIdAvailability,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Check'),
                    ),
                  ),
                  labelText: 'User ID',
                  errorText: userIdErrorText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: passwordcontroller,
                obscureText: obscurePassword,
                onChanged: (_) {
                  setState(() {
                    passwordErrorText = _setPasswordErrorText(
                      passwordcontroller.text,
                    );
                    confirmPasswordErrorText = _setConfirmPasswordErrorText(
                      confirmpasswordcontroller.text,
                    );
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText: passwordErrorText,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: confirmpasswordcontroller,
                obscureText: obscureConfirmPassword,
                onChanged: (_) {
                  setState(() {
                    confirmPasswordErrorText = _setConfirmPasswordErrorText(
                      confirmpasswordcontroller.text,
                    );
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  errorText: confirmPasswordErrorText,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            ElevatedButton(onPressed: validate, child: const Text('Register')),
          ],
        ),
      ),
    );
  }
}
