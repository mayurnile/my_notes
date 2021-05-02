import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/core.dart';
import '../widgets/widgets.dart';
import '../../providers/providers.dart';

class SignupScreen extends StatelessWidget {
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
                _buildLoginOption(screenSize, textTheme),
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
              'Hi There !',
              style: textTheme.headline2,
            ),
          ),
        ),
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
                onChanged: (String value) =>
                    _authProvider.setPassword = value.trim(),
                validator: (String value) {
                  if (value.trim().length == 0) {
                    return 'This field cannot be empty !';
                  }
                  return null;
                },
              ),
              //spacing
              SizedBox(
                height: screenSize.height * 0.02,
              ),
              //confirm password input
              MyTextField(
                key: ValueKey('confirm_password'),
                hint: 'Confirm Password',
                inputType: TextInputType.visiblePassword,
                obscureText: _authProvider.showConfirmPassword,
                isError: _authProvider.authState == AuthState.ERROR,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r"\s")),
                ],
                suffix: IconButton(
                  icon: Icon(
                    _authProvider.showConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  color: _authProvider.authState == AuthState.ERROR
                      ? MyNotesTheme.FONT_LIGHT_COLOR
                      : MyNotesTheme.FONT_DARK_COLOR,
                  onPressed: _authProvider.toggleShowConfirmPassword,
                ),
                onSaved: (String value) =>
                    _authProvider.setConfirmPassword = value.trim(),
                validator: (String value) {
                  if (value.trim().length == 0) {
                    return 'This field cannot be empty !';
                  } else if (value.trim() != _authProvider.password) {
                    return 'Password and Confirm Password didn\'t match !';
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
                  : ElevatedButton(
                      onPressed: () => _signup(_authProvider),
                      child: Text(
                        'Signup',
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

  Widget _buildLoginOption(Size screenSize, TextTheme textTheme) {
    return SizedBox(
      width: screenSize.width * 0.55,
      child: FittedBox(
        child: Row(
          children: [
            Text(
              'I\'m already a member,' + ' ',
              key: ValueKey('login_text'),
              style: textTheme.bodyText1,
            ),
            InkWell(
              onTap: () => locator
                  .get<NavigationService>()
                  .removeAllAndPush(LOGIN_ROUTE),
              key: ValueKey('login_button'),
              child: Text(
                'Login',
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

  void _signup(AuthProvider _authProvider) async {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();

      final result = await _authProvider.signup();

      if (result) {
        locator.get<NavigationService>().navigateToReplacement(HOME_ROUTE);
        Fluttertoast.showToast(msg: 'Signup Success!');
      } else {
        Fluttertoast.showToast(msg: 'Something went wrong!');
      }
    }
  }
}
