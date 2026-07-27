import 'package:equatable/equatable.dart';

abstract class TargetGiftHistoryEvent extends Equatable {
  const TargetGiftHistoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchTargetGiftHistory extends TargetGiftHistoryEvent {
  const FetchTargetGiftHistory();
}

class ClaimTargetGiftEvent extends TargetGiftHistoryEvent {
  final int targetId;
  final int? addressId;

  const ClaimTargetGiftEvent({required this.targetId, this.addressId});

  @override
  List<Object?> get props => [targetId, addressId];
}
