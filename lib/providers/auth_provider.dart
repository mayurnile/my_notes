import 'dart:async';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends GetxController {
  late FirebaseAuth _firebaseAuth;

  String? _email;
  String? _password;
  String? _confirmPassword;
  late bool _showPassword;
  late bool _showConfirmPassword;
  late AuthState _state;
  late String _errorMessage;

  @override
  void onInit() {
    super.onInit();

    //initialize firebase
    _firebaseAuth = FirebaseAuth.instance;

    //initialize variables
    _email = '';
    _password = '';
    _confirmPassword = '';
    _errorMessage = '';
    _showPassword = true;
    _showConfirmPassword = true;
    _state = AuthState.unauthenticated;
  }

  //setter
  set email(String? em) => _email = em ?? '';
  set password(String? pw) => _password = pw ?? '';
  set confirmPassword(String? cpw) => _confirmPassword = cpw ?? '';

  void toggleShowPassword() {
    _showPassword = !_showPassword;
    update();
  }

  void toggleShowConfirmPassword() {
    _showConfirmPassword = !_showConfirmPassword;
    update();
  }

  //getters
  String? get email => _email;
  String? get password => _password;
  String? get confirmPassword => _confirmPassword;
  AuthState get authState => _state;
  String get authError => _errorMessage;
  bool get showPassword => _showPassword;
  bool get showConfirmPassword => _showConfirmPassword;
  FirebaseAuth get firebaseAuth => _firebaseAuth;

  ///[Login method]
  ///Return true if login is success or false if unsuccess
  Future<bool> login({
    required FirebaseAuth auth,
    required String email,
    required String password,
  }) async {
    _setLoadingState();
    try {
      final User? user = (await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ))
          .user;
      // await _authRepository.signIn(email, password);

      if (user != null) {
        _state = AuthState.authenticated;
        update();
        return true;
      } else {
        _state = AuthState.error;
        _errorMessage = 'Something went wrong';
        update();
        return false;
      }
    } catch (_) {
      _state = AuthState.unauthenticated;
      update();
    }
    return false;
  }

  ///[Signup method]
  ///Return true if signup is success or false if unsuccess
  Future<bool> signup({
    required FirebaseAuth auth,
    required String email,
    required String password,
  }) async {
    _setLoadingState();
    try {
      final User? user = (await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ))
          .user;

      if (user != null) {
        _state = AuthState.authenticated;
        update();
        return true;
      } else {
        _state = AuthState.error;
        _errorMessage = 'Something went wrong';
        update();
        return false;
      }
    } catch (_) {
      _state = AuthState.unauthenticated;
      update();
    }
    return false;
  }

  Future<bool> logout({required FirebaseAuth auth}) async {
    _setLoadingState();
    // try {
    await auth.signOut();

    _state = AuthState.unauthenticated;
    update();
    return true;
    // } catch (_) {
    //   return false;
    // }
  }

  ///[Setting State as Loading]
  void _setLoadingState() {
    _state = AuthState.authenticating;
    update();
  }
}

enum AuthState {
  authenticated,
  unauthenticated,
  authenticating,
  error,
}
