import 'package:flutter/material.dart';
import 'package:tourism_kg_alisa/pdf_view_page.dart';
import 'package:tourism_kg_alisa/splash_page.dart';

import 'components/add_comment_card.dart';
import 'components/place_detail_card.dart';
import 'hotel_add_page.dart';
import 'info_page.dart';
import 'main_screen.dart';

class AppNavigation {
  static const String splash = '/';
  static const String home = '/home_page';
  static const String info_page = '/info_page';
  static const String place_detail_card = '/place_detail_card';
  static const String add_hotel_page = '/add_hotel_page';
  static const String add_comment = '/add_comment';
  static const String pdf_view_page = '/pdf_view_page';
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case home:
        return MaterialPageRoute(builder: (_) => MainScreen());

      case info_page:
        return MaterialPageRoute(builder: (_) => const InfoPage());
      case place_detail_card:
        final args = (settings.arguments as Map<String, dynamic>?) ?? {};
        return MaterialPageRoute(
          builder: (_) => PlaceDetailCard(
            placeModelData: args['placeModelData'],
            uid: args['uid'] ?? '',
          ),
        );
      case add_comment:
        final args = (settings.arguments as Map<String, dynamic>?) ?? {};
        return MaterialPageRoute(
          builder: (_) =>
              AddCommentCard(placeModelData: args['placeModelData']),
        );
      case add_hotel_page:
        return MaterialPageRoute(builder: (_) => HotelAddPage());
      case pdf_view_page:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PdfViewPage(
            pdfUrl: args['pdfUrl'],
            title: args['title'] ?? 'PDF Document',
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => MainScreen());
    }
  }
}
