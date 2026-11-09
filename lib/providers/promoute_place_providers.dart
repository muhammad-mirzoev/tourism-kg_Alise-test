import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/place_model.dart';

class PromotePaceProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addPlaceModel(PlaceModel placeModel) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Authorization required');
    }

    if (placeModel.owner_uid_user != user.uid) {
      throw Exception('Invalid place owner');
    }

    try {
      await _db
          .collection('place_models')
          .doc(placeModel.id.toString())
          .set(placeModel.toMap());

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding place model: $e');
      rethrow;
    }
  }

  Future<void> deletePlaceModel(String placeModelId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Authorization required');
    }

    try {
      final docRef = _db.collection('place_models').doc(placeModelId);

      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        throw Exception('Place model not found');
      }

      final data = snapshot.data()!;

      if (data['owner_uid_user'] != user.uid) {
        throw Exception('You can only delete your own place models');
      }

      await docRef.delete();

      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting place model: $e');
      rethrow;
    }
  }

  Future<void> updatePlaceModel(
    String placeModelId,
    PlaceModel placeModel,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Authorization required');
    }

    try {
      final docRef = _db.collection('place_models').doc(placeModelId);

      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        throw Exception('Place model not found');
      }

      final data = snapshot.data()!;

      if (data['owner_uid_user'] != user.uid) {
        throw Exception('You can only edit your own place models');
      }

      if (placeModel.owner_uid_user != user.uid) {
        throw Exception('Invalid place owner');
      }

      await docRef.update(placeModel.toMap());

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating place model: $e');
      rethrow;
    }
  }
}
