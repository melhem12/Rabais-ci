import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? textColor;
  final Color? iconColor;

  const LogoWidget({
    super.key,
    this.size = 120,
    this.showText = true,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = this.textColor ?? (isDark ? AppTheme.white : AppTheme.primaryTurquoise);
    final iconColor = this.iconColor ?? AppTheme.primaryOrange;

    return Container(
      width: size,
      height: size * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Branded logo image
          SizedBox(
            width: size * 0.8,
            height: size * 0.4,
            child: Image.asset(
              'assets/icons/mylogo.png',
              fit: BoxFit.contain,
            ),
          ),
          if (showText) ...[
            const SizedBox(height: 8),
            // App name
            Text(
              'Rabaisci',
              style: TextStyle(
                color: textColor,
                fontSize: size * 0.12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            // Tagline
            Text(
              'Vos économies, notre passion',
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: size * 0.06,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LogoIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const LogoIcon({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppTheme.primaryOrange;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.primaryTurquoise,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: iconColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          'R',
          style: TextStyle(
            color: iconColor,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
