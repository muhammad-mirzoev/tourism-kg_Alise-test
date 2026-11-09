import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../app_navigation.dart';

class PlaceCard extends StatelessWidget {
  final Map<String, dynamic> placeModelData;
  final String uid;

  const PlaceCard({super.key, required this.placeModelData, required this.uid});

  @override
  Widget build(BuildContext context) {
    String imageUrl = '';
    if (placeModelData['images'] is List &&
        (placeModelData['images'] as List).isNotEmpty) {
      imageUrl = placeModelData['images'][0].toString();
    }

    final double rating = (placeModelData['rating'] as num?)?.toDouble() ?? 0.0;
    final int filledStars = rating.round().clamp(0, 5);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppNavigation.place_detail_card,
          arguments: {'placeModelData': placeModelData, 'uid': uid},
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.lightBlue, width: 1),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )
                  : Container(
                      height: 90,
                      width: 90,
                      color: Colors.grey[300],
                      child: const Icon(Icons.hotel, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    placeModelData['place_name'] ?? 'NO NAMED PLACE',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
                      const SizedBox(width: 6),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
