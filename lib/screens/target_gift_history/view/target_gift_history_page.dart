import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_user/config/theme.dart';
import 'package:intl/intl.dart';
import '../bloc/target_gift_history_bloc.dart';
import '../bloc/target_gift_history_event.dart';
import '../bloc/target_gift_history_state.dart';
import '../model/target_gift_history_model.dart';
import '../repo/target_gift_history_repo.dart';

class TargetGiftHistoryPage extends StatelessWidget {
  const TargetGiftHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TargetGiftHistoryBloc(TargetGiftHistoryRepository())
        ..add(const FetchTargetGiftHistory()),
      child: const _TargetGiftHistoryView(),
    );
  }
}

class _TargetGiftHistoryView extends StatelessWidget {
  const _TargetGiftHistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: BlocConsumer<TargetGiftHistoryBloc, TargetGiftHistoryState>(
        listener: (context, state) {
          if (state is TargetGiftClaiming) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          } else if (state is TargetGiftClaimSuccess) {
            Navigator.of(context, rootNavigator: true).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
          } else if (state is TargetGiftClaimFailed) {
            Navigator.of(context, rootNavigator: true).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
            current is! TargetGiftClaiming &&
            current is! TargetGiftClaimSuccess &&
            current is! TargetGiftClaimFailed,
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, state),
              if (state is TargetGiftHistoryLoading)
                const SliverFillRemaining(child: _LoadingView()),
              if (state is TargetGiftHistoryFailed)
                SliverFillRemaining(
                    child: _ErrorView(
                  message: state.message,
                  onRetry: () => context
                      .read<TargetGiftHistoryBloc>()
                      .add(const FetchTargetGiftHistory()),
                )),
              if (state is TargetGiftHistoryLoaded) ...[
                SliverToBoxAdapter(
                    child: _SummaryCard(summary: state.data.summary)),
                SliverToBoxAdapter(
                    child: _CurrentProgressCard(
                        progress: state.data.currentProgress)),
                if (state.data.completedTargets.isNotEmpty)
                  SliverToBoxAdapter(
                      child: _CompletedTargetsSection(
                          items: state.data.completedTargets)),
                if (state.data.upcomingGifts.isNotEmpty)
                  SliverToBoxAdapter(
                      child: _UpcomingGiftsSection(
                          gifts: state.data.upcomingGifts,
                          totalSpent: state.data.summary?.totalSpent ?? 0)),
                SliverToBoxAdapter(child: SizedBox(height: 32.h)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(
      BuildContext context, TargetGiftHistoryState state) {
    return SliverAppBar(
      expandedHeight: 180.h,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _AppBarBackground(state: state),
      ),
      title: Text(
        'My Gift Targets',
        style: TextStyle(
          color: Colors.white,
          fontSize: 17.sp,
          fontWeight: FontWeight.bold,
          fontFamily: AppTheme.fontFamily,
        ),
      ),
    );
  }
}

class _AppBarBackground extends StatelessWidget {
  final TargetGiftHistoryState state;
  const _AppBarBackground({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            const Color(0xFF065226),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20.h,
            right: -20.w,
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -30.h,
            left: -10.w,
            child: Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.only(left: 20.w, right: 20.w, top: 50.h, bottom: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '🎁 My Gift Targets',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Track your rewards & unlock more gifts',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12.sp,
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                        if (state is TargetGiftHistoryLoaded &&
                            (state as TargetGiftHistoryLoaded).data.summary?.currentTierLabel != null)
                          Container(
                            margin: EdgeInsets.only(top: 8.h),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                  color: Colors.amber.withOpacity(0.5)),
                            ),
                            child: Text(
                              '⭐ ${(state as TargetGiftHistoryLoaded).data.summary!.currentTierLabel}',
                              style: TextStyle(
                                color: Colors.amber[100],
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppTheme.fontFamily,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration( 
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.card_giftcard_rounded,
                        color: Colors.white, size: 32.sp),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Summary Stats Card ────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final GiftHistorySummary? summary;
  const _SummaryCard({this.summary});

  @override
  Widget build(BuildContext context) {
    final spent = summary?.totalSpent ?? 0;
    final earned = summary?.totalGiftsEarned ?? 0;
    final pct = summary?.progressPct ?? 0;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.currency_rupee_rounded,
            iconColor: AppTheme.primaryColor,
            bgColor: AppTheme.primaryColor.withOpacity(0.1),
            value: '₹${spent.toStringAsFixed(0)}',
            label: 'Total Spent',
          ),
          _Divider(),
          _StatItem(
            icon: Icons.card_giftcard_rounded,
            iconColor: Colors.deepOrange,
            bgColor: Colors.deepOrange.withOpacity(0.1),
            value: '$earned',
            label: 'Gifts Earned',
          ),
          _Divider(),
          _StatItem(
            icon: Icons.trending_up_rounded,
            iconColor: Colors.purple,
            bgColor: Colors.purple.withOpacity(0.1),
            value: '${pct.toInt()}%',
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration:
                BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[500],
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 50.h,
      color: Colors.grey.shade200,
    );
  }
}

// ─── Current Progress Card ─────────────────────────────────────────────────────
class _CurrentProgressCard extends StatelessWidget {
  final GiftCurrentProgress? progress;
  const _CurrentProgressCard({this.progress});

  @override
  Widget build(BuildContext context) {
    if (progress == null) return const SizedBox.shrink();

    final nextGift = progress!.nextGift;
    final eligibleGift = progress!.eligibleGift;

    if (nextGift == null && eligibleGift == null) return const SizedBox.shrink();

    final bool isUnlocked = eligibleGift != null;
    final giftName = isUnlocked
        ? eligibleGift.giftName ?? 'Gift Unlocked!'
        : nextGift?.giftName ?? '';
    final giftImage =
        isUnlocked ? eligibleGift.giftImage : nextGift?.giftImage;
    final targetAmount = nextGift?.targetAmount ?? 0;
    final amountNeeded = nextGift?.amountNeeded ?? 0;
    final pct = nextGift?.progressPct ?? 0;
    final double progressVal =
        isUnlocked ? 1.0 : (pct > 0 ? pct / 100 : 0).clamp(0.0, 1.0).toDouble();

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isUnlocked
              ? [const Color(0xFFFF6B00), const Color(0xFFFF9500)]
              : [AppTheme.primaryColor, const Color(0xFF065226)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: (isUnlocked ? Colors.orange : AppTheme.primaryColor)
                .withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUnlocked ? '🎉 Gift Unlocked!' : '🎯 Current Target',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11.sp,
                          fontFamily: AppTheme.fontFamily,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        giftName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppTheme.fontFamily,
                        ),
                      ),
                      if (!isUnlocked) ...[
                        SizedBox(height: 4.h),
                        Text(
                          'Add ₹${amountNeeded.toInt()} more to unlock',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12.sp,
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (giftImage != null && giftImage.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: giftImage,
                      height: 52.h,
                      width: 52.w,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => Icon(
                        Icons.card_giftcard,
                        color: Colors.white,
                        size: 32.sp,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.card_giftcard_rounded,
                      color: Colors.white,
                      size: 40.sp,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹0',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10.sp,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
                Text(
                  '₹${targetAmount.toInt()}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10.sp,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: progressVal,
                minHeight: 10.h,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isUnlocked ? Colors.white : Colors.white,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '${(progressVal * 100).toInt()}% Complete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Completed Targets Section ─────────────────────────────────────────────────
class _CompletedTargetsSection extends StatelessWidget {
  final List<CompletedTarget> items;
  const _CompletedTargetsSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 10.h),
          child: Row(
            children: [
              Container(
                width: 4.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Completed Targets',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${items.length} earned',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...items.asMap().entries.map((e) => _CompletedTargetCard(
              item: e.value,
              index: e.key,
              isLast: e.key == items.length - 1,
            )),
      ],
    );
  }
}

class _CompletedTargetCard extends StatelessWidget {
  final CompletedTarget item;
  final int index;
  final bool isLast;

  const _CompletedTargetCard({
    required this.item,
    required this.index,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final date = item.completedAtDate;
    final dateStr = date != null
        ? DateFormat('dd MMM yyyy').format(date.toLocal())
        : 'Target Achieved';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: item.isClaimed
                        ? AppTheme.primaryColor
                        : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.isClaimed
                        ? Icons.check_rounded
                        : Icons.hourglass_top_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.w,
                      color: Colors.grey.shade200,
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            // Card
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (item.giftImage != null && item.giftImage!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: CachedNetworkImage(
                          imageUrl: item.giftImage!,
                          height: 48.h,
                          width: 48.w,
                          fit: BoxFit.contain,
                          errorWidget: (_, __, ___) => Container(
                            height: 48.h,
                            width: 48.w,
                            color: Colors.grey.shade100,
                            child: Icon(Icons.card_giftcard,
                                color: Colors.grey, size: 24.sp),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 48.h,
                        width: 48.w,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.card_giftcard_rounded,
                            color: Colors.grey.shade400, size: 26.sp),
                      ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.giftName ?? 'Gift',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'Target: ₹${item.targetAmount?.toInt() ?? 0}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey[400],
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (item.status?.toLowerCase() == 'achieved' || (!item.isClaimed && item.status?.toLowerCase() != 'pending'))
                      InkWell(
                        onTap: () => _showClaimConfirmDialog(context, item),
                        borderRadius: BorderRadius.circular(20.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2E7D32).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.card_giftcard_rounded,
                                  color: Colors.white, size: 14.sp),
                              SizedBox(width: 4.w),
                              Text(
                                'Claim Gift',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: AppTheme.fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: (item.isClaimed ? AppTheme.primaryColor : Colors.orange)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          item.statusLabel,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: item.isClaimed
                                ? AppTheme.primaryColor
                                : Colors.orange,
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClaimConfirmDialog(BuildContext context, CompletedTarget item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.card_giftcard_rounded, color: AppTheme.primaryColor, size: 28.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Claim Your Gift!',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'Congratulations on completing the target for "${item.giftName ?? 'Gift'}"!\n\nOnce claimed, our admin team will verify your target completion and deliver this gift to your primary saved address.',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey[700], height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TargetGiftHistoryBloc>().add(
                    ClaimTargetGiftEvent(targetId: item.id ?? 0),
                  );
            },
            child: const Text('Confirm Claim', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Upcoming Gifts Section ────────────────────────────────────────────────────
class _UpcomingGiftsSection extends StatelessWidget {
  final List<UpcomingGift> gifts;
  final double totalSpent;

  const _UpcomingGiftsSection({
    required this.gifts,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
          child: Row(
            children: [
              Container(
                width: 4.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Upcoming Gifts',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 190.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 16.w, right: 8.w),
            itemCount: gifts.length,
            itemBuilder: (context, index) =>
                _UpcomingGiftCard(gift: gifts[index], totalSpent: totalSpent),
          ),
        ),
      ],
    );
  }
}

class _UpcomingGiftCard extends StatelessWidget {
  final UpcomingGift gift;
  final double totalSpent;

  const _UpcomingGiftCard({required this.gift, required this.totalSpent});

  @override
  Widget build(BuildContext context) {
    final target = gift.targetAmount ?? 0;
    final amountNeeded = gift.amountNeeded ?? 0;
    final double progress = gift.progressPct != null
        ? (gift.progressPct! / 100).clamp(0.0, 1.0)
        : (target > 0 ? ((target - amountNeeded) / target).clamp(0.0, 1.0) : 0.0);
    final bool isCurrent = gift.isCurrent == true;

    return Container(
      width: 150.w,
      margin: EdgeInsets.only(right: 12.w, bottom: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isCurrent
              ? AppTheme.primaryColor.withOpacity(0.4)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isCurrent)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: isCurrent ? AppTheme.primaryColor : Colors.grey,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Center(
              child: gift.giftImage != null && gift.giftImage!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: gift.giftImage!,
                      height: 60.h,
                      width: 60.w,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => Icon(
                        Icons.card_giftcard_rounded,
                        color: Colors.grey.shade300,
                        size: 40.sp,
                      ),
                    )
                  : Icon(
                      Icons.card_giftcard_rounded,
                      color: Colors.grey.shade300,
                      size: 40.sp,
                    ),
            ),
            SizedBox(height: 8.h),
            Text(
              gift.giftName ?? 'Gift',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Spend ₹${target.toInt()}',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[500],
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5.h,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCurrent ? AppTheme.primaryColor : Colors.grey.shade300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Loading & Error States ────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryColor),
          SizedBox(height: 16.h),
          Text(
            'Loading your gifts...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13.sp,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 56.sp, color: Colors.red.shade300),
            SizedBox(height: 16.h),
            Text(
              'Could not load gift history',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                padding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
