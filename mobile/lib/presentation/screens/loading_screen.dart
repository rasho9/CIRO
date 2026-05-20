import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            // Lottie animation (you can replace with any cinematic asset)
            LottieBuilder.asset('assets/animations/cinematic_loading.json',
                width: 200, height: 200, repeat: true),
            SizedBox(height: 20),
            Text('Booting CIRO Core…',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}
