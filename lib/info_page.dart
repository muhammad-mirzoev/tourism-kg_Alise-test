import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'pdf_view_page.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  Future<void> _openEVisa() async {
    final uri = Uri.parse('https://www.evisa.e-gov.kg/');

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open eVisa website')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open eVisa website')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDEEFFD),

      appBar: AppBar(
        title: const Text(
          'Information for tourists',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFDEEFFD),
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Column(
        children: [
          // Ссылка на официальный портал eVisa
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: InkWell(
              onTap: _openEVisa,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent, width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.language, color: Colors.blue, size: 26),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Official Kyrgyzstan eVisa portal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'https://www.evisa.e-gov.kg/',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.open_in_new, color: Colors.blue, size: 20),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('pdf_documents')
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Error loading documents',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No PDF documents available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final documents = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: documents.length,

                  itemBuilder: (context, index) {
                    final data = documents[index].data();

                    final String title =
                        data['title']?.toString() ??
                        data['name']?.toString() ??
                        'PDF Document ${index + 1}';

                    final String description =
                        data['description']?.toString() ?? '';

                    final String pdfUrl =
                        data['url']?.toString() ??
                        data['pdf_url']?.toString() ??
                        data['download_url']?.toString() ??
                        '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),

                        leading: Container(
                          width: 50,
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                            size: 32,
                          ),
                        ),

                        title: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        subtitle: description.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(description),
                              )
                            : const Text('PDF document'),

                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.blue,
                        ),

                        onTap: () async {
                          if (pdfUrl.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'PDF link is missing in Firebase',
                                ),
                              ),
                            );
                            return;
                          }

                          try {
                            String downloadUrl;

                            if (pdfUrl.startsWith('gs://')) {
                              downloadUrl = await FirebaseStorage.instance
                                  .refFromURL(pdfUrl)
                                  .getDownloadURL();
                            } else {
                              downloadUrl = pdfUrl;
                            }

                            if (!context.mounted) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PdfViewPage(
                                  pdfUrl: downloadUrl,
                                  title: title,
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Cannot open PDF: $e')),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
