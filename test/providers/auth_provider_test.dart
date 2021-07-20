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
  MockFirebaseAuth _auth = MockFirebaseAuth();
  AuthProvider _authProvider = AuthProvider();
  MockUserCredential _userCredential = MockUserCredential();
  MockUser _user = MockUser();

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
          String _email = "email";
          String _password = "password";

          //Act
          bool result = await _authProvider.login(
            auth: _auth,
            email: _email,
            password: _password,
          );

          //Assert
          expect(result, true);
          expect(_authProvider.authState, AuthState.AUTHENTICATED);
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
          String _email = "email";
          String _password = "pass123";

          //Act
          bool result = await _authProvider.login(
            auth: _auth,
            email: _email,
            password: _password,
          );

          //Assert
          expect(result, false);
          expect(_authProvider.authState, AuthState.UNAUTHENTICATED);
        },
      );

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
          String _email = "email";
          String _password = "password";

          //Act
          bool result = await _authProvider.signup(
            auth: _auth,
            email: _email,
            password: _password,
          );

          //Assert
          expect(result, true);
          expect(_authProvider.authState, AuthState.AUTHENTICATED);
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
          String _email = "ema1l";
          String _password = "password";

          //Act
          bool result = await _authProvider.signup(
            auth: _auth,
            email: _email,
            password: _password,
          );

          //Assert
          expect(result, false);
          expect(_authProvider.authState, AuthState.UNAUTHENTICATED);
        },
      );

      test(
        "signout should success",
        () async {
          //Arrange
          when(
            _auth.signOut(),
          ).thenAnswer((_) => Future.value());

          //Act
          bool result = await _authProvider.logout(auth: _auth);

          //Asset
          expect(result, true);
          expect(_authProvider.authState, AuthState.UNAUTHENTICATED);
        },
      );
    },
  );
}
