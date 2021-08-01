import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_notes/providers/auth_provider.dart';

import './auth_provider_test.mocks.dart';

@GenerateMocks([UserCredential])
@GenerateMocks([FirebaseAuth])
@GenerateMocks([User])
void main() {
  final MockFirebaseAuth _auth = MockFirebaseAuth();
  final AuthProvider _authProvider = AuthProvider();
  final MockUserCredential _userCredential = MockUserCredential();
  final MockUser _user = MockUser();

  group(
    "User Login Test",
    () {
      test(
        "sign in with email and password",
        () async {
          when(
            _auth.signInWithEmailAndPassword(
              email: "email",
              password: "password",
            ),
          ).thenAnswer(
            (_) async {
              return _userCredential;
            },
          );

          when(
            _userCredential.user,
          ).thenReturn(_user);

          //Arrange
          const String _email = "email";
          const String _password = "password";

          //Act
          final bool result = await _authProvider.login(
            auth: _auth,
            email: _email,
            password: _password,
          );

          //Assert
          expect(result, true);
          expect(_authProvider.authState, AuthState.authenticated);
        },
      );

      test(
        "sign in fails with wrong email and password",
        () async {
          when(
            _auth.signInWithEmailAndPassword(
              email: "email",
              password: "password",
            ),
          ).thenAnswer(
            (_) async {
              return _userCredential;
            },
          );

          when(
            _userCredential.user,
          ).thenReturn(_user);

          //Arrange
          const String _email = "email";
          const String _password = "pass123";

          //Act
          final bool result = await _authProvider.login(
            auth: _auth,
            email: _email,
            password: _password,
          );

          //Assert
          expect(result, false);
          expect(_authProvider.authState, AuthState.unauthenticated);
        },
      );
    },
  );

  group(
    'User Signup Test',
    () {
      test(
        "sign up is successful with email and password",
        () async {
          when(
            _auth.createUserWithEmailAndPassword(
              email: "email",
              password: "password",
            ),
          ).thenAnswer(
            (_) async {
              return _userCredential;
            },
          );

          when(
            _userCredential.user,
          ).thenReturn(_user);

          //Arrange
          const String _email = "email";
          const String _password = "password";

          //Act
          final bool result = await _authProvider.signup(
            auth: _auth,
            email: _email,
            password: _password,
          );

          //Assert
          expect(result, true);
          expect(_authProvider.authState, AuthState.authenticated);
        },
      );

      test(
        "sign up fails with email and password",
        () async {
          when(
            _auth.createUserWithEmailAndPassword(
              email: "email",
              password: "password",
            ),
          ).thenAnswer(
            (_) async {
              return _userCredential;
            },
          );

          when(
            _userCredential.user,
          ).thenReturn(_user);

          //Arrange
          const String _email = "ema1l";
          const String _password = "password";

          //Act
          final bool result = await _authProvider.signup(
            auth: _auth,
            email: _email,
            password: _password,
          );

          //Assert
          expect(result, false);
          expect(_authProvider.authState, AuthState.unauthenticated);
        },
      );
    },
  );

  group(
    'Sign out Test',
    () {
      test(
        "signout should be success",
        () async {
          //Arrange
          when(
            _auth.signOut(),
          ).thenAnswer((_) => Future.value());

          //Act
          final bool result = await _authProvider.logout(auth: _auth);

          //Asset
          expect(result, true);
          expect(_authProvider.authState, AuthState.unauthenticated);
        },
      );
    },
  );
}
