import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_user/config/constant.dart';
import 'package:grofery_user/config/theme.dart';
import 'package:grofery_user/utils/widgets/animated_button.dart';
import 'package:grofery_user/utils/widgets/custom_image_container.dart';

class CouponCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String couponCode;
  final bool isCollected;
  final bool isLoading;
  final VoidCallback? onTap;

  const CouponCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.couponCode,
    this.isCollected = false,
    this.isLoading = false,
    this.onTap,
  });

  void _handleTap() {
    if (isLoading) return;
    if (onTap != null) onTap!();
  }

  @override
  Widget build(BuildContext context) {
    // We use a fixed width for the left ticket stub
    final double leftStubWidth = 90.w;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 8.h),
      child: CustomPaint(
        painter: _TicketShadowPainter(separatorX: leftStubWidth),
        child: ClipPath(
          clipper: _HorizontalTicketClipper(separatorX: leftStubWidth),
          child: Container(
            color: Colors.white,
            child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Stub (Colored)
              Container(
                width: leftStubWidth,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.85),
                      AppTheme.primaryColor,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: CustomImageContainer(
                          imagePath: getAppLogoUrl(context),
                          height: 28.w,
                          width: 28.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'COUPON',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.sp,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Dashed Line Separator
              SizedBox(
                width: 1,
                child: CustomPaint(
                  painter: _VerticalDashedLinePainter(),
                ),
              ),

              // Right Content (White)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (title.isNotEmpty && title.toLowerCase() != 'new')
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      if (subtitle.isNotEmpty && 
                          subtitle.toLowerCase() != 'new' && 
                          subtitle != title) ...[
                        if (title.isNotEmpty && title.toLowerCase() != 'new') SizedBox(height: 6.h),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ],
                      SizedBox(height: 12.h),

                      // Code and Apply button
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: AppTheme.couponCollectBgColor,
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: 0.3),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  couponCode,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryColor,
                                    letterSpacing: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          AnimatedButton(
                            onTap: (!isCollected && !isLoading)
                                ? _handleTap
                                : null,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: isCollected
                                    ? Colors.transparent
                                    : const Color(0xFF007933),
                                borderRadius: BorderRadius.circular(24.r),
                                border: isCollected
                                    ? Border.all(
                                        color: const Color(0xFF007933),
                                        width: 1.5)
                                    : null,
                                boxShadow: isCollected || isLoading
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: const Color(0xFF007933)
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        )
                                      ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isLoading)
                                    SizedBox(
                                      width: 16.w,
                                      height: 16.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  else ...[
                                    Text(
                                      isCollected ? 'APPLIED' : 'APPLY',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w800,
                                        color: isCollected
                                            ? const Color(0xFF007933)
                                            : Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    if (isCollected) ...[
                                      SizedBox(width: 4.w),
                                      Icon(
                                        Icons.check_circle,
                                        size: 16.w,
                                        color: const Color(0xFF007933),
                                      ),
                                    ]
                                  ]
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 14.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              'Applicable on select products. T&C Apply.',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: const Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ), // closes Row
        ), // closes IntrinsicHeight
        ), // closes Container
        ), // closes ClipPath
      ), // closes CustomPaint
    ); // closes outer Container
  }
}

class _TicketShadowPainter extends CustomPainter {
  final double separatorX;
  _TicketShadowPainter({required this.separatorX});
  
  @override
  void paint(Canvas canvas, Size size) {
    final path = _HorizontalTicketClipper(separatorX: separatorX).getClip(size);
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant _TicketShadowPainter oldDelegate) => 
      oldDelegate.separatorX != separatorX;
}

class _VerticalDashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const dashHeight = 6.0;
    const dashSpace = 4.0;
    double startY = 12.0; // offset for the cutout

    while (startY < size.height - 12.0) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _HorizontalTicketClipper extends CustomClipper<Path> {
  final double separatorX;
  _HorizontalTicketClipper({required this.separatorX});

  @override
  Path getClip(Size size) {
    final path = Path();
    const double radius = 16.0;
    const double cutoutRadius = 10.0;

    // Top left
    path.moveTo(radius, 0);
    // Top separator cutout
    path.lineTo(separatorX - cutoutRadius, 0);
    path.arcToPoint(Offset(separatorX + cutoutRadius, 0),
        radius: Radius.circular(cutoutRadius), clockwise: false);
    // Top right
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(Offset(size.width, radius),
        radius: Radius.circular(radius));
    // Bottom right
    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(Offset(size.width - radius, size.height),
        radius: Radius.circular(radius));
    // Bottom separator cutout
    path.lineTo(separatorX + cutoutRadius, size.height);
    path.arcToPoint(Offset(separatorX - cutoutRadius, size.height),
        radius: Radius.circular(cutoutRadius), clockwise: false);
    // Bottom left
    path.lineTo(radius, size.height);
    path.arcToPoint(Offset(0, size.height - radius),
        radius: Radius.circular(radius));
    // Close
    path.lineTo(0, radius);
    path.arcToPoint(Offset(radius, 0), radius: Radius.circular(radius));

    path.close();
    return path;
  }

  @override
  bool shouldReclip(_HorizontalTicketClipper oldClipper) =>
      oldClipper.separatorX != separatorX;
}
