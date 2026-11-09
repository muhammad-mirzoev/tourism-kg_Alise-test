import 'package:flutter/material.dart';

import 'app_navigation.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppNavigation.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAFDCED),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 160,
              backgroundImage: const AssetImage(
                'assets/images/ala_kol_image.jpg',
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'TOUR GIDE KG',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF082890),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.indigo),
          ],
        ),
      ),
    );
  }
}
