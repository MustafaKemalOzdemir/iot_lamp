/*
 ** Created by Mustafa Kemal ÖZDEMİR on 4.04.2022 **
*/
import 'package:flutter/material.dart';
import 'package:iot_playground/core/theme/app_colors.dart';

class DeviceModeButton extends StatelessWidget {
  final Function()? onTap;
  final String title;
  final String res;

  const DeviceModeButton({Key? key, required this.title, required this.res, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned(
                left: 24,
                right: 24,
                top: 24,
                bottom: 48,
                child: Image.asset(res, fit: BoxFit.contain),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: Text(
                  title,
                  style: const TextStyle(color: AppColors.lightBlue, fontWeight: FontWeight.w400, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
