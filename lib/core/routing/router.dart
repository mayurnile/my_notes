import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './route_names.dart';
import '../../presentation/screens/screens.dart';
import '../../providers/providers.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      AuthProvider _authProvider = Get.find();
      User? user = _authProvider.firebaseAuth.currentUser;
      if (user != null) {
        return _getPageRoute(HomeScreen(), settings);
      }
      return _getPageRoute(LoginScreen(), settings);
    case LOGIN_ROUTE:
      return _getPageRoute(LoginScreen(), settings);
    case SIGNUP_ROUTE:
      return _getPageRoute(SignupScreen(), settings);
    case HOME_ROUTE:
      return _getPageRoute(HomeScreen(), settings);
    case ADD_NOTE_ROUTE:
      final Map<String, dynamic> args =
          settings.arguments as Map<String, dynamic>;
      if (args['isEdit'])
        return _getPageRoute(
          AddNotescreen(
            isEdit: true,
            note: args['note'],
          ),
          settings,
        );
      return _getPageRoute(
        AddNotescreen(isEdit: false),
        settings,
      );
    case VIEW_NOTE_ROUTE:
      final Map<String, dynamic> args =
          settings.arguments as Map<String, dynamic>;
      return _getPageRoute(
        ViewNoteScreen(
          viewNote: args['note'],
        ),
        settings,
      );
    default:
      return _getPageRoute(LoginScreen(), settings);
  }
}

PageRoute _getPageRoute(Widget child, RouteSettings settings) {
  return _FadeRoute(child: child, routeName: settings.name!);
}

class _FadeRoute extends PageRouteBuilder {
  final Widget child;
  final String routeName;

  _FadeRoute({required this.child, required this.routeName})
      : super(
          settings: RouteSettings(name: routeName),
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              child,
          transitionsBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child) =>
              FadeTransition(opacity: animation, child: child),
        );
}
