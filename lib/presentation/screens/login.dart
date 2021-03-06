import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/core.dart';
import '../../providers/providers.dart';
import '../widgets/widgets.dart';

class LoginScreen extends StatelessWidget {
  // final AuthProvider _authProvider = Get.find();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //spacing
                SizedBox(height: screenSize.height * 0.05),
                //app logo and title
                AppLogo(),
                //spacing
                SizedBox(height: screenSize.height * 0.1),
                //welcome text
                _buildWelcomeText(screenSize, textTheme),
                //spacing
                SizedBox(height: screenSize.height * 0.05),
                //login form
                _buildLoginForm(screenSize, textTheme),
                //spacing
                SizedBox(height: screenSize.height * 0.1),
                //signup option
                _buildSignupOption(screenSize, textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText(Size screenSize, TextTheme textTheme) {
    return Column(
      children: [
        //title
        SizedBox(
          width: screenSize.width,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Welcome',
              style: textTheme.headline2,
            ),
          ),
        ),
        //subtitle
        SizedBox(
          width: screenSize.width,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Sign in to continue !',
              style: textTheme.headline3,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildLoginForm(Size screenSize, TextTheme textTheme) {
    return GetBuilder<AuthProvider>(
      builder: (AuthProvider _authProvider) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //email input
                MyTextField(
                  key: const ValueKey('email'),
                  hint: 'Enter Email',
                  inputType: TextInputType.emailAddress,
                  onSaved: (String? value) {
                    if (value != null) _authProvider.email = value.trim();
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r"\s")),
                  ],
                  validator: (String? value) {
                    if (value != null && value.trim().isEmpty) {
                      return 'This field cannot be empty !';
                    }
                    if (value != null && !RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(value.trim())) {
                      return 'Please enter a valid email !';
                    }
                    return null;
                  },
                ),
                //spacing
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                //password input
                MyTextField(
                  key: const ValueKey('password'),
                  hint: 'Password',
                  inputType: TextInputType.visiblePassword,
                  obscureText: _authProvider.showPassword,
                  isError: _authProvider.authState == AuthState.error,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r"\s")),
                  ],
                  suffix: IconButton(
                    icon: Icon(
                      _authProvider.showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    color: _authProvider.authState == AuthState.error ? MyNotesTheme.fontLightColor : MyNotesTheme.fontDarkColor,
                    onPressed: _authProvider.toggleShowPassword,
                  ),
                  onSaved: (String? value) {
                    if (value != null) _authProvider.password = value.trim();
                  },
                  validator: (String? value) {
                    if (value != null && value.trim().isEmpty) {
                      return 'This field cannot be empty !';
                    }
                  },
                ),
                //spacing
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                //login button
                if (_authProvider.authState == AuthState.authenticating)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(MyNotesTheme.primaryColor),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () => _login(_authProvider),
                    child: Text(
                      'Login',
                      style: textTheme.headline4!.copyWith(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignupOption(Size screenSize, TextTheme textTheme) {
    return SizedBox(
      width: screenSize.width * 0.55,
      child: FittedBox(
        child: Row(
          children: [
            Text(
              "I'm a new user ",
              key: const ValueKey('signup_text'),
              style: textTheme.bodyText1,
            ),
            InkWell(
              onTap: () => locator.get<NavigationService>().removeAllAndPush(signupRoute),
              key: const ValueKey('signup_button'),
              child: Text(
                'Signup',
                style: textTheme.bodyText1!.copyWith(
                  color: MyNotesTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login(AuthProvider _authProvider) async {
    final form = _formKey.currentState;

    if (form!.validate()) {
      form.save();

      final result = await _authProvider.login(
        auth: _authProvider.firebaseAuth,
        email: _authProvider.email != null ? _authProvider.email! : '',
        password: _authProvider.password != null ? _authProvider.password! : '',
      );

      if (result) {
        locator.get<NavigationService>().navigateToReplacement(homeRoute);
        Fluttertoast.showToast(msg: 'Login Success!');
      } else {
        Fluttertoast.showToast(msg: 'Something went wrong!');
      }
    }
  }
}
