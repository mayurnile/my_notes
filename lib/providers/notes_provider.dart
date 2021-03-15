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
  FirebaseFirestore _firestore;
  FirebaseStorage _firebaseStorage;
  List<Note> _myNotes = [];
  List<Note> _searchedNotes = [];
  NotesState _state;

  @override
  void onInit() {
    super.onInit();

    //initialize firebase
    _firestore = FirebaseFirestore.instance;
    _firebaseStorage = FirebaseStorage.instance;

    //initialize variables
    _myNotes = [];
    _searchedNotes = [];
    _state = NotesState.LOADING;
  }

  get myNotes => _myNotes;
  get notesState => _state;
  get searchedNotes => _searchedNotes;

  Future<void> fetchAllNotes() async {
    _myNotes = [];
    AuthProvider _authProvider = Get.find();
    User user = _authProvider.firebaseAuth.currentUser;
    String userId = user.uid;

    _state = NotesState.LOADING;
    update();

    try {
      CollectionReference collectionReference =
          _firestore.collection('users').doc('$userId').collection('notes');

      QuerySnapshot queryData = await collectionReference.get();

      if (queryData.docs.length == 0) {
        _state = NotesState.NONOTES;
        update();
      } else {
        queryData.docs.forEach((snapshot) {
          Map<String, dynamic> data = snapshot.data();
          Note myNote = Note.fromJSON(data, snapshot.id);
          _myNotes.add(myNote);
        });

        _myNotes.sort((a, b) => a.createdTime.isAfter(b.createdTime) ? 0 : 1);
        _state = NotesState.LOADED;
        update();
      }
    } catch (_) {
      _state = NotesState.ERROR;
      update();
    }
  }

  Future<bool> createNewNote(
    String title,
    String description,
    File image,
  ) async {
    AuthProvider _authProvider = Get.find();
    User user = _authProvider.firebaseAuth.currentUser;
    String userId = user.uid;
    try {
      String imageUrl;
      if (image != null) {
        imageUrl = await _uploadFile(image, userId);
      }

      DocumentReference userDocument =
          _firestore.collection('users').doc('$userId');

      List<String> _searchParameters = [];
      String temp = "";
      for (int i = 0; i < title.trim().length; i++) {
        temp += title[i];
        _searchParameters.add(temp);
      }

      Note newNote = Note(
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

  Future<bool> removeNote(String noteId) async {
    AuthProvider _authProvider = Get.find();
    User user = _authProvider.firebaseAuth.currentUser;
    String userId = user.uid;

    try {
      DocumentReference userDocument = _firestore
          .collection('users')
          .doc('$userId')
          .collection('notes')
          .doc('$noteId');

      await userDocument.delete();
      fetchAllNotes();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> editNote(Note editedNote, File image) async {
    AuthProvider _authProvider = Get.find();
    User user = _authProvider.firebaseAuth.currentUser;
    String userId = user.uid;

    try {
      DocumentReference userDocument = _firestore
          .collection('users')
          .doc('$userId')
          .collection('notes')
          .doc('${editedNote.id}');

      String imageUrl;
      if (image != null) {
        imageUrl = await _uploadFile(image, userId);
      } else if (editedNote.imagePath != null) {
        imageUrl = editedNote.imagePath;
      }

      List<String> _searchParameters = [];
      String temp = "";
      for (int i = 0; i < editedNote.title.trim().length; i++) {
        temp += editedNote.title[i];
        _searchParameters.add(temp);
      }

      Note newNote = Note(
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

  Future<void> searchNotes(String searchString) async {
    try {
      _state = NotesState.SEARCHING;
      update();

      AuthProvider _authProvider = Get.find();
      User user = _authProvider.firebaseAuth.currentUser;
      String userId = user.uid;

      List<DocumentSnapshot> documentList = (await _firestore
              .collection('users')
              .doc('$userId')
              .collection('notes')
              .where('searchParameters', arrayContains: searchString)
              .get())
          .docs;

      if (documentList.length == 0) {
        _state = NotesState.SEARCHEMPTY;
        update();
      } else {
        documentList.forEach((snapshot) {
          Map<String, dynamic> data = snapshot.data();
          Note myNote = Note.fromJSON(data, snapshot.id);
          _searchedNotes.add(myNote);
        });

        _myNotes.sort((a, b) => a.createdTime.isAfter(b.createdTime) ? 0 : 1);
        _state = NotesState.SEARCHED;
        update();
      }
    } catch (_) {
      _state = NotesState.ERROR;
      update();
    }
  }

  Future<Uri> shareNote(String noteID) async {
    AuthProvider _authProvider = Get.find();
    User user = _authProvider.firebaseAuth.currentUser;
    String userId = user.uid;

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://mynotess.page.link',
      link: Uri.parse(
          'https://mynotess.page.link.com/?id=$userId&noteId=$noteID'),
      androidParameters: AndroidParameters(
        packageName: 'com.example.my_notes',
        minimumVersion: 1,
      ),
    );
    var dynamicUrl = await parameters.buildUrl();

    return dynamicUrl;
  }

  Future<void> retrieveDynamicLink(BuildContext context) async {
    try {
      final PendingDynamicLinkData data =
          await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri deepLink = data?.link;

      if (deepLink != null) {
        if (deepLink.queryParameters.containsKey('id')) {
          String senderID = deepLink.queryParameters['id'];
          String noteID = deepLink.queryParameters['noteId'];

          Note fetchedNote = await fetchNoteById(senderID, noteID);

          locator.get<NavigationService>().navigateToNamed(
            VIEW_NOTE_ROUTE,
            arguments: {'note': fetchedNote},
          );
        }
        return;
      }

      FirebaseDynamicLinks.instance.onLink(onSuccess: (
        PendingDynamicLinkData dynamicLink,
      ) async {
        if (dynamicLink.link.queryParameters.containsKey('id')) {
          String senderID = dynamicLink.link.queryParameters['id'];
          String noteID = dynamicLink.link.queryParameters['noteId'];

          Note fetchedNote = await fetchNoteById(senderID, noteID);

          locator.get<NavigationService>().navigateToNamed(
            VIEW_NOTE_ROUTE,
            arguments: {'note': fetchedNote},
          );
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<Note> fetchNoteById(String userId, String noteId) async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('users')
          .doc('$userId')
          .collection('notes')
          .doc('$noteId')
          .get();

      Note fetchedNote = Note.fromJSON(documentSnapshot.data(), noteId);

      return fetchedNote;
    } catch (_) {
      return null;
    }
  }

  Future<String> _uploadFile(File _image, String userId) async {
    String returnURL;
    Reference storageReference = _firebaseStorage
        .ref()
        .child('images/$userId/${_image.path.split('/').last}');
    UploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask;
    returnURL = await storageReference.getDownloadURL();
    return returnURL;
  }
}

enum NotesState {
  LOADING,
  LOADED,
  NONOTES,
  ERROR,
  SEARCHING,
  SEARCHED,
  SEARCHEMPTY
}
