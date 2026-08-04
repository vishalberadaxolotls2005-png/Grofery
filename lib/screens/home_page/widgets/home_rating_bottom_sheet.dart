import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_user/config/theme.dart';
import 'package:grofery_user/screens/my_orders/repo/delivery_boy_feedback_repo.dart';
import 'package:grofery_user/screens/product_detail_page/repo/product_feedback_repo.dart';
import 'package:grofery_user/utils/widgets/custom_toast.dart';

class HomeRatingBottomSheet extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const HomeRatingBottomSheet({super.key, required this.orderData});

  @override
  State<HomeRatingBottomSheet> createState() => _HomeRatingBottomSheetState();
}

class _HomeRatingBottomSheetState extends State<HomeRatingBottomSheet> {
  double _deliveryRating = 0;
  double _productRating = 0;
  bool _isSubmitting = false;

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  void _submitRating() async {
    if (_deliveryRating == 0 && _productRating == 0) {
      ToastManager.show(
        context: context,
        message: 'Please provide a rating before submitting',
        type: ToastType.error,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final int? orderId = _parseInt(widget.orderData['id']);
      final int? deliveryBoyId = _parseInt(widget.orderData['delivery_boy_id']);
      
      if (orderId == null) {
        throw Exception("Order ID is missing");
      }
      
      // Submit Delivery Feedback
      if (_deliveryRating > 0 && deliveryBoyId != null) {
        final deliveryRepo = DeliveryBoyFeedbackRepo();
        await deliveryRepo.addDeliveryFeedback(
          deliveryBoyId: deliveryBoyId,
          orderId: orderId,
          title: 'Delivery Rating',
          description: 'Delivery rating',
          rating: _deliveryRating.toInt(),
        );
      }

      // Submit Product Feedback
      if (_productRating > 0) {
        final items = widget.orderData['items'] as List<dynamic>?;
        if (items != null && items.isNotEmpty) {
          final productRepo = ProductFeedbackRepo();
          // To keep it simple based on the UI which only has one product star rating,
          // we apply this rating to all products.
          for (var item in items) {
            final int? itemId = _parseInt(item['id']);
            if (itemId != null) {
              await productRepo.addProductFeedback(
                orderItemId: itemId,
                title: 'Product Rating',
                description: 'Product rating',
                rating: _productRating.toInt(),
                images: [],
              );
            }
          }
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ToastManager.show(
          context: context,
          message: 'Thank you for your feedback!',
          type: ToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        ToastManager.show(
          context: context,
          message: 'Failed to submit rating: $e',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String deliveredDate = '';
    if (widget.orderData['updated_at'] != null || widget.orderData['created_at'] != null) {
      try {
        DateTime date = DateTime.parse(widget.orderData['updated_at'] ?? widget.orderData['created_at']);
        // Format date manually to avoid depending on intl package if not already imported
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        deliveredDate = '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
      } catch (e) {
        // ignore
      }
    }
    String deliveryBoyName = widget.orderData['delivery_boy_name'] ?? 'Delivery Partner';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hand Emoji
          Text(
            '👋',
            style: TextStyle(fontSize: 36.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'How was your experience?',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          SizedBox(height: 16.h),
          
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                // Product Rating Section
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 22.r,
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        child: Icon(Icons.shopping_bag, color: Colors.green, size: 24.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rate your order',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontFamily: AppTheme.fontFamily,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Delivered on $deliveredDate',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                                fontFamily: AppTheme.fontFamily,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            RatingBar(
                              initialRating: _productRating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              itemCount: 5,
                              itemSize: 24.sp,
                              itemPadding: EdgeInsets.symmetric(horizontal: 2.w),
                              ratingWidget: RatingWidget(
                                full: Icon(Icons.star, color: AppTheme.ratingStarColor),
                                half: Icon(Icons.star_half, color: AppTheme.ratingStarColor),
                                empty: Icon(Icons.star_border, color: Colors.grey.withOpacity(0.5)),
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  _productRating = rating;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                
                // Delivery Rating Section
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 22.r,
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        child: Icon(Icons.delivery_dining, color: Colors.green, size: 24.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rate our delivery',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontFamily: AppTheme.fontFamily,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'By $deliveryBoyName',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                                fontFamily: AppTheme.fontFamily,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            RatingBar(
                              initialRating: _deliveryRating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              itemCount: 5,
                              itemSize: 24.sp,
                              itemPadding: EdgeInsets.symmetric(horizontal: 2.w),
                              ratingWidget: RatingWidget(
                                full: Icon(Icons.star, color: AppTheme.ratingStarColor),
                                half: Icon(Icons.star_half, color: AppTheme.ratingStarColor),
                                empty: Icon(Icons.star_border, color: Colors.grey.withOpacity(0.5)),
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  _deliveryRating = rating;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 42.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              onPressed: _isSubmitting ? null : _submitRating,
              child: _isSubmitting
                  ? SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

