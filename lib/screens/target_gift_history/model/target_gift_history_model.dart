class TargetGiftHistoryModel {
  final bool? success;
  final GiftHistorySummary? summary;
  final GiftCurrentProgress? currentProgress;
  final List<CompletedTarget> completedTargets;
  final List<UpcomingGift> upcomingGifts;

  TargetGiftHistoryModel({
    this.success,
    this.summary,
    this.currentProgress,
    this.completedTargets = const [],
    this.upcomingGifts = const [],
  });

  factory TargetGiftHistoryModel.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : null;

    // 1. Completed targets
    List<CompletedTarget> completedList = [];
    final achievedJson = dataMap?['achieved'] ?? json['completed_targets'];
    if (achievedJson is List) {
      completedList = achievedJson
          .map((e) => CompletedTarget.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // 2. Upcoming gifts
    List<UpcomingGift> upcomingList = [];
    final upcomingJson = dataMap?['upcoming'] ?? json['upcoming_gifts'];
    if (upcomingJson is List) {
      for (int i = 0; i < upcomingJson.length; i++) {
        final itemMap = upcomingJson[i] as Map<String, dynamic>;
        final bool isCurr = itemMap['is_current'] == true ||
            (itemMap['is_current'] == null && i == 0);
        upcomingList.add(UpcomingGift.fromJson(itemMap, isCurrentFallback: isCurr));
      }
    }

    // 3. Summary
    GiftHistorySummary? summaryObj;
    if (json['summary'] != null && json['summary'] is Map<String, dynamic>) {
      summaryObj = GiftHistorySummary.fromJson(json['summary']);
    } else {
      final double totalSpentVal = (json['eligible_spent'] as num?)?.toDouble() ??
          (json['total_spent'] as num?)?.toDouble() ??
          0.0;
      final double progressVal = (json['progress_pct'] as num?)?.toDouble() ??
          (upcomingList.isNotEmpty ? upcomingList.first.progressPct ?? 0.0 : (completedList.isNotEmpty ? 100.0 : 0.0));
      summaryObj = GiftHistorySummary(
        totalSpent: totalSpentVal,
        totalGiftsEarned: completedList.length,
        progressPct: progressVal,
        currentTierLabel: json['current_tier_label'] as String?,
      );
    }

    // 4. Current progress
    GiftCurrentProgress? currentProgObj;
    if (json['current_progress'] != null && json['current_progress'] is Map<String, dynamic>) {
      currentProgObj = GiftCurrentProgress.fromJson(json['current_progress']);
    } else {
      EligibleGiftHistory? eligGift;
      final eligJson = json['eligible_gift'] ?? dataMap?['eligible_gift'];
      if (eligJson != null && eligJson is Map<String, dynamic>) {
        eligGift = EligibleGiftHistory.fromJson(eligJson);
      }
      UpcomingGift? nextG = upcomingList.isNotEmpty
          ? upcomingList.firstWhere((e) => e.isCurrent == true, orElse: () => upcomingList.first)
          : null;
      if (eligGift != null || nextG != null) {
        currentProgObj = GiftCurrentProgress(
          eligibleGift: eligGift,
          nextGift: nextG,
        );
      }
    }

    return TargetGiftHistoryModel(
      success: json['success'] as bool? ?? true,
      summary: summaryObj,
      currentProgress: currentProgObj,
      completedTargets: completedList,
      upcomingGifts: upcomingList,
    );
  }
}

class GiftHistorySummary {
  final double? totalSpent;
  final double? progressPct;
  final int? totalGiftsEarned;
  final String? currentTierLabel;

  GiftHistorySummary({
    this.totalSpent,
    this.progressPct,
    this.totalGiftsEarned,
    this.currentTierLabel,
  });

  factory GiftHistorySummary.fromJson(Map<String, dynamic> json) =>
      GiftHistorySummary(
        totalSpent: (json['total_spent'] as num?)?.toDouble(),
        progressPct: (json['progress_pct'] as num?)?.toDouble(),
        totalGiftsEarned: (json['total_gifts_earned'] as num?)?.toInt(),
        currentTierLabel: json['current_tier_label']?.toString(),
      );
}

class GiftCurrentProgress {
  final UpcomingGift? nextGift;
  final EligibleGiftHistory? eligibleGift;

  GiftCurrentProgress({this.nextGift, this.eligibleGift});

  factory GiftCurrentProgress.fromJson(Map<String, dynamic> json) =>
      GiftCurrentProgress(
        nextGift: json['next_gift'] != null
            ? UpcomingGift.fromJson(json['next_gift'])
            : null,
        eligibleGift: json['eligible_gift'] != null
            ? EligibleGiftHistory.fromJson(json['eligible_gift'])
            : null,
      );
}

class EligibleGiftHistory {
  final String? giftName;
  final String? giftImage;

  EligibleGiftHistory({this.giftName, this.giftImage});

  factory EligibleGiftHistory.fromJson(Map<String, dynamic> json) =>
      EligibleGiftHistory(
        giftName: json['gift_name']?.toString(),
        giftImage: json['gift_image']?.toString(),
      );
}

class CompletedTarget {
  final int? id;
  final String? giftName;
  final String? giftImage;
  final double? targetAmount;
  final String? completedAt;
  final String? orderId;
  final String? status; // "achieved", "claimed" or "pending"

  CompletedTarget({
    this.id,
    this.giftName,
    this.giftImage,
    this.targetAmount,
    this.completedAt,
    this.orderId,
    this.status,
  });

  factory CompletedTarget.fromJson(Map<String, dynamic> json) =>
      CompletedTarget(
        id: (json['id'] as num?)?.toInt(),
        giftName: json['gift_name']?.toString(),
        giftImage: json['gift_image']?.toString(),
        targetAmount: (json['target_amount'] as num?)?.toDouble(),
        completedAt: json['completed_at']?.toString(),
        orderId: json['order_id']?.toString(),
        status: json['status']?.toString(),
      );

  bool get isClaimed => status?.toLowerCase() == 'claimed' || status?.toLowerCase() == 'achieved';

  String get statusLabel {
    if (status?.toLowerCase() == 'achieved') return 'Achieved';
    if (status?.toLowerCase() == 'claimed') return 'Claimed';
    if (status?.toLowerCase() == 'pending') return 'Pending';
    if (status != null && status!.isNotEmpty) {
      return status![0].toUpperCase() + status!.substring(1).toLowerCase();
    }
    return 'Achieved';
  }

  DateTime? get completedAtDate {
    if (completedAt == null) return null;
    try {
      return DateTime.parse(completedAt!);
    } catch (_) {
      return null;
    }
  }
}

class UpcomingGift {
  final int? id;
  final String? giftName;
  final String? giftImage;
  final double? targetAmount;
  final double? amountNeeded;
  final double? progressPct;
  final bool? isCurrent;

  UpcomingGift({
    this.id,
    this.giftName,
    this.giftImage,
    this.targetAmount,
    this.amountNeeded,
    this.progressPct,
    this.isCurrent,
  });

  factory UpcomingGift.fromJson(Map<String, dynamic> json, {bool? isCurrentFallback}) => UpcomingGift(
        id: (json['id'] as num?)?.toInt(),
        giftName: json['gift_name']?.toString(),
        giftImage: json['gift_image']?.toString(),
        targetAmount: (json['target_amount'] as num?)?.toDouble(),
        amountNeeded: (json['amount_needed'] as num?)?.toDouble(),
        progressPct: (json['progress_pct'] as num?)?.toDouble(),
        isCurrent: json['is_current'] as bool? ?? isCurrentFallback,
      );
}
