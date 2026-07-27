import 'package:equatable/equatable.dart';
import '../model/target_gift_history_model.dart';

abstract class TargetGiftHistoryState extends Equatable {
  const TargetGiftHistoryState();

  @override
  List<Object?> get props => [];
}

class TargetGiftHistoryInitial extends TargetGiftHistoryState {}

class TargetGiftHistoryLoading extends TargetGiftHistoryState {}

class TargetGiftHistoryLoaded extends TargetGiftHistoryState {
  final TargetGiftHistoryModel data;

  const TargetGiftHistoryLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class TargetGiftHistoryFailed extends TargetGiftHistoryState {
  final String message;

  const TargetGiftHistoryFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class TargetGiftClaiming extends TargetGiftHistoryState {}

class TargetGiftClaimSuccess extends TargetGiftHistoryState {
  final String message;

  const TargetGiftClaimSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TargetGiftClaimFailed extends TargetGiftHistoryState {
  final String message;

  const TargetGiftClaimFailed(this.message);

  @override
  List<Object?> get props => [message];
}
