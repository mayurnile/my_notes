import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_notes/core/models/models.dart';

import '../../presentation/screens/screens.dart';
import '../../providers/providers.dart';
import './route_names.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      final AuthProvider _authProvider = Get.find();
      final User? user = _authProvider.firebaseAuth.currentUser;
      if (user != null) {
        return _getPageRoute(HomeScreen(), settings);
      }
      return _getPageRoute(LoginScreen(), settings);
    case loginRoute:
      return _getPageRoute(LoginScreen(), settings);
    case signupRoute:
      return _getPageRoute(SignupScreen(), settings);
    case homeRoute:
      return _getPageRoute(HomeScreen(), settings);
    case addNoteRoute:
      final Map<String, dynamic>? args =
          settings.arguments as Map<String, dynamic>?;
      if (args != null && args['isEdit'] == true) {
        final Note note = args['note'] as Note;
        return _getPageRoute(
          AddNotescreen(
            isEdit: true,
            note: note,
          ),
          settings,
        );
      }
      return _getPageRoute(
        const AddNotescreen(isEdit: false),
        settings,
      );
    case viewNoteRoute:
      final Map<String, dynamic>? args =
          settings.arguments as Map<String, dynamic>?;
      final Note note = args!['note'] as Note;
      return _getPageRoute(
        ViewNoteScreen(
          viewNote: note,
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
