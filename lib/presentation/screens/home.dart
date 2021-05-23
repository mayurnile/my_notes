import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_notes/providers/providers.dart';

import '../../core/core.dart';
import '../../providers/notes_provider.dart';

import '../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final NotesProvider _notesProvider = Get.find();
  Timer? _timerLink;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerLink = new Timer(
        const Duration(milliseconds: 1000),
        () {
          _notesProvider.retrieveDynamicLink(context);
        },
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    if (_timerLink != null) {
      _timerLink!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return WillPopScope(
      onWillPop: () async {
        NotesProvider _notesProvider = Get.find();
        if (_notesProvider.notesState == NotesState.SEARCHED ||
            _notesProvider.notesState == NotesState.SEARCHEMPTY) {
          locator.get<NavigationService>().removeAllAndPush(HOME_ROUTE);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                NotesProvider _notesProvider = Get.find();
                _notesProvider.fetchAllNotes();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22.0, 12.0, 22.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //appBar
                    _buildAppBar(textTheme),
                    //searchbar
                    _buildSearchBar(textTheme),
                    //list of notes
                    _buildListNotes(screenSize),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => locator.get<NavigationService>().navigateToNamed(
            ADD_NOTE_ROUTE,
            arguments: {'isEdit': false},
          ),
          child: SvgPicture.asset(Assets.ADD),
        ),
      ),
    );
  }

  Widget _buildAppBar(TextTheme textTheme) {
    return GetBuilder<AuthProvider>(builder: (AuthProvider _authProvider) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          //title
          Text(
            'My Notes',
            style: textTheme.headline2,
          ),
          //spacing
          Spacer(),
          //logout button
          _authProvider.authState == AuthState.AUTHENTICATING
              ? CircularProgressIndicator()
              : InkWell(
                  onTap: () async {
                    final result = await _authProvider.logout();

                    if (result) {
                      locator
                          .get<NavigationService>()
                          .removeAllAndPush(LOGIN_ROUTE);
                    }
                  },
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: SvgPicture.asset(
                      Assets.LOGOUT,
                      height: 22.0,
                      width: 22.0,
                    ),
                  ),
                ),
        ],
      );
    });
  }

  Widget _buildSearchBar(TextTheme textTheme) {
    return SearchField();
  }

  Widget _buildListNotes(Size screenSize) {
    return GetBuilder<NotesProvider>(
      initState: (_) {
        final NotesProvider _notesProvider = Get.find();
        _notesProvider.fetchAllNotes();
      },
      builder: (NotesProvider _notesProvider) {
        if (_notesProvider.notesState == NotesState.LOADING) {
          return Padding(
            padding: EdgeInsets.only(top: screenSize.height * 0.32),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (_notesProvider.notesState == NotesState.LOADED) {
          return Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: _notesProvider.myNotes.length,
              padding: const EdgeInsets.symmetric(vertical: 22.0),
              itemBuilder: (BuildContext context, int index) {
                return NoteCard(
                  note: _notesProvider.myNotes[index],
                );
              },
            ),
          );
        } else if (_notesProvider.notesState == NotesState.NONOTES) {
          return NoNotesError();
        } else if (_notesProvider.notesState == NotesState.ERROR) {
          return Padding(
            padding: EdgeInsets.only(top: screenSize.height * 0.32),
            child: Text('Something went wrong !'),
          );
        } else if (_notesProvider.notesState == NotesState.SEARCHING) {
          return Padding(
            padding: EdgeInsets.only(top: screenSize.height * 0.32),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (_notesProvider.notesState == NotesState.SEARCHED) {
          return Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: _notesProvider.searchedNotes.length,
              padding: const EdgeInsets.symmetric(vertical: 22.0),
              itemBuilder: (BuildContext context, int index) {
                return NoteCard(
                  note: _notesProvider.searchedNotes[index],
                );
              },
            ),
          );
        } else if (_notesProvider.notesState == NotesState.SEARCHEMPTY) {
          return Padding(
            padding: EdgeInsets.only(top: screenSize.height * 0.3),
            child: Center(child: Text('Nothing Found !')),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
