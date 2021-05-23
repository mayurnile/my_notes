import 'dart:async';

import 'package:get/get.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends GetxController {
  late FirebaseAuth _firebaseAuth;

  String? _email;
  String? _password;
  String? _confirmPassword;
  bool? _showPassword;
  bool? _showConfirmPassword;
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
    _state = AuthState.UNAUTHENTICATED;
  }

  //setter
  set setEmail(String em) => _email = em;
  set setPassword(String pw) => _password = pw;
  set setConfirmPassword(String cpw) => _confirmPassword = cpw;
  void toggleShowPassword() {
    _showPassword = _showPassword != null ? !_showPassword! : false;
    update();
  }

  void toggleShowConfirmPassword() {
    _showConfirmPassword =
        _showConfirmPassword != null ? !_showConfirmPassword! : true;
    update();
  }

  //getters
  get email => _email;
  get password => _password;
  get confirmPassword => _confirmPassword;
  get authState => _state;
  get authError => _errorMessage;
  get showPassword => _showPassword;
  get showConfirmPassword => _showConfirmPassword;
  get firebaseAuth => _firebaseAuth;

  ///[Login method]
  ///Return true if login is success or false if unsuccess
  Future<bool> login() async {
    _setLoadingState();
    try {
      final User? user = (await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ))
          .user;

      if (user != null) {
        _state = AuthState.AUTHENTICATED;
        update();
        return true;
      } else {
        _state = AuthState.ERROR;
        _errorMessage = 'Something went wrong';
        update();
        return false;
      }
    } catch (_) {
      _state = AuthState.UNAUTHENTICATED;
      update();
    }
    return false;
  }

  ///[Signup method]
  ///Return true if signup is success or false if unsuccess
  Future<bool> signup() async {
    _setLoadingState();
    try {
      final User? user = (await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ))
          .user;

      if (user != null) {
        _state = AuthState.AUTHENTICATED;
        update();
        return true;
      } else {
        _state = AuthState.ERROR;
        _errorMessage = 'Something went wrong';
        update();
        return false;
      }
    } catch (_) {
      _state = AuthState.UNAUTHENTICATED;
      update();
    }
    return false;
  }

  Future<bool> logout() async {
    _setLoadingState();
    try {
      await _firebaseAuth.signOut();

      _state = AuthState.UNAUTHENTICATED;
      update();
      return true;
    } catch (_) {
      return false;
    }
  }

  ///[Setting State as Loading]
  void _setLoadingState() {
    _state = AuthState.AUTHENTICATING;
    update();
  }
}

enum AuthState {
  AUTHENTICATED,
  UNAUTHENTICATED,
  AUTHENTICATING,
  ERROR,
}
