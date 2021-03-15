import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/core.dart';
import '../widgets/widgets.dart';
import '../../providers/providers.dart';

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
              crossAxisAlignment: CrossAxisAlignment.center,
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
      crossAxisAlignment: CrossAxisAlignment.center,
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
    return GetBuilder<AuthProvider>(builder: (AuthProvider _authProvider) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //email input
              MyTextField(
                key: ValueKey('email'),
                hint: 'Enter Email',
                inputType: TextInputType.emailAddress,
                onSaved: (String value) =>
                    _authProvider.setEmail = value.trim(),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r"\s")),
                ],
                validator: (String value) {
                  if (value.trim().length == 0) {
                    return 'This field cannot be empty !';
                  }
                  if (!RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                      .hasMatch(value.trim())) {
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
                key: ValueKey('password'),
                hint: 'Password',
                inputType: TextInputType.visiblePassword,
                obscureText: _authProvider.showPassword,
                isError: _authProvider.authState == AuthState.ERROR,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r"\s")),
                ],
                suffix: IconButton(
                  icon: Icon(
                    _authProvider.showPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  color: _authProvider.authState == AuthState.ERROR
                      ? MyNotesTheme.FONT_LIGHT_COLOR
                      : MyNotesTheme.FONT_DARK_COLOR,
                  onPressed: _authProvider.toggleShowPassword,
                ),
                onSaved: (String value) =>
                    _authProvider.setPassword = value.trim(),
                validator: (String value) {
                  if (value.trim().length == 0) {
                    // setState(() => _passwordError = true);
                    return 'This field cannot be empty !';
                  }
                  return null;
                },
              ),
              //spacing
              SizedBox(
                height: screenSize.height * 0.02,
              ),
              //login button
              _authProvider.authState == AuthState.AUTHENTICATING
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : RaisedButton(
                      onPressed: () => _login(_authProvider),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Login',
                        style:
                            textTheme.headline4.copyWith(color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSignupOption(Size screenSize, TextTheme textTheme) {
    return SizedBox(
      width: screenSize.width * 0.55,
      child: FittedBox(
        child: Row(
          children: [
            Text(
              'I\'m a new user,' + ' ',
              key: ValueKey('signup_text'),
              style: textTheme.bodyText1,
            ),
            InkWell(
              onTap: () => locator
                  .get<NavigationService>()
                  .removeAllAndPush(SIGNUP_ROUTE),
              key: ValueKey('signup_button'),
              child: Text(
                'Signup',
                style: textTheme.bodyText1.copyWith(
                  color: MyNotesTheme.PRIMARY_COLOR,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login(AuthProvider _authProvider) async {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();

      final result = await _authProvider.login();

      if (result) {
        locator.get<NavigationService>().navigateToReplacement(HOME_ROUTE);
        Fluttertoast.showToast(msg: 'Login Success!');
      } else {
        Fluttertoast.showToast(msg: 'Something went wrong!');
      }
    }
  }
}