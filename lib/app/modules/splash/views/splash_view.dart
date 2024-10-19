import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lelang_fb/core/assets/assets.gen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/color.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});
  @override
 Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.svg.logoLelang.svg(),
            const SizedBox(
              height: 15,
            ),
            Text(
              "Bid & Win It!",
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AppColors.hijauTua,
                  shadows: [
                    Shadow(
                        color: const Color.fromARGB(25, 0, 0, 0),
                        offset: Offset(1, 1),
                        blurRadius: 1)
                  ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppColors.hijauTua,
          ),
          SizedBox(
            height: 16,
          ),
          BottomAppBar(
            color: AppColors.hijauTua,
            child: Center(
              child: Text(
                'LeLang Application v1.0',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
