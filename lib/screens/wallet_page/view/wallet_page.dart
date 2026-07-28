import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:grofery_user/config/constant.dart';
import 'package:grofery_user/config/theme.dart';
import 'package:grofery_user/router/app_routes.dart';
import 'package:grofery_user/screens/wallet_page/bloc/user_wallet/user_wallet_bloc.dart';
import 'package:grofery_user/utils/widgets/custom_image_container.dart';
import 'package:grofery_user/utils/widgets/custom_scaffold.dart';
import 'dart:math' as math;

import 'package:grofery_user/l10n/app_localizations.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> with TickerProviderStateMixin {
  late AnimationController _coinFlipController;
  late AnimationController _glowController;
  late Animation<double> _flipAnimation;
  late Animation<double> _glowAnimation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    context.read<UserWalletBloc>().add(FetchUserWallet());

    // Coin flip animation controller
    _coinFlipController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    // Glow pulse animation controller
    _glowController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _coinFlipController, curve: Curves.easeInOutBack),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _coinFlipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _coinFlipController.reset();
        setState(() => _isRefreshing = false);
      }
    });
  }

  @override
  void dispose() {
    _coinFlipController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _refreshBalance() {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    _coinFlipController.forward();
    _glowController.repeat(reverse: true);

    // Call API to refresh balance
    context.read<UserWalletBloc>().add(FetchUserWallet());

    // Stop glow after coin flip
    Future.delayed(Duration(milliseconds: 1200), () {
      _glowController.stop();
      _glowController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      showViewCart: false,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    _buildBalanceCard(),
                    SizedBox(height: 24),
                    _buildTransactionsRow(),
                    Spacer(),
                    _buildBottomButtons(context),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                color: Theme.of(context).colorScheme.tertiary,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.wallet,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
                fontSize: isTablet(context) ? 24 : 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.9),
                AppTheme.primaryColor.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.balance,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    BlocBuilder<UserWalletBloc, UserWalletState>(
                      builder: (BuildContext context, UserWalletState state) {
                        if (state is UserWalletLoaded) {
                          return Text(
                            '${AppConstant.currency}${state.userWallet.first.balance ?? '0.00'}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        return Container(
                          height: 38,
                          width: 80,
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _flipAnimation,
                          builder: (context, child) {
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(_flipAnimation.value),
                              child: Icon(
                                TablerIcons.coin,
                                color: Colors.white.withValues(alpha: 0.9),
                                size: 18,
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.tapCoinToRefresh,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _refreshBalance,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final angle = _flipAnimation.value;
                    final isFront = (angle / math.pi) % 2 < 1;

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002)
                        ..rotateY(angle),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: _isRefreshing ? [
                            BoxShadow(
                              color: Colors.yellow.withValues(alpha: 0.5 * _glowAnimation.value),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ] : [],
                        ),
                        child: isFront
                            ? CustomImageContainer(
                          imagePath:  'assets/images/wallet/wallet-coins.png',
                          width: 90,
                          height: 90,
                        )
                            : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: CustomImageContainer(
                            imagePath:  'assets/images/wallet/wallet-coins.png',
                            width: 90,
                            height: 90,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionsRow() {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).push(AppRoutes.transactions);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                TablerIcons.receipt,
                color: AppTheme.primaryColor,
                size: 26,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.viewTransactions,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: _buildActionButton(
        AppLocalizations.of(context)!.addMoney,
        AppTheme.primaryColor,
        Colors.white,
        Colors.transparent,
            () {
          GoRouter.of(context).push(AppRoutes.addMoney);
        },
      ),
    );
  }

  Widget _buildActionButton(
      String text,
      Color backgroundColor,
      Color textColor,
      Color borderColor,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor != Colors.transparent
                ? borderColor
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}