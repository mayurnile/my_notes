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
      _timerLink = Timer(
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
        final NotesProvider _notesProvider = Get.find();
        if (_notesProvider.notesState == NotesState.searched || _notesProvider.notesState == NotesState.searchEmpty) {
          locator.get<NavigationService>().removeAllAndPush(homeRoute);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: RefreshIndicator(
              color: MyNotesTheme.primaryColor,
              onRefresh: () async {
                final NotesProvider _notesProvider = Get.find();
                final AuthProvider _authProvider = Get.find();
                final String? userId = _authProvider.userId;
                _notesProvider.fetchAllNotes(
                  firestore: _notesProvider.firestore,
                  userID: userId ?? '',
                );
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
            addNoteRoute,
            arguments: {'isEdit': false},
          ),
          child: SvgPicture.asset(Assets.add),
        ),
      ),
    );
  }

  Widget _buildAppBar(TextTheme textTheme) {
    return GetBuilder<AuthProvider>(
      builder: (AuthProvider _authProvider) {
        return Row(
          children: [
            //title
            Text(
              'My Notes',
              style: textTheme.headline2,
            ),
            //spacing
            const Spacer(),
            //logout button
            if (_authProvider.authState == AuthState.authenticating)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(MyNotesTheme.primaryColor),
              )
            else
              InkWell(
                onTap: () async {
                  final result = await _authProvider.logout(
                    auth: _authProvider.firebaseAuth,
                  );

                  if (result) {
                    locator.get<NavigationService>().removeAllAndPush(loginRoute);
                  }
                },
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SvgPicture.asset(
                    Assets.logout,
                    height: 22.0,
                    width: 22.0,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(TextTheme textTheme) {
    return SearchField();
  }

  Widget _buildListNotes(Size screenSize) {
    return GetBuilder<NotesProvider>(
      initState: (_) {
        final NotesProvider _notesProvider = Get.find();
        final AuthProvider _authProvider = Get.find();
        final String? userId = _authProvider.userId;
        _notesProvider.fetchAllNotes(
          firestore: _notesProvider.firestore,
          userID: userId ?? '',
        );
      },
      builder: (NotesProvider _notesProvider) {
        if (_notesProvider.notesState == NotesState.loading) {
          return Padding(
            padding: EdgeInsets.only(top: screenSize.height * 0.32),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(MyNotesTheme.primaryColor),
              ),
            ),
          );
        } else if (_notesProvider.notesState == NotesState.loaded) {
          return Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: _notesProvider.myNotes!.length,
              padding: const EdgeInsets.symmetric(vertical: 22.0),
              itemBuilder: (BuildContext context, int index) {
                return NoteCard(
                  note: _notesProvider.myNotes![index],
                );
              },
            ),
          );
        } else if (_notesProvider.notesState == NotesState.noNotes) {
          return NoNotesError();
        } else if (_notesProvider.notesState == NotesState.error) {
          return Padding(
            padding: EdgeInsets.only(top: screenSize.height * 0.32),
            child: const Text('Something went wrong !'),
          );
        } else if (_notesProvider.notesState == NotesState.searching) {
          return Padding(
            padding: EdgeInsets.only(top: screenSize.height * 0.32),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(MyNotesTheme.primaryColor),
              ),
            ),
          );
        } else if (_notesProvider.notesState == NotesState.searched) {
          final searchedNotes = _notesProvider.searchedNotes!.toSet().toList();
          return Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: searchedNotes.length,
              padding: const EdgeInsets.symmetric(vertical: 22.0),
              itemBuilder: (BuildContext context, int index) {
                return NoteCard(
                  note: searchedNotes[index],
                );
              },
            ),
          );
        } else if (_notesProvider.notesState == NotesState.searchEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: screenSize.height * 0.3),
            child: const Center(child: Text('Nothing Found !')),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
