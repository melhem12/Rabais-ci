import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppIcons {
  // Custom icon colors
  static const Color primaryIconColor = AppTheme.primaryOrange;
  static const Color secondaryIconColor = AppTheme.primaryTurquoise;
  static const Color textIconColor = AppTheme.navyBlue;

  // Custom icon widgets
  static Widget logoIcon({double size = 24, Color? color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.primaryTurquoise,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color ?? primaryIconColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          'R',
          style: TextStyle(
            color: color ?? primaryIconColor,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Widget ticketIcon({double size = 24, Color? color}) {
    return CustomPaint(
      size: Size(size, size),
      painter: TicketIconPainter(color: color ?? primaryIconColor),
    );
  }

  static Widget discountIcon({double size = 24, Color? color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? primaryIconColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '%',
          style: TextStyle(
            color: AppTheme.white,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Widget walletIcon({double size = 24, Color? color}) {
    return Icon(
      Icons.account_balance_wallet,
      size: size,
      color: color ?? primaryIconColor,
    );
  }

  static Widget voucherIcon({double size = 24, Color? color}) {
    return Icon(
      Icons.local_offer,
      size: size,
      color: color ?? secondaryIconColor,
    );
  }

  static Widget businessIcon({double size = 24, Color? color}) {
    return Icon(
      Icons.business,
      size: size,
      color: color ?? secondaryIconColor,
    );
  }

  static Widget purchaseIcon({double size = 24, Color? color}) {
    return Icon(
      Icons.shopping_bag,
      size: size,
      color: color ?? primaryIconColor,
    );
  }

  static Widget profileIcon({double size = 24, Color? color}) {
    return Icon(
      Icons.person,
      size: size,
      color: color ?? textIconColor,
    );
  }

  static Widget qrIcon({double size = 24, Color? color}) {
    return Icon(
      Icons.qr_code,
      size: size,
      color: color ?? primaryIconColor,
    );
  }

  static Widget scanIcon({double size = 24, Color? color}) {
    return Icon(
      Icons.qr_code_scanner,
      size: size,
      color: color ?? secondaryIconColor,
    );
  }
}

class TicketIconPainter extends CustomPainter {
  final Color color;

  TicketIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Main ticket body
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
      const Radius.circular(4),
    ));
    
    // Ticket notch on the left
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.3, 4, size.height * 0.4),
      const Radius.circular(2),
    ));
    
    canvas.drawPath(path, paint);
    
    // Add "R" in the center
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'R',
        style: TextStyle(
          color: AppTheme.white,
          fontSize: size.width * 0.6,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
