import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grofery_user/config/api_routes.dart';
import 'package:grofery_user/config/constant.dart';
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
      int? addressIdToUse = event.addressId;
      
      if (addressIdToUse == null) {
        try {
          final addressRes = await AppConstant.apiBaseHelper.getAPICall(ApiRoutes.getAddressesApi, {});
          if (addressRes.data != null && addressRes.data['data'] != null) {
             final dataList = addressRes.data['data']['data'] as List?;
             if (dataList != null && dataList.isNotEmpty) {
               addressIdToUse = dataList.first['id'] as int?;
             }
          }
        } catch (e) {
          // Ignore address fetch error and proceed
        }
        
        if (addressIdToUse == null) {
           emit(const TargetGiftClaimFailed('Please add a delivery address first.'));
           return;
        }
      }

      final res = await repository.claimTargetGift(
        targetId: event.targetId,
        addressId: addressIdToUse,
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
