import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:my_notes/core/core.dart';

import '../core/models/models.dart';
import '../providers/providers.dart';

class NotesProvider extends GetxController {
  late FirebaseFirestore _firestore;
  late FirebaseStorage _firebaseStorage;
  List<Note>? _myNotes = [];
  List<Note>? _searchedNotes = [];
  late NotesState _state;

  @override
  void onInit() {
    super.onInit();

    //initialize firebase
    _firestore = FirebaseFirestore.instance;
    _firebaseStorage = FirebaseStorage.instance;

    //initialize variables
    _myNotes = [];
    _searchedNotes = [];
    _state = NotesState.loading;
  }

  List<Note>? get myNotes => _myNotes;
  NotesState get notesState => _state;
  List<Note>? get searchedNotes => _searchedNotes;

  Future<void> fetchAllNotes() async {
    _myNotes = [];
    final AuthProvider _authProvider = Get.find();
    final User? user = _authProvider.firebaseAuth.currentUser;
    final String userId = user!.uid;

    // _state = NotesState.loading;
    // update();

    try {
      final CollectionReference collectionReference =
          _firestore.collection('users').doc(userId).collection('notes');

      final QuerySnapshot queryData = await collectionReference.get();

      if (queryData.docs.isEmpty) {
        _state = NotesState.noNotes;
        update();
      } else {
        for (final snapshot in queryData.docs) {
          final Map<String, dynamic>? data =
              snapshot.data() as Map<String, dynamic>?;
          final Note myNote = Note.fromJSON(data!, snapshot.id);
          _myNotes!.add(myNote);
        }
        // queryData.docs.forEach((snapshot) {});

        _myNotes!.sort((a, b) => a.createdTime.isAfter(b.createdTime) ? 0 : 1);
        _state = NotesState.loaded;
        update();
      }
    } catch (_) {
      _state = NotesState.error;
      update();
    }
  }

  ///[Method for Creating a New Note]
  Future<bool> createNewNote({
    required String title,
    required String description,
    File? image,
  }) async {
    final AuthProvider _authProvider = Get.find();
    final User? user = _authProvider.firebaseAuth.currentUser;
    String? userId = '';
    if (user != null) {
      userId = user.uid;
    } else {
      return false;
    }

    try {
      String imageUrl = '';

      if (image != null) {
        imageUrl = await _uploadFile(image: image, userId: userId);
      }

      final DocumentReference userDocument =
          _firestore.collection('users').doc(userId);

      final List<String> _searchParameters = [];
      final temp = StringBuffer();
      // String temp = "";

      for (int i = 0; i < title.trim().length; i++) {
        // temp += title[i];
        temp.write(title[i]);
        _searchParameters.add(temp.toString());
      }

      final Note newNote = Note(
        title: title.trim(),
        description: description.trim(),
        imagePath: imageUrl,
        createdTime: DateTime.now(),
        searchParameters: _searchParameters,
      );

      await userDocument.collection('notes').doc().set(Note.toJSON(newNote));
      fetchAllNotes();
      return true;
    } catch (_) {
      return false;
    }
  }

  ///[Method for Removing a Note]
  Future<bool> removeNote({required String noteId}) async {
    final AuthProvider _authProvider = Get.find();
    final User? user = _authProvider.firebaseAuth.currentUser;
    String? userId = '';
    if (user != null) {
      userId = user.uid;
    } else {
      return false;
    }

    try {
      final DocumentReference userDocument = _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(noteId);

      await userDocument.delete();
      fetchAllNotes();
      return true;
    } catch (_) {
      return false;
    }
  }

  ///[Method for Editing Note]
  Future<bool> editNote({required Note editedNote, File? image}) async {
    final AuthProvider _authProvider = Get.find();
    final User? user = _authProvider.firebaseAuth.currentUser;
    String? userId = '';
    if (user != null) {
      userId = user.uid;
    } else {
      return false;
    }

    try {
      final DocumentReference userDocument = _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(editedNote.id);

      String? imageUrl;
      if (image != null) {
        imageUrl = await _uploadFile(image: image, userId: userId);
      } else {
        imageUrl = editedNote.imagePath;
      }

      final List<String> _searchParameters = [];
      final temp = StringBuffer();
      // String temp = "";
      for (int i = 0; i < editedNote.title.trim().length; i++) {
        // temp += editedNote.title[i];
        temp.write(editedNote.title[i]);
        _searchParameters.add(temp.toString());
      }

      final Note newNote = Note(
        id: editedNote.id,
        title: editedNote.title,
        description: editedNote.description,
        imagePath: imageUrl,
        createdTime: editedNote.createdTime,
        searchParameters: _searchParameters,
      );

      userDocument.update(Note.toJSON(newNote));

      fetchAllNotes();
      return true;
    } catch (_) {
      return false;
    }
  }

  ///[Method for Seaching in Notes]
  Future<void> searchNotes({required String searchString}) async {
    try {
      _searchedNotes = [];
      _state = NotesState.searching;
      update();

      if (searchString.isEmpty) {
        _state = NotesState.loaded;
        update();
        return;
      }
      final AuthProvider _authProvider = Get.find();
      final User? user = _authProvider.firebaseAuth.currentUser;
      String? userId = '';
      if (user != null) {
        userId = user.uid;
      } else {
        return;
      }

      final List<DocumentSnapshot> documentList = (await _firestore
              .collection('users')
              .doc(userId)
              .collection('notes')
              .where('searchParameters', arrayContains: searchString)
              .get())
          .docs;

      if (documentList.isEmpty) {
        _state = NotesState.searchEmpty;
        update();
      } else {
        for (final snapshot in documentList) {
          final Map<String, dynamic>? data =
              snapshot.data() as Map<String, dynamic>?;
          final Note myNote = Note.fromJSON(data!, snapshot.id);
          _searchedNotes!.add(myNote);
        }

        // documentList.forEach((snapshot) {
        //   final Map<String, dynamic>? data =
        //       snapshot.data() as Map<String, dynamic>?;
        //   final Note myNote = Note.fromJSON(data!, snapshot.id);
        //   _searchedNotes!.add(myNote);
        // });

        _myNotes!.sort((a, b) => a.createdTime.isAfter(b.createdTime) ? 0 : 1);
        _state = NotesState.searched;
        update();
      }
    } catch (_) {
      _state = NotesState.error;
      update();
    }
  }

  ///[Method for Sharing Note]
  Future<Uri> shareNote({required String noteID}) async {
    final AuthProvider _authProvider = Get.find();
    final User? user = _authProvider.firebaseAuth.currentUser;
    String? userId = '';
    if (user != null) {
      userId = user.uid;
    } else {
      throw Exception;
    }

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://mynotess.page.link',
      link: Uri.parse(
          'https://mynotess.page.link.com/?id=$userId&noteId=$noteID'),
      androidParameters: AndroidParameters(
        packageName: 'com.example.my_notes',
        minimumVersion: 1,
      ),
    );
    final dynamicUrl = await parameters.buildUrl();

    return dynamicUrl;
  }

  ///[Method for displaying visited link]
  Future<void> retrieveDynamicLink(BuildContext context) async {
    try {
      final PendingDynamicLinkData? data =
          await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri? deepLink = data?.link;

      if (deepLink != null) {
        if (deepLink.queryParameters.containsKey('id')) {
          final String? senderID = deepLink.queryParameters['id'];
          final String? noteID = deepLink.queryParameters['noteId'];

          Note? fetchedNote;
          if (senderID != null && noteID != null) {
            fetchedNote = await fetchNoteById(userId: senderID, noteId: noteID);
          }

          locator.get<NavigationService>().navigateToNamed(
            viewNoteRoute,
            arguments: {'note': fetchedNote},
          );
        }
        return;
      }

      FirebaseDynamicLinks.instance.onLink(onSuccess: (
        PendingDynamicLinkData? dynamicLink,
      ) async {
        if (dynamicLink!.link.queryParameters.containsKey('id')) {
          final String? senderID = dynamicLink.link.queryParameters['id'];
          final String? noteID = dynamicLink.link.queryParameters['noteId'];
          Note? fetchedNote;

          if (senderID != null && noteID != null) {
            fetchedNote = await fetchNoteById(userId: senderID, noteId: noteID);
          }

          if (fetchedNote != null) {
            locator.get<NavigationService>().navigateToNamed(
              viewNoteRoute,
              arguments: {'note': fetchedNote},
            );
          } else {
            throw Exception;
          }
        }
      });
    } catch (e) {
      // print(e.toString());
    }
  }

  ///[Method to fetch a specific note by it's ID]
  Future<Note?> fetchNoteById(
      {required String userId, required String noteId}) async {
    try {
      final DocumentSnapshot documentSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(noteId)
          .get();

      Note? fetchedNote;
      if (documentSnapshot.data() != null) {
        final Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;
        fetchedNote = Note.fromJSON(data!, noteId);
      }

      return fetchedNote;
    } catch (_) {
      return null;
    }
  }

  ///[Method for uploading file to storage]
  Future<String> _uploadFile(
      {required File image, required String userId}) async {
    // String returnURL;
    final Reference storageReference = _firebaseStorage
        .ref()
        .child('images/$userId/${image.path.split('/').last}');
    final UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask;
    return storageReference.getDownloadURL();
    // returnURL = await storageReference.getDownloadURL();
    // return returnURL;
  }
}

enum NotesState {
  loading,
  loaded,
  noNotes,
  error,
  searching,
  searched,
  searchEmpty
}
