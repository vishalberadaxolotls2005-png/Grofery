import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:grofery_user/config/theme.dart';
import 'package:grofery_user/router/app_routes.dart';
import 'package:grofery_user/screens/home_page/model/special_offer_model.dart';
import 'package:grofery_user/utils/widgets/custom_shimmer.dart';
import 'package:grofery_user/utils/widgets/custom_toast.dart';

class SpecialOfferCarousel extends StatefulWidget {
  final List<SpecialOfferBannerData> banners;
  final int totalCount;
  final String? title;

  const SpecialOfferCarousel({
    super.key,
    required this.banners,
    required this.totalCount,
    this.title,
  });

  @override
  State<SpecialOfferCarousel> createState() => _SpecialOfferCarouselState();
}

class _SpecialOfferCarouselState extends State<SpecialOfferCarousel> {
  late PageController _pageController;
  Timer? _timer;

  // High number to simulate infinity
  static const int _infiniteValue = 10000;

  @override
  void initState() {
    super.initState();

    // Start in the middle of the infinite range to allow scrolling both ways
    final int initialPage = _infiniteValue ~/ 2;
    _pageController =
        PageController(viewportFraction: 0.9, initialPage: initialPage);

    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    final int actualLength = widget.banners.length;
    final int displayTotal =
        widget.totalCount > 0 ? widget.totalCount : actualLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.title ?? 'Explore more',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  fontFamily: AppTheme.fontFamily,
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    // Calculate real index for the counter text
                    int displayIndex = 0;
                    if (_pageController.hasClients &&
                        _pageController.page != null) {
                      displayIndex =
                          (_pageController.page!.round() % actualLength) + 1;
                    } else {
                      displayIndex = ((_infiniteValue ~/ 2) % actualLength) + 1;
                    }

                    return Text(
                      '$displayIndex/$displayTotal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        SizedBox(
          height: 140.h,
          child: PageView.builder(
            controller: _pageController,
            // Infinite count
            itemCount: _infiniteValue,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              // Map the infinite index back to real index
              final int realIndex = index % actualLength;
              final String imageUrl = widget.banners[realIndex].bannerImage ?? '';

              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.05)).clamp(0.0, 1.0);
                  }

                  return Transform.scale(
                    scale: value,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16.r),
                        onTap: () {
                          debugPrint(
                              'Special Offer banner tapped: ${widget.banners[realIndex].id}');
                          _navigateToDetail(context, widget.banners[realIndex]);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 6.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: Colors.grey.shade100,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                ShimmerWidget.rectangular(
                              height: 170.h,
                              width: double.infinity,
                              isBorder: false,
                            ),
                            errorWidget: (context, url, error) => const Icon(
                                Icons.broken_image,
                                color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SizedBox(height: 15.h),
      ],
    );
  }

  void _navigateToDetail(BuildContext context, SpecialOfferBannerData banner) {
    if (banner.products != null && banner.products!.isNotEmpty) {
      GoRouter.of(context).push(AppRoutes.specialOfferListing, extra: {
        'products': banner.products,
      });
    } else {
      ToastManager.show(
        context: context,
        message: 'This offer is not linked to any product yet.',
        type: ToastType.info,
      );
    }
  }
}
