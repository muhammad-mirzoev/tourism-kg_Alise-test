import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddCommentCard extends StatefulWidget {
  final Map<String, dynamic>? placeModelData;

  const AddCommentCard({super.key, this.placeModelData});

  @override
  State<AddCommentCard> createState() => _AddCommentCardState();
}

class _AddCommentCardState extends State<AddCommentCard> {
  final TextEditingController _commentController = TextEditingController();
  double _userRating = 5.0;
  bool _isSubmitting = false;

  Future<void> _submitCommentAndRating() async {
    final String commentText = _commentController.text.trim();

    if (commentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пожалуйста, напишите комментарий")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final firestore = FirebaseFirestore.instance;
      DocumentReference? docRef;

      if (widget.placeModelData != null) {
        if (widget.placeModelData!['doc_id'] != null) {
          docRef = firestore
              .collection('place_models')
              .doc(widget.placeModelData!['doc_id'].toString());
        } else if (widget.placeModelData!['id'] != null) {
          final query = await firestore
              .collection('place_models')
              .where('id', isEqualTo: widget.placeModelData!['id'])
              .get();
          if (query.docs.isNotEmpty) {
            docRef = query.docs.first.reference;
          }
        } else if (widget.placeModelData!['place_name'] != null) {
          final query = await firestore
              .collection('place_models')
              .where(
                'place_name',
                isEqualTo: widget.placeModelData!['place_name'],
              )
              .get();
          if (query.docs.isNotEmpty) {
            docRef = query.docs.first.reference;
          }
        }
      }

      if (docRef != null) {
        final snapshot = await docRef.get();
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;

          List<dynamic> comments = data['comments'] is List
              ? List.from(data['comments'])
              : [];
          List<dynamic> ratings = data['ratings'] is List
              ? List.from(data['ratings'])
              : [];

          comments.add(commentText);
          ratings.add(_userRating);

          double totalSum = ratings.fold(
            0.0,
            (prev, elem) => prev + (elem as num).toDouble(),
          );
          double avgRating = totalSum / ratings.length;
          avgRating = double.parse(avgRating.toStringAsFixed(1));

          await docRef.update({
            'comments': comments,
            'ratings': ratings,
            'rating': avgRating,
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ваш отзыв и оценка добавлены!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Ошибка при отправке: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placeName =
        widget.placeModelData?['place_name'] ?? 'Отель / Место отдыха';
    final double currentRating =
        (widget.placeModelData?['rating'] as num?)?.toDouble() ?? 0.0;
    final int filledStars = currentRating.round().clamp(0, 5);

    return Scaffold(
      backgroundColor: const Color(0xFFDEEFFD),
      appBar: AppBar(
        title: const Text("Оставить отзыв и рейтинг"),
        backgroundColor: const Color(0xFFDEEFFD),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.lightBlue, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                placeName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 6),

              Row(
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        size: 20,
                        color: index < filledStars
                            ? Colors.amber
                            : Colors.grey[400],
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${currentRating.toStringAsFixed(1)} / 5.0",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                "Поставьте вашу оценку:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  final bool isFilled = starValue <= _userRating;
                  return IconButton(
                    iconSize: 36,
                    icon: Icon(
                      Icons.star,
                      color: isFilled ? Colors.amber : Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() {
                        _userRating = starValue.toDouble();
                      });
                    },
                  );
                }),
              ),
              Center(
                child: Text(
                  "${_userRating.toInt()} / 5 ★",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Ваш комментарий:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _commentController,
                maxLines: 4,
                style: const TextStyle(fontSize: 14, color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Напишите ваши впечатления...",
                  filled: true,
                  fillColor: const Color(0xFFBDE1F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _submitCommentAndRating,
                        icon: const Icon(Icons.send),
                        label: const Text(
                          "Отправить отзыв",
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
