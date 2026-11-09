import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _db_persons = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _userData;

  UserModel? get userData => _userData;

  UserProvider() {
    _listenToUser();
  }

  void _listenToUser() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _userData = null;

        _db_persons.collection('user_persons').doc(user.uid).snapshots().listen(
          (snapshot) {
            if (snapshot.exists && snapshot.data() != null) {
              _userData = UserModel.fromMap(snapshot.data()!);
              notifyListeners();
            }
          },
        );
      } else {
        _userData = null;
        notifyListeners();
      }
    });
  }
}
