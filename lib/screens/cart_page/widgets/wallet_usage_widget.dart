import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:grofery_user/config/theme.dart';
import 'package:grofery_user/screens/cart_page/bloc/get_user_cart/get_user_cart_bloc.dart';
import 'package:grofery_user/screens/wallet_page/bloc/user_wallet/user_wallet_bloc.dart';
import 'package:grofery_user/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:grofery_user/config/constant.dart';

class WalletUsageWidget extends StatefulWidget {
  final bool isWalletEnabled;
  final Function(bool) onWalletToggle;
  final bool isLoading;
  final double? walletAmountUsed;
  final double? remainingBalance;

  const WalletUsageWidget({
    super.key,
    required this.isWalletEnabled,
    required this.onWalletToggle,
    this.isLoading = false,
    this.walletAmountUsed,
    this.remainingBalance,
  });

  @override
  State<WalletUsageWidget> createState() => _WalletUsageWidgetState();
}

class _WalletUsageWidgetState extends State<WalletUsageWidget> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserWalletBloc, UserWalletState>(
      builder: (context, walletState) {
        double balance = 0.00;
        if (walletState is UserWalletLoaded &&
            walletState.userWallet.isNotEmpty) {
          final wallet = walletState.userWallet.first;
          balance = double.tryParse(wallet.balance ?? '0.00') ?? 0.00;
        }

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: BlocBuilder<GetUserCartBloc, GetUserCartState>(
            builder: (context, cartState) {
              double usedBalance = 0.00;
              double remainingBalance = 0.00;

              if (cartState is GetUserCartLoaded) {
                usedBalance = widget.walletAmountUsed ??
                    double.parse(cartState
                        .cartData.first.data!.paymentSummary!.walletAmountUsed!
                        .toStringAsFixed(2));
                remainingBalance = widget.remainingBalance ??
                    (double.parse(cartState
                            .cartData.first.data!.paymentSummary!.walletBalance!
                            .toStringAsFixed(2)) -
                        usedBalance);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              TablerIcons.wallet,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Use Wallet Balance',
                                style: TextStyle(
                                  fontSize: isTablet(context) ? 20 : 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _showDetails = !_showDetails;
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(top: 2.h),
                                  child: Text(
                                    _showDetails
                                        ? 'hide details'
                                        : 'see details',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      cartState is GetUserCartLoading
                          ? const CustomCircularProgressIndicator()
                          : SizedBox(
                              height: 25,
                              child: Switch(
                                value: widget.isWalletEnabled,
                                onChanged: balance > 0.0
                                    ? (value) {
                                        setState(() {
                                          _showDetails = value;
                                        });
                                        widget.onWalletToggle(value);
                                      }
                                    : null,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.padded,
                                activeThumbColor: AppTheme.primaryColor,
                                activeTrackColor: AppTheme.primaryColor
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                    ],
                  ),
                  if (_showDetails) ...[
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            context,
                            label: 'Available Balance',
                            value:
                                '${AppConstant.currency}${balance.toStringAsFixed(2)}',
                          ),
                          SizedBox(height: 10.h),
                          _buildDetailRow(
                            context,
                            label: 'Wallet Amount Used',
                            value:
                                '- ${AppConstant.currency}${usedBalance.toStringAsFixed(2)}',
                            valueColor: AppTheme.primaryColor,
                          ),
                          SizedBox(height: 10.h),
                          _buildDetailRow(
                            context,
                            label: 'Remaining Balance',
                            value:
                                '${AppConstant.currency}${remainingBalance.toStringAsFixed(2)}',
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                    if (balance <= 0) ...[
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18.r,
                              color: Colors.red.shade400,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Insufficient wallet balance',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.red.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color:
                  Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: valueColor ?? Theme.of(context).colorScheme.tertiary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
