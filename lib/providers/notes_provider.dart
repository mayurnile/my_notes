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
      CollectionReference? collectionReference =
          _firestore.collection('users').doc('$userId').collection('notes');

      QuerySnapshot? queryData = await collectionReference.get();

      if (queryData.docs.length == 0) {
        _state = NotesState.NONOTES;
        update();
      } else {
        queryData.docs.forEach((snapshot) {
          Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>;
          Note? myNote = Note.fromJSON(data, snapshot.id);
          _myNotes!.add(myNote);
        });

        _myNotes!.sort((a, b) => a.createdTime.isAfter(b.createdTime) ? 0 : 1);
        _state = NotesState.LOADED;
        update();
      }
    } catch (_) {
      _state = NotesState.ERROR;
      update();
    }
  }

  ///[Method for Creating a New Note]
  Future<bool> createNewNote({
    required String title,
    required String description,
    File? image,
  }) async {
    AuthProvider _authProvider = Get.find();
    User? user = _authProvider.firebaseAuth.currentUser;
    String? userId = '';
    if (user != null) {
      userId = user.uid;
    } else {
      return false;
    }

    try {
      String imageUrl = '';

      if (image != null)
        imageUrl = await _uploadFile(image: image, userId: userId);

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

  ///[Method for Removing a Note]
  Future<bool> removeNote({required String noteId}) async {
    AuthProvider _authProvider = Get.find();
    User? user = _authProvider.firebaseAuth.currentUser;
    String? userId = '';
    if (user != null) {
      userId = user.uid;
    } else {
      return false;
    }

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

  ///[Method for Editing Note]
  Future<bool> editNote({required Note editedNote, File? image}) async {
    AuthProvider _authProvider = Get.find();
    User? user = _authProvider.firebaseAuth.currentUser;
    String? userId = '';
    if (user != null) {
      userId = user.uid;
    } else {
      return false;
    }

    try {
      DocumentReference? userDocument = _firestore
          .collection('users')
          .doc('$userId')
          .collection('notes')
          .doc('${editedNote.id}');

      String? imageUrl;
      if (image != null) {
        imageUrl = await _uploadFile(image: image, userId: userId);
      } else {
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

  ///[Method for Seaching in Notes]
  Future<void> searchNotes({required String searchString}) async {
    try {
      _searchedNotes = [];
      _state = NotesState.SEARCHING;
      update();

      if (searchString.length == 0) {
        _state = NotesState.LOADED;
        update();
        return;
      }
      AuthProvider _authProvider = Get.find();
      User? user = _authProvider.firebaseAuth.currentUser;
      String? userId = '';
      if (user != null) {
        userId = user.uid;
      } else {
        return;
      }

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
          Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>;
          Note myNote = Note.fromJSON(data, snapshot.id);
          _searchedNotes!.add(myNote);
        });

        _myNotes!.sort((a, b) => a.createdTime.isAfter(b.createdTime) ? 0 : 1);
        _state = NotesState.SEARCHED;
        update();
      }
    } catch (_) {
      _state = NotesState.ERROR;
      update();
    }
  }

  ///[Method for Sharing Note]
  Future<Uri> shareNote({required String noteID}) async {
    AuthProvider _authProvider = Get.find();
    User? user = _authProvider.firebaseAuth.currentUser;
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
    var dynamicUrl = await parameters.buildUrl();

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
          String? senderID = deepLink.queryParameters['id'];
          String? noteID = deepLink.queryParameters['noteId'];

          Note? fetchedNote;
          if (senderID != null && noteID != null)
            fetchedNote = await fetchNoteById(userId: senderID, noteId: noteID);

          locator.get<NavigationService>().navigateToNamed(
            VIEW_NOTE_ROUTE,
            arguments: {'note': fetchedNote},
          );
        }
        return;
      }

      FirebaseDynamicLinks.instance.onLink(onSuccess: (
        PendingDynamicLinkData? dynamicLink,
      ) async {
        if (dynamicLink!.link.queryParameters.containsKey('id')) {
          String? senderID = dynamicLink.link.queryParameters['id'];
          String? noteID = dynamicLink.link.queryParameters['noteId'];
          Note? fetchedNote;

          if (senderID != null && noteID != null)
            fetchedNote = await fetchNoteById(userId: senderID, noteId: noteID);

          if (fetchedNote != null)
            locator.get<NavigationService>().navigateToNamed(
              VIEW_NOTE_ROUTE,
              arguments: {'note': fetchedNote},
            );
          else
            throw Exception;
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  ///[Method to fetch a specific note by it's ID]
  Future<Note?> fetchNoteById(
      {required String userId, required String noteId}) async {
    try {
      DocumentSnapshot? documentSnapshot = await _firestore
          .collection('users')
          .doc('$userId')
          .collection('notes')
          .doc('$noteId')
          .get();

      Note? fetchedNote;
      if (documentSnapshot.data() != null) {
        Map<String, dynamic>? data =
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
    String returnURL;
    Reference storageReference = _firebaseStorage
        .ref()
        .child('images/$userId/${image.path.split('/').last}');
    UploadTask uploadTask = storageReference.putFile(image);
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
