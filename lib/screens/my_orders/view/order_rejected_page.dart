import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:grofery_user/bloc/user_cart_bloc/user_cart_bloc.dart';
import 'package:grofery_user/bloc/user_cart_bloc/user_cart_event.dart';

import '../../../router/app_routes.dart';
import '../../cart_page/bloc/get_user_cart/get_user_cart_bloc.dart';

class OrderRejectedPage extends StatefulWidget {
  final String address;
  final String addressType;
  final String orderSlug;
  const OrderRejectedPage({super.key, required this.address, required this.addressType, required this.orderSlug});

  @override
  State<OrderRejectedPage> createState() => _OrderRejectedPageState();
}

class _OrderRejectedPageState extends State<OrderRejectedPage> {

  @override
  void initState() {
    navigateBack();
    context.read<CartBloc>().add(ClearCart(context: context));
    super.initState();
  }

  Future<void> navigateBack() async {
    Future.delayed(const Duration(seconds: 8),(){
      if(mounted) {
        GoRouter.of(context).pop();
        context.read<GetUserCartBloc>().add(RefreshUserCart());
        GoRouter.of(context).push(
            AppRoutes.orderDetail,
            extra: {
              'order-slug': widget.orderSlug
            }
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentGeometry.center,
      children: [
        Container(
          color: Colors.white,
          width: double.infinity,
          alignment: Alignment.center,
          child: Material(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  TablerIcons.circle_x_filled,
                  color: Colors.red,
                  size: 150.r,
                ),
                SizedBox(height: 10.h,),
                Text(
                  'Order Rejected',
                  style: TextStyle(
                      fontSize: 18.sp
                  ),
                ),
                SizedBox(height: 8.h,),
                Padding(
                  padding:  EdgeInsets.symmetric(
                      horizontal: 25.w,
                      vertical: 00
                  ),
                  child: Text(
                    'Delivery to ${widget.addressType.toUpperCase()}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16.sp
                    ),
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.symmetric(
                      horizontal: 25.w,
                    vertical: 0.0
                  ),
                  child: Text(
                    widget.address,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16.sp
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
