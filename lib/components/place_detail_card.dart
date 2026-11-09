import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tourism_kg_alisa/components/view_all_photos_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_navigation.dart';

class PlaceDetailCard extends StatelessWidget {
  final Map<String, dynamic> placeModelData;
  final String uid;

  const PlaceDetailCard({
    super.key,
    required this.placeModelData,
    required this.uid,
  });

  List<String> _getValidImages() {
    if (placeModelData['images'] is List) {
      return (placeModelData['images'] as List)
          .map((img) => img.toString().trim())
          .where((img) => img.isNotEmpty)
          .toList();
    }
    return [];
  }

  String _getContact(int index) {
    if (placeModelData['tel_contacts'] is List) {
      final List contacts = placeModelData['tel_contacts'];
      if (index >= 0 && index < contacts.length) {
        return contacts[index].toString();
      }
    }
    return '';
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final contact = _getContact(0).trim();
    final phone = contact.replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.length < 8 || phone.length > 15 || phone.startsWith('0')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp number is not valid')),
      );
      return;
    }

    final uri = Uri.parse('https://wa.me/$phone');

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp could not be opened')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp could not be opened')),
        );
      }
    }
  }

  Future<void> _openTelegram(BuildContext context) async {
    final contact = _getContact(1).trim();
    String username = contact;

    if (contact.startsWith('http://') || contact.startsWith('https://')) {
      final uri = Uri.tryParse(contact);

      if (uri == null ||
          ![
            't.me',
            'www.t.me',
            'telegram.me',
            'www.telegram.me',
          ].contains(uri.host.toLowerCase()) ||
          uri.hasQuery ||
          uri.hasFragment ||
          uri.pathSegments.length != 1) {
        _showTelegramError(context);
        return;
      }

      username = uri.pathSegments.first;
    } else {
      username = contact.startsWith('@') ? contact.substring(1) : contact;
    }

    final validUsername = RegExp(r'^[a-zA-Z0-9_]{5,32}$').hasMatch(username);

    if (!validUsername) {
      _showTelegramError(context);
      return;
    }

    final telegramUri = Uri.https('t.me', '/$username');

    try {
      final opened = await launchUrl(
        telegramUri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        _showTelegramError(context);
      }
    } catch (e) {
      if (context.mounted) {
        _showTelegramError(context);
      }
    }
  }

  void _showTelegramError(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Telegram link is not valid')));
  }

  @override
  Widget build(BuildContext context) {
    final List comments = placeModelData['comments'] is List
        ? placeModelData['comments']
        : [];

    final double rating = (placeModelData['rating'] as num?)?.toDouble() ?? 0.0;
    final int filledStars = rating.round().clamp(0, 5);
    final List<String> validImages = _getValidImages();

    return Scaffold(
      backgroundColor: const Color(0xFFDEEFFD),
      appBar: AppBar(
        title: Text(placeModelData['place_name'] ?? 'Детали отеля'),
        backgroundColor: const Color(0xFFDEEFFD),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.lightBlue, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
                child: validImages.isEmpty
                    ? Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.hotel,
                          color: Colors.grey,
                          size: 40,
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: validImages.length,
                        itemBuilder: (context, index) {
                          final imgUrl = validImages[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewAllPhotosPage(
                                      images: validImages,
                                      initialIndex: index,
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedNetworkImage(
                                  imageUrl: imgUrl,
                                  height: 90,
                                  width: 90,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 12),

              Text(
                placeModelData['place_name'] ?? 'NO NAMED PLACE',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 6),

              Row(
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        size: 24,
                        color: index < filledStars
                            ? Colors.amber
                            : Colors.grey[400],
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${rating.toStringAsFixed(1)} / 5.0",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_getContact(0).isNotEmpty)
                InkWell(
                  onTap: () => _openWhatsApp(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/whatsapp.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (ctx, err, stack) =>
                              const Icon(Icons.phone, color: Colors.green),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getContact(0),
                          style: const TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              if (_getContact(1).isNotEmpty)
                InkWell(
                  onTap: () => _openTelegram(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/telegram.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (ctx, err, stack) =>
                              const Icon(Icons.send, color: Colors.blue),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getContact(1),
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Address\nDescription: ",
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "${placeModelData['description'] ?? ''}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Divider(),

              const Text(
                "Comments: ",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              comments.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "No reviews yet. Be the first to write one!",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final itemComment = comments[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: const Color(0xFFF0F8FF),
                          child: ListTile(
                            leading: const Icon(
                              Icons.comment,
                              color: Colors.blue,
                            ),
                            title: Text(itemComment.toString()),
                          ),
                        );
                      },
                    ),

              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppNavigation.add_comment,
                      arguments: {'placeModelData': placeModelData},
                    );
                  },
                  icon: const Icon(Icons.add_comment),
                  label: const Text('Add comment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
