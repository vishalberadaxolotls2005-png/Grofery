import 'package:flutter_bloc/flutter_bloc.dart';
import '../repo/target_gift_history_repo.dart';
import '../model/target_gift_history_model.dart';
import 'target_gift_history_event.dart';
import 'target_gift_history_state.dart';

class TargetGiftHistoryBloc
    extends Bloc<TargetGiftHistoryEvent, TargetGiftHistoryState> {
  final TargetGiftHistoryRepository repository;

  TargetGiftHistoryBloc(this.repository) : super(TargetGiftHistoryInitial()) {
    on<FetchTargetGiftHistory>(_onFetch);
    on<ClaimTargetGiftEvent>(_onClaim);
  }

  Future<void> _onFetch(
    FetchTargetGiftHistory event,
    Emitter<TargetGiftHistoryState> emit,
  ) async {
    emit(TargetGiftHistoryLoading());
    try {
      final data = await repository.fetchTargetGiftHistory();
      final model = TargetGiftHistoryModel.fromJson(data);
      emit(TargetGiftHistoryLoaded(model));
    } catch (e) {
      emit(TargetGiftHistoryFailed(e.toString()));
    }
  }

  Future<void> _onClaim(
    ClaimTargetGiftEvent event,
    Emitter<TargetGiftHistoryState> emit,
  ) async {
    emit(TargetGiftClaiming());
    try {
      final res = await repository.claimTargetGift(
        targetId: event.targetId,
        addressId: event.addressId,
      );
      final msg = res['message']?.toString() ??
          'Gift claimed successfully! Our admin team will dispatch it soon.';
      emit(TargetGiftClaimSuccess(msg));
      add(const FetchTargetGiftHistory());
    } catch (e) {
      emit(TargetGiftClaimFailed(e.toString()));
    }
  }
}
