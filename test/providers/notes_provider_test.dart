import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_notes/providers/notes_provider.dart';

import './notes_provider_test.mocks.dart';

@GenerateMocks([FirebaseFirestore])
@GenerateMocks([FirebaseStorage])
@GenerateMocks([CollectionReference])
@GenerateMocks([QuerySnapshot])
@GenerateMocks([DocumentReference])
@GenerateMocks([], customMocks: [
  MockSpec<QueryDocumentSnapshot>(
    as: #MockQueryDocumentSnapshot,
    fallbackGenerators: {#data: queryDocumentSnapshot},
  )
])
@GenerateMocks([Reference])
@GenerateMocks([UploadTask])
@GenerateMocks([TaskSnapshot])
void main() {
  setupFirebaseMocks();
  final MockFirebaseFirestore _firestore = MockFirebaseFirestore();
  final MockFirebaseStorage _firebaseStorage = MockFirebaseStorage();
  final MockCollectionReference<Map<String, dynamic>> _mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
  final MockDocumentReference<Map<String, dynamic>> _mockDocumentReference = MockDocumentReference();
  final MockQuerySnapshot<Map<String, dynamic>> _mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
  final MockQueryDocumentSnapshot<Map<String, dynamic>> _mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();
  List<MockQueryDocumentSnapshot<Map<String, dynamic>>> _mockQueryDocuments;
  final MockReference _mockReference = MockReference();
  final MockUploadTask _mockUploadTask = MockUploadTask();
  final MockTaskSnapshot _mockTaskSnapshot = MockTaskSnapshot();

  final NotesProvider _notesProvider = NotesProvider();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('fetchAllNotes', () {
    final Map<String, dynamic> responseMap = {
      "id": "id",
      "title": "title",
      "description": "description",
      "image_path": "",
      "created_time": "2021-04-22T16:19:10.343410",
    };
    const String _userId = 'userId';
    _mockQueryDocuments = [_mockQueryDocumentSnapshot];

    setUp(() {
      when(_firestore.collection(any)).thenReturn(_mockCollectionReference);
      when(_firestore.doc(_userId)).thenReturn(_mockDocumentReference);
      when(_mockCollectionReference.doc(any)).thenReturn(_mockDocumentReference);
      when(_mockDocumentReference.collection(any)).thenReturn(_mockCollectionReference);
      when(_mockCollectionReference.get()).thenAnswer((_) => Future.value(_mockQuerySnapshot));
      when(_mockQuerySnapshot.docs.isEmpty).thenReturn(false);
      when(_mockQuerySnapshot.docs).thenReturn(_mockQueryDocuments);
      when(_mockQueryDocumentSnapshot.data()).thenReturn(responseMap);
      when(_mockQueryDocumentSnapshot.id).thenReturn("id");
    });

    test('should return all of notes', () async {
      //ARRANGE
      _mockQueryDocuments = [_mockQueryDocumentSnapshot];

      //ACT
      await _notesProvider.fetchAllNotes(
        firestore: _firestore,
        userID: _userId,
      );

      //ASSERT
      expect(_notesProvider.notesState, NotesState.loaded);
    });

    test('should return exception while getting notes', () async {
      //ARRANGE
      const String _userId = 'userId';

      when(_firestore.collection(any)).thenThrow(Exception());

      //ACT
      await _notesProvider.fetchAllNotes(
        firestore: _firestore,
        userID: _userId,
      );

      //ASSERT
      expect(_notesProvider.notesState, NotesState.error);
    });

    test('should return no notes when data is empty', () async {
      //ARRANGE
      _mockQueryDocuments = [];
      when(_mockQuerySnapshot.docs).thenReturn(_mockQueryDocuments);

      //ACT
      await _notesProvider.fetchAllNotes(
        firestore: _firestore,
        userID: _userId,
      );

      //ASSERT
      expect(_notesProvider.notesState, NotesState.noNotes);
    });
  });

  group('createNewNote', () {
    const String _userID = 'userID';
    const String _title = 'title';
    const String _description = 'description';

    setUp(() {
      when(_firestore.collection(any)).thenReturn(_mockCollectionReference);
      when(_firestore.doc(_userID)).thenReturn(_mockDocumentReference);
      when(_mockCollectionReference.doc(any)).thenReturn(_mockDocumentReference);
      when(_mockDocumentReference.collection(any)).thenReturn(_mockCollectionReference);
      when(_mockDocumentReference.set(any)).thenAnswer((_) => Future.value(null));
    });

    test('should create a new note without image', () async {
      //ACT
      final bool result = await _notesProvider.createNewNote(
        firebaseStorage: _firebaseStorage,
        firestore: _firestore,
        userID: _userID,
        title: _title,
        description: _description,
      );

      //ASSERT
      verify(_notesProvider.fetchAllNotes(firestore: _firestore, userID: _userID));
      expect(result, true);
    });

    test('should fail while creating a new note without image', () async {
      //ARRANGE
      when(_firestore.collection(any)).thenThrow(Exception);

      //ACT
      final bool result = await _notesProvider.createNewNote(
        firebaseStorage: _firebaseStorage,
        firestore: _firestore,
        userID: _userID,
        title: _title,
        description: _description,
      );

      //ASSERT
      expect(result, false);
    });

    // test("should create a new note with image", () async {
    //   // arrange
    //   const String _imagePath = 'imagePath';
    //   const String _imageDownloadURL = 'downloadURL';
    //   final File _imageFile = File(_imagePath);
    //   // final _mockReference = _firebaseStorage.ref();

    //   when(_firebaseStorage.ref()).thenAnswer((_) => _mockReference);
    //   when(_mockReference.child('images/$_userID/$_imagePath')).thenAnswer((_) => _mockReference);
    //   when(_mockReference.putFile(_imageFile)).thenAnswer((_) => _mockUploadTask);
    //   // when(_mockReference.putFile(_imageFile)).thenReturn(_mockTaskSnapshot);
    //   when(_mockUploadTask);
    //   when(_mockReference.getDownloadURL()).thenAnswer((_) async => _imageDownloadURL);

    //   // act
    //   final result = await _notesProvider.createNewNote(
    //     firebaseStorage: _firebaseStorage,
    //     firestore: _firestore,
    //     userID: _userID,
    //     title: _title,
    //     description: _description,
    //     image: _imageFile,
    //   );

    //   // assert
    //   expect(result, true);
    //   // verify(_firebaseStorage.ref().child('images/$_userID/$_imagePath'));
    // });
  });

  group("uploadFile", () {
    const String _userID = 'userID';

    test("should return download url when file is uploaded successfully ", () async {
      // arrange
      const String _imagePath = 'imagePath';
      const String _imageDownloadURL = 'downloadURL';
      final File _imageFile = File(_imagePath);
      // final _mockReference = _firebaseStorage.ref();

      when(_firebaseStorage.ref()).thenAnswer((_) => _mockReference);
      when(_mockReference.child('images/$_userID/$_imagePath')).thenAnswer((_) => _mockReference);
      when(_mockReference.putFile(_imageFile)).thenAnswer((_) => _mockUploadTask);
      when(_mockUploadTask).thenAnswer((_) => _mockUploadTask);
      when(_mockReference.getDownloadURL()).thenAnswer((_) async => _imageDownloadURL);

      // act
      final result = await _notesProvider.uploadFile(
        firebaseStorage: _firebaseStorage,
        image: _imageFile,
        userId: _userID,
      );

      // assert
      expect(result, _imageDownloadURL);
    });
  });
}

///[Mocking QueryDocumentSnapshot.data() method]
Map<String, dynamic> queryDocumentSnapshot() {
  return {
    'id': "id",
    "title": "title",
    "description": "description",
    "image_path": "",
    "created_time": "2021-04-22T16:19:10.343410",
  };
}

///[Setting FirebaseApp for mocking purposes]
void setupFirebaseMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFirebase.channel.setMockMethodCallHandler((call) async {
    if (call.method == 'Firebase#initializeCore') {
      return [
        {
          'name': defaultFirebaseAppName,
          'options': {
            'apiKey': '123',
            'appId': '123',
            'messagingSenderId': '123',
            'projectId': '123',
          },
          'pluginConstants': {},
        }
      ];
    }

    if (call.method == 'Firebase#initializeApp') {
      return {
        'name': call.arguments['appName'],
        'options': call.arguments['options'],
        'pluginConstants': {},
      };
    }

    if (customHandlers != null) {
      customHandlers();
    }

    return null;
  });
}
