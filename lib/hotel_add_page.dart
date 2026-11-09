import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tourism_kg_alisa/signIn_signUp/registration_page.dart';

import 'models/place_model.dart';

class HotelAddPage extends StatefulWidget {
  final String? current_user_uid;

  const HotelAddPage({super.key, this.current_user_uid});

  @override
  State<HotelAddPage> createState() => _HotelAddPageState();
}

class _HotelAddPageState extends State<HotelAddPage> {
  final _placeNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _telContacts1Controller = TextEditingController();
  final _telContacts2Controller = TextEditingController();

  final List<File> _selectedImages = [];
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: const Text("Select from gallery (up to 6 photos)"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImagesFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.blue),
                  title: const Text("Take a photo with the camera"),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhotoWithCamera();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(limit: 6);
      if (pickedFiles.isNotEmpty) {
        setState(() {
          for (var pickedFile in pickedFiles) {
            if (_selectedImages.length < 6) {
              _selectedImages.add(File(pickedFile.path));
            }
          }
        });
        _showToast(
          "Photos have been selected! (Total: ${_selectedImages.length}/6)",
        );
      }
    } catch (e) {
      _showToast("Error when selecting a photo: $e");
    }
  }

  Future<void> _takePhotoWithCamera() async {
    if (_selectedImages.length >= 6) {
      _showToast("You have already selected the maximum of 6 photos");
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(File(pickedFile.path));
        });
        _showToast("Photo added! (Total: ${_selectedImages.length}/6)");
      }
    } catch (e) {
      _showToast("Error while working with the camera: $e");
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _addHotel() async {
    final String placeName = _placeNameController.text.trim();
    final String description = _descriptionController.text.trim();
    final String telContacts1 = _telContacts1Controller.text.trim();
    final String telContacts2 = _telContacts2Controller.text.trim();

    if (placeName.isEmpty ||
        description.isEmpty ||
        telContacts1.isEmpty ||
        telContacts2.isEmpty) {
      _showToast("Fill in all the fields");
      return;
    }

    if (_selectedImages.isEmpty) {
      _showToast("Add at least one photo of your hotel");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('You must be authorized to add a place.');
      }

      final ownerUid = currentUser.uid;

      List<String> imageUrls = [];

      for (int i = 0; i < _selectedImages.length; i++) {
        final fileName =
            'place_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

        final ref = FirebaseStorage.instance.ref().child(
          'place_models_images/$fileName',
        );

        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'ownerUid': ownerUid},
        );

        final uploadTask = await ref.putFile(_selectedImages[i], metadata);

        final downloadUrl = await uploadTask.ref.getDownloadURL();

        imageUrls.add(downloadUrl);
      }

      final placeModel = PlaceModel(
        id: DateTime.now().millisecondsSinceEpoch,
        place_name: placeName,
        description: description,
        images: imageUrls,
        tel_contacts: [
          telContacts1,
          telContacts2,
        ].where((c) => c.isNotEmpty).toList(),
        comments: [],
        rating: 0.0,
        owner_uid_user: ownerUid,
      );

      await FirebaseFirestore.instance
          .collection('place_models')
          .doc()
          .set(placeModel.toMap());

      _showToast("Отель успешно добавлен!");

      _placeNameController.clear();
      _descriptionController.clear();
      _telContacts1Controller.clear();
      _telContacts2Controller.clear();
      setState(() {
        _selectedImages.clear();
      });

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showToast("Error while adding: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _placeNameController.dispose();
    _descriptionController.dispose();
    _telContacts1Controller.dispose();
    _telContacts2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFDEEFFD),
        appBar: AppBar(
          title: const Text(
            "Add Your Hotel\nRelax Place",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFDEEFFD),
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 70, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  "Добавлять отели и места отдыха могут"
                  "\nзарегистрированные пользователи."
                  "\nRegistered users"
                  "\ncan add hotels and vacation spots.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegistrationPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text("Register / Log in"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFDEEFFD),
      appBar: AppBar(
        title: const Text("Add Hotel / Place"),
        centerTitle: true,
        backgroundColor: const Color(0xFFDEEFFD),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _placeNameController,
              decoration: const InputDecoration(
                hintText: "Name of your hotel or relax place",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: "Add point address and description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Please add contacts with prefix:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _telContacts1Controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: "Contact 1",
                prefixIcon: Icon(Icons.wifi_calling, color: Colors.green),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telContacts2Controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: "Contact 2",
                prefixIcon: Icon(Icons.telegram, color: Colors.blueAccent),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _selectedImages.length >= 3
                  ? null
                  : _showImageSourceDialog,
              icon: const Icon(Icons.add_a_photo),
              label: Text(
                _selectedImages.isEmpty
                    ? "Add photo (Gallery or Camera)"
                    : "Add more photos (${_selectedImages.length}/3)",
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 110,
              child: _selectedImages.isEmpty
                  ? Center(
                      child: Text(
                        "No photos selected",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(
                                  _selectedImages[index],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 6),

            _isLoading
                ? const CircularProgressIndicator()
                : IconButton(
                    iconSize: 60,
                    icon: const Icon(
                      Icons.add_circle,
                      color: Colors.lightBlueAccent,
                    ),
                    onPressed: _addHotel,
                  ),
          ],
        ),
      ),
    );
  }
}
