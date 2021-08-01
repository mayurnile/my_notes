import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_notes/providers/notes_provider.dart';

import './notes_provider_test.mocks.dart';

// @GenerateMocks([Firebase])
@GenerateMocks([FirebaseFirestore])
@GenerateMocks([FirebaseStorage])
@GenerateMocks([CollectionReference])
@GenerateMocks([QuerySnapshot])
@GenerateMocks([DocumentReference])
@GenerateMocks(
  [],
  customMocks: [
    MockSpec<QueryDocumentSnapshot>(
      as: #MockQueryDocumentSnapshot,
      fallbackGenerators: {
        #data: queryDocumentSnapshot,
      },
      // returnNullOnMissingStub: true,
    )
  ],
)
void main() {
  setupFirebaseMocks();
  final MockFirebaseFirestore _firestore = MockFirebaseFirestore();
  // final MockFirebaseStorage _firebaseStorage = MockFirebaseStorage();
  final MockCollectionReference<Map<String, dynamic>> _mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
  final MockDocumentReference<Map<String, dynamic>> _mockDocumentReference = MockDocumentReference();
  final MockQuerySnapshot<Map<String, dynamic>> _mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
  final MockQueryDocumentSnapshot<Map<String, dynamic>> _mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();
  List<MockQueryDocumentSnapshot<Map<String, dynamic>>> _mockQueryDocuments;

  final NotesProvider _notesProvider = NotesProvider();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('Fetching List of Notes', () {
    test('should return all of notes', () async {
      //ARRANGE
      final Map<String, dynamic> responseMap = {
        "id": "id",
        "title": "title",
        "description": "description",
        "image_path": "",
        "created_time": "2021-04-22T16:19:10.343410",
      };
      const String _userId = 'userId';
      _mockQueryDocuments = [_mockQueryDocumentSnapshot];

      when(_firestore.collection(any)).thenReturn(_mockCollectionReference);
      when(_firestore.doc(_userId)).thenReturn(_mockDocumentReference);
      when(_mockCollectionReference.doc(any)).thenReturn(_mockDocumentReference);
      when(_mockDocumentReference.collection(any)).thenReturn(_mockCollectionReference);
      when(_mockCollectionReference.get()).thenAnswer((_) => Future.value(_mockQuerySnapshot));
      when(_mockQuerySnapshot.docs.isEmpty).thenReturn(false);
      when(_mockQuerySnapshot.docs).thenReturn(_mockQueryDocuments);
      when(_mockQueryDocumentSnapshot.data()).thenReturn(responseMap);
      when(_mockQueryDocumentSnapshot.id).thenReturn("id");

      //ACT
      await _notesProvider.fetchAllNotes(
        firestore: _firestore,
        userId: _userId,
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
        userId: _userId,
      );

      //ASSERT
      expect(_notesProvider.notesState, NotesState.error);
    });

    test('should return no notes when data is empty', () async {
      //ARRANGE
      final Map<String, dynamic> responseMap = {
        "id": "id",
        "title": "title",
        "description": "description",
        "image_path": "",
        "created_time": "2021-04-22T16:19:10.343410",
      };
      const String _userId = 'userId';
      _mockQueryDocuments = [];

      when(_firestore.collection(any)).thenReturn(_mockCollectionReference);
      when(_firestore.doc(_userId)).thenReturn(_mockDocumentReference);
      when(_mockCollectionReference.doc(any)).thenReturn(_mockDocumentReference);
      when(_mockDocumentReference.collection(any)).thenReturn(_mockCollectionReference);
      when(_mockCollectionReference.get()).thenAnswer((_) => Future.value(_mockQuerySnapshot));
      when(_mockQuerySnapshot.docs.isEmpty).thenReturn(true);
      when(_mockQuerySnapshot.docs).thenReturn(_mockQueryDocuments);
      when(_mockQueryDocumentSnapshot.data()).thenReturn(responseMap);
      when(_mockQueryDocumentSnapshot.id).thenReturn("id");

      //ACT
      await _notesProvider.fetchAllNotes(
        firestore: _firestore,
        userId: _userId,
      );

      //ASSERT
      expect(_notesProvider.notesState, NotesState.noNotes);
    });
  });

  group('Create New Note', () {
    test('should create a new note without image', () async {
      //ARRANGE
      const String _userID = 'userID';
      const String _title = 'title';
      const String _description = 'description';

      when(_firestore.collection(any)).thenReturn(_mockCollectionReference);
      when(_firestore.doc(_userID)).thenReturn(_mockDocumentReference);
      when(_mockCollectionReference.doc(any)).thenReturn(_mockDocumentReference);
      when(_mockDocumentReference.collection(any)).thenReturn(_mockCollectionReference);
      when(_mockDocumentReference.set(any)).thenAnswer((_) => Future.value(null));

      //ACT
      final bool result = await _notesProvider.createNewNote(
        firestore: _firestore,
        userId: _userID,
        title: _title,
        description: _description,
      );

      //ASSERT
      verify(_notesProvider.fetchAllNotes(firestore: _firestore, userId: _userID));
      expect(result, true);
    });

    test('should fail while creating a new note without image', () async {
      //ARRANGE
      const String _userID = 'userID';
      const String _title = 'title';
      const String _description = 'description';

      when(_firestore.collection(any)).thenThrow(Exception);
      // when(_firestore.doc(_userID)).thenReturn(_mockDocumentReference);
      // when(_mockCollectionReference.doc(any)).thenReturn(_mockDocumentReference);
      // when(_mockDocumentReference.collection(any)).thenReturn(_mockCollectionReference);
      // when(_mockDocumentReference.set(any)).thenAnswer((_) => Future.value(null));

      //ACT
      final bool result = await _notesProvider.createNewNote(
        firestore: _firestore,
        userId: _userID,
        title: _title,
        description: _description,
      );

      //ASSERT
      // verifyNever(_notesProvider.fetchAllNotes(firestore: _firestore, userId: _userID));
      expect(result, false);
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
