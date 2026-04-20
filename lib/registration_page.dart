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

  final ValueNotifier<String?> userIdErrorText = ValueNotifier<String?>(null);
  final ValueNotifier<String?> passwordErrorText = ValueNotifier<String?>(null);
  final ValueNotifier<String?> confirmPasswordErrorText =
      ValueNotifier<String?>(null);
  final ValueNotifier<bool> obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> obscureConfirmPassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    useridcontroller.dispose();
    passwordcontroller.dispose();
    confirmpasswordcontroller.dispose();
    userIdErrorText.dispose();
    passwordErrorText.dispose();
    confirmPasswordErrorText.dispose();
    obscurePassword.dispose();
    obscureConfirmPassword.dispose();
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

  void _validateUserId() {
    userIdErrorText.value = _setUserIdErrorText(useridcontroller.text);
  }

  void _validatePassword() {
    passwordErrorText.value = _setPasswordErrorText(passwordcontroller.text);
    confirmPasswordErrorText.value = _setConfirmPasswordErrorText(
      confirmpasswordcontroller.text,
    );
  }

  void _validateConfirmPassword() {
    confirmPasswordErrorText.value = _setConfirmPasswordErrorText(
      confirmpasswordcontroller.text,
    );
  }

  void _checkUserIdAvailability() {
    _validateUserId();
    final isAvailable = userIdErrorText.value == null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAvailable ? 'User ID is available' : userIdErrorText.value!,
        ),
        backgroundColor: isAvailable ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void validate() {
    _validateUserId();
    _validatePassword();
    _validateConfirmPassword();

    if (userIdErrorText.value == null &&
        passwordErrorText.value == null &&
        confirmPasswordErrorText.value == null) {
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
              child: ValueListenableBuilder<String?>(
                valueListenable: userIdErrorText,
                builder: (context, value, child) {
                  return TextField(
                    controller: useridcontroller,
                    onChanged: (_) => _validateUserId(),
                    decoration: InputDecoration(
                      suffixIcon: InkWell(
                        onTap: _checkUserIdAvailability,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Check'),
                        ),
                      ),
                      labelText: 'User ID',
                      errorText: value,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ValueListenableBuilder<String?>(
                valueListenable: passwordErrorText,
                builder: (context, value, child) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: obscurePassword,
                    builder: (context, isObscure, child) {
                      return TextField(
                        controller: passwordcontroller,
                        obscureText: isObscure,
                        onChanged: (_) => _validatePassword(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          errorText: value,
                          suffixIcon: IconButton(
                            onPressed: () {
                              obscurePassword.value = !obscurePassword.value;
                            },
                            icon: Icon(
                              isObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
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
              child: ValueListenableBuilder<String?>(
                valueListenable: confirmPasswordErrorText,
                builder: (context, value, child) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: obscureConfirmPassword,
                    builder: (context, isObscure, child) {
                      return TextField(
                        controller: confirmpasswordcontroller,
                        obscureText: isObscure,
                        onChanged: (_) => _validateConfirmPassword(),
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          errorText: value,
                          suffixIcon: IconButton(
                            onPressed: () {
                              obscureConfirmPassword.value =
                                  !obscureConfirmPassword.value;
                            },
                            icon: Icon(
                              isObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton(onPressed: validate, child: const Text('Register')),
          ],
        ),
      ),
    );
  }
}
