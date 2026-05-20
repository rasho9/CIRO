import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Simulate loading then navigate to dashboard
    Future.delayed(const Duration(seconds: 3), () {
      // Using GoRouter navigation – will be injected later
      // context.go('/home'); // cannot use context in initState directly, use addPostFrameCallback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacementNamed('/home');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flash_on, size: 120, color: AppColors.teal)
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(duration: 800.ms, begin: 0.5, end: 1.0),
            const SizedBox(height: 24),
            const Text('CIRO', style: TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold))
                .animate()
                .slideY(begin: 0.5, end: 0, duration: 600.ms)
                .fadeIn(duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
