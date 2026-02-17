import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/number_limits.dart';
import 'package:thinkcreative_technologies/Services/firebase_services/FirebaseApi.dart';

//  _________ CUSTOMER ____________
class FirestoreDataProviderCUSTOMERS extends ChangeNotifier {
  final _datalistSnapshot = <DocumentSnapshot>[];
  String _errorMessage = '';
  bool _hasNext = true;
  bool _isFetchingData = false;

  String get errorMessage => _errorMessage;

  bool get hasNext => _hasNext;

  List get recievedDocs => _datalistSnapshot.map((snap) {
        final recievedData = snap.data();

        return recievedData;
      }).toList();

  reset() {
    _hasNext = true;
    _datalistSnapshot.clear();
    _isFetchingData = false;
    _errorMessage = '';
    recievedDocs.clear();
    notifyListeners();
  }

  Future fetchNextData(
      String? dataType, Query? refdataa, bool isAfterNewdocCreated) async {
    if (_isFetchingData) return;

    _errorMessage = '';
    _isFetchingData = true;

    try {
      final snap = isAfterNewdocCreated == true
          ? await FirebaseApi.getFirestoreCOLLECTIONData(
              Numberlimits.totalDatatoLoadAtOnceFromFirestore,
              // startAfter: null,
              refdata: refdataa)
          : await FirebaseApi.getFirestoreCOLLECTIONData(
              Numberlimits.totalDatatoLoadAtOnceFromFirestore,
              startAfter:
                  _datalistSnapshot.isNotEmpty ? _datalistSnapshot.last : null,
              refdata: refdataa);
      if (isAfterNewdocCreated == true) {
        _datalistSnapshot.clear();
        _datalistSnapshot.addAll(snap.docs);
      } else {
        _datalistSnapshot.addAll(snap.docs);
      }
      // notifyListeners();
      if (snap.docs.length < Numberlimits.totalDatatoLoadAtOnceFromFirestore)
        _hasNext = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }

    _isFetchingData = false;
  }

  updateparticulardocinProvider(
      {required CollectionReference colRef,
      required String userid,
      required Function(DocumentSnapshot user) onfetchDone}) async {
    int index =
        _datalistSnapshot.indexWhere((prod) => prod[Dbkeys.id] == userid);
    await colRef.doc(userid).get().then((value) {
      _datalistSnapshot.removeAt(index);
      _datalistSnapshot.insert(index, value);
      notifyListeners();
      onfetchDone(value);
    });
  }

  deleteparticulardocinProvider({
    String? collection,
    String? document,
    String? compareKey,
    String? compareVal,
    GlobalKey? scaffoldkey,
    GlobalKey? keyloader,
    BuildContext? context,
  }) async {
    int index =
        _datalistSnapshot.indexWhere((prod) => prod[compareKey!] == compareVal);

    _datalistSnapshot.removeAt(index);
    notifyListeners();
  }
}

//  _________ AGENTS ____________
class FirestoreDataProviderAGENTS extends ChangeNotifier {
  final _datalistSnapshot = <DocumentSnapshot>[];
  String _errorMessage = '';
  bool _hasNext = true;
  bool _isFetchingData = false;

  String get errorMessage => _errorMessage;

  bool get hasNext => _hasNext;

  List get recievedDocs => _datalistSnapshot.map((snap) {
        final recievedData = snap.data();

        return recievedData;
      }).toList();

  reset() {
    _hasNext = true;
    _datalistSnapshot.clear();
    _isFetchingData = false;
    _errorMessage = '';
    recievedDocs.clear();
    notifyListeners();
  }

  Future fetchNextData(
      String? dataType, Query? refdataa, bool isAfterNewdocCreated) async {
    if (_isFetchingData) return;

    _errorMessage = '';
    _isFetchingData = true;

    try {
      final snap = isAfterNewdocCreated == true
          ? await FirebaseApi.getFirestoreCOLLECTIONData(
              Numberlimits.totalDatatoLoadAtOnceFromFirestore,
              // startAfter: null,
              refdata: refdataa)
          : await FirebaseApi.getFirestoreCOLLECTIONData(
              Numberlimits.totalDatatoLoadAtOnceFromFirestore,
              startAfter:
                  _datalistSnapshot.isNotEmpty ? _datalistSnapshot.last : null,
              refdata: refdataa);
      if (isAfterNewdocCreated == true) {
        _datalistSnapshot.clear();
        _datalistSnapshot.addAll(snap.docs);
      } else {
        _datalistSnapshot.addAll(snap.docs);
      }
      // notifyListeners();
      if (snap.docs.length < Numberlimits.totalDatatoLoadAtOnceFromFirestore)
        _hasNext = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }

    _isFetchingData = false;
  }

  updateparticulardocinProvider(
      {required CollectionReference colRef,
      required String userid,
      required Function(DocumentSnapshot user) onfetchDone}) async {
    int index =
        _datalistSnapshot.indexWhere((prod) => prod[Dbkeys.id] == userid);
    await colRef.doc(userid).get().then((value) {
      _datalistSnapshot.removeAt(index);
      _datalistSnapshot.insert(index, value);
      notifyListeners();
      onfetchDone(value);
    });
  }

  deleteparticulardocinProvider({
    String? collection,
    String? document,
    String? compareKey,
    String? compareVal,
    GlobalKey? scaffoldkey,
    GlobalKey? keyloader,
    BuildContext? context,
  }) async {
    int index =
        _datalistSnapshot.indexWhere((prod) => prod[compareKey!] == compareVal);

    _datalistSnapshot.removeAt(index);
    notifyListeners();
  }
}

//  _________ CALL HISTORY ____________
class FirestoreDataProviderCALLHISTORY extends ChangeNotifier {
  final _datalistSnapshot = <DocumentSnapshot>[];
  String _errorMessage = '';
  bool _hasNext = true;
  bool _isFetchingData = false;

  String get errorMessage => _errorMessage;

  bool get hasNext => _hasNext;

  List get recievedDocs => _datalistSnapshot.map((snap) {
        final recievedData = snap.data();

        return recievedData;
      }).toList();

  Future fetchNextData(
      String? dataType, Query? refdataa, bool isAfterNewdocCreated) async {
    if (_isFetchingData) return;

    _errorMessage = '';
    _isFetchingData = true;

    try {
      final snap = isAfterNewdocCreated == true
          ? await FirebaseApi.getFirestoreCOLLECTIONData(
              Numberlimits.totalDatatoLoadAtOnceFromFirestore,
              // startAfter: null,
              refdata: refdataa)
          : await FirebaseApi.getFirestoreCOLLECTIONData(
              Numberlimits.totalDatatoLoadAtOnceFromFirestore,
              startAfter:
                  _datalistSnapshot.isNotEmpty ? _datalistSnapshot.last : null,
              refdata: refdataa);
      if (isAfterNewdocCreated == true) {
        _datalistSnapshot.clear();
        _datalistSnapshot.addAll(snap.docs);
      } else {
        _datalistSnapshot.addAll(snap.docs);
      }
      // notifyListeners();
      if (snap.docs.length < Numberlimits.totalDatatoLoadAtOnceFromFirestore)
        _hasNext = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }

    _isFetchingData = false;
  }

  updateparticulardocinProvider({
    required String collection,
    String? document,
    String? compareKey,
    String? compareVal,
    GlobalKey? scaffoldkey,
    BuildContext? context,
  }) async {
    int index =
        _datalistSnapshot.indexWhere((prod) => prod[compareKey!] == compareVal);
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(document)
        .get()
        .then((value) {
      _datalistSnapshot.removeAt(index);
      _datalistSnapshot.insert(index, value);
      notifyListeners();
    });
  }

  deleteparticulardocinProvider({
    String? collection,
    String? document,
    String? compareKey,
    String? compareVal,
    GlobalKey? scaffoldkey,
    GlobalKey? keyloader,
    BuildContext? context,
  }) async {
    int index =
        _datalistSnapshot.indexWhere((prod) => prod[compareKey!] == compareVal);

    _datalistSnapshot.removeAt(index);
    notifyListeners();
  }
}

//  _________ REPORTS ____________
class FirestoreDataProviderREPORTS extends ChangeNotifier {
  final _datalistSnapshot = <DocumentSnapshot>[];
  String _errorMessage = '';
  bool _hasNext = true;
  bool _isFetchingData = false;

  String get errorMessage => _errorMessage;

  bool get hasNext => _hasNext;

  List get recievedDocs => _datalistSnapshot.map((snap) {
        final recievedData = snap.data();

        return recievedData;
      }).toList();

  reset() {
    _hasNext = true;
    _datalistSnapshot.clear();
    _isFetchingData = false;
    _errorMessage = '';
    recievedDocs.clear();
    notifyListeners();
  }

  Future fetchNextData(
      String? dataType, Query? refdataa, bool isAfterNewdocCreated) async {
    if (_isFetchingData) return;

    _errorMessage = '';
    _isFetchingData = true;

    try {
      final snap = isAfterNewdocCreated == true
          ? await FirebaseApi.getFirestoreCOLLECTIONData(
              Numberlimits.totalDatatoLoadAtOnceFromFirestore,
              // startAfter: null,
              refdata: refdataa)
          : await FirebaseApi.getFirestoreCOLLECTIONData(
              Numberlimits.totalDatatoLoadAtOnceFromFirestore,
              startAfter:
                  _datalistSnapshot.isNotEmpty ? _datalistSnapshot.last : null,
              refdata: refdataa);
      if (isAfterNewdocCreated == true) {
        _datalistSnapshot.clear();
        _datalistSnapshot.addAll(snap.docs);
      } else {
        _datalistSnapshot.addAll(snap.docs);
      }
      // notifyListeners();
      if (snap.docs.length < Numberlimits.totalDatatoLoadAtOnceFromFirestore)
        _hasNext = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }

    _isFetchingData = false;
  }

  updateparticulardocinProvider({
    required String collection,
    String? document,
    String? compareKey,
    String? compareVal,
    GlobalKey? scaffoldkey,
    BuildContext? context,
  }) async {
    int index =
        _datalistSnapshot.indexWhere((prod) => prod[compareKey!] == compareVal);
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(document)
        .get()
        .then((value) {
      _datalistSnapshot.removeAt(index);
      _datalistSnapshot.insert(index, value);
      notifyListeners();
    });
  }

  deleteparticulardocinProvider({
    required String compareKey,
    required int compareVal,
  }) async {
    int index =
        _datalistSnapshot.indexWhere((prod) => prod[compareKey] == compareVal);

    _datalistSnapshot.removeAt(index);
    notifyListeners();
  }
}

//  _________ CHAT MESSAGE - AGENT CHAT< GROUP CHAT< BROADCAST ____________
class FirestoreDataProviderCHATMESSAGES extends ChangeNotifier {
  final _datalistSnapshot = <DocumentSnapshot>[];
  String _errorMessage = '';
  bool _hasNext = true;
  bool isFetchingData = false;
  StreamSubscription? _subscription;

  String get errorMessage => _errorMessage;

  bool get hasNext => _hasNext;

  List get recievedDocs => _datalistSnapshot.map((snap) {
        final recievedData = snap.data();

        return recievedData;
      }).toList();

  reset() {
    _subscription?.cancel();
    _hasNext = true;
    _datalistSnapshot.clear();
    isFetchingData = false;
    _errorMessage = '';
    notifyListeners();
  }

  Future fetchNextData(
      String? dataType, Query? refdataa, bool isAfterNewdocCreated) async {
    if (isFetchingData) return;

    _errorMessage = '';
    isFetchingData = true;

    try {
      final snap = isAfterNewdocCreated == true
          ? await FirebaseApi.getFirestoreCOLLECTIONData(
              Numberlimits.totalDatatoLoadAtOnceFromFirestore,
              refdata: refdataa)
          : await FirebaseApi.getFirestoreCOLLECTIONData(
              Numberlimits.totalDatatoLoadAtOnceFromFirestore,
              startAfter:
                  _datalistSnapshot.isNotEmpty ? _datalistSnapshot.last : null,
              refdata: refdataa);
      if (isAfterNewdocCreated == true) {
        _datalistSnapshot.clear();
        _datalistSnapshot.addAll(snap.docs);
      } else {
        // Avoid duplicates if listener is also running
        for (var doc in snap.docs) {
          if (!_datalistSnapshot.any((element) => element.id == doc.id)) {
            _datalistSnapshot.add(doc);
          }
        }
      }
      if (snap.docs.length < Numberlimits.totalDatatoLoadAtOnceFromFirestore)
        _hasNext = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }

    isFetchingData = false;
  }

  void startListening(Query query) {
    print('🟢 FirestoreDataProviderCHATMESSAGES - startListening called');
    _subscription?.cancel();
    _subscription = query.snapshots().listen((snapshot) {
      print('🟢 FirestoreDataProviderCHATMESSAGES - Received snapshot with ${snapshot.docChanges.length} changes');
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          if (!_datalistSnapshot.any((element) => element.id == change.doc.id)) {
            _datalistSnapshot.insert(0, change.doc);
            print('🟢 Added new message: ${change.doc.id}');
          } else {
            print('🟡 Skipped duplicate message: ${change.doc.id}');
          }
        } else if (change.type == DocumentChangeType.modified) {
          int index = _datalistSnapshot
              .indexWhere((element) => element.id == change.doc.id);
          if (index != -1) {
            _datalistSnapshot[index] = change.doc;
            print('🟢 Modified message at index $index: ${change.doc.id}');
          }
        } else if (change.type == DocumentChangeType.removed) {
          _datalistSnapshot
              .removeWhere((element) => element.id == change.doc.id);
          print('🟢 Removed message: ${change.doc.id}');
        }
      }
      print('🟢 Total messages in list: ${_datalistSnapshot.length}');
      notifyListeners();
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  updateparticulardocinProvider(
      {required CollectionReference colRef,
      required String userid,
      required Function(DocumentSnapshot user) onfetchDone}) async {
    int index =
        _datalistSnapshot.indexWhere((prod) => prod[Dbkeys.id] == userid);
    await colRef.doc(userid).get().then((value) {
      if (index != -1) {
        _datalistSnapshot.removeAt(index);
        _datalistSnapshot.insert(index, value);
      }
      notifyListeners();
      onfetchDone(value);
    });
  }

  deleteparticulardocinProvider({
    String? collection,
    String? document,
    String? compareKey,
    String? compareVal,
    GlobalKey? scaffoldkey,
    GlobalKey? keyloader,
    BuildContext? context,
  }) async {
    _datalistSnapshot.removeWhere((element) {
      final data = element.data() as Map<String, dynamic>?;
      return data != null && data[compareKey!] == compareVal;
    });
    notifyListeners();
  }
}
