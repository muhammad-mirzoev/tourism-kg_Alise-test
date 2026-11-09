import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourism_kg_alisa/services/hotel_api_service.dart';

import 'components/place_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _apiPlaces = [];
  bool _isLoadingApi = true;

  @override
  void initState() {
    super.initState();
    _loadApiData();
  }

  Future<void> _loadApiData() async {
    try {
      final data = await HotelApiService().getAllHotels();
      if (mounted) {
        setState(() {
          _apiPlaces = data;
          _isLoadingApi = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingApi = false;
        });
      }
      debugPrint("API Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCEF2F8),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('place_models')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                _isLoadingApi) {
              return const Center(child: CircularProgressIndicator());
            }

            final List<Map<String, dynamic>> combinedPlaces = [];

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                data['doc_id'] = doc.id;
                combinedPlaces.add(data);
              }
            }

            if (combinedPlaces.isEmpty && _apiPlaces.isNotEmpty) {
              for (var place in _apiPlaces) {
                if (place is Map<String, dynamic>) {
                  combinedPlaces.add(place);
                }
              }
            }

            if (combinedPlaces.isEmpty) {
              return const Center(
                child: Text(
                  "Нет доступных отелей",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: combinedPlaces.length,
              itemBuilder: (context, index) {
                final place = combinedPlaces[index];
                return PlaceCard(placeModelData: place, uid: '');
              },
            );
          },
        ),
      ),
    );
  }
}
