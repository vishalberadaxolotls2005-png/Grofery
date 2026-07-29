import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repo/special_offer_repo.dart';
import '../../model/special_offer_model.dart';
import 'special_offer_event.dart';
import 'special_offer_state.dart';

class SpecialOfferBloc extends Bloc<SpecialOfferEvent, SpecialOfferState> {
  final SpecialOfferRepository repository;

  SpecialOfferBloc(this.repository) : super(SpecialOfferInitial()) {
    on<FetchSpecialOffers>(_onFetchSpecialOffers);
    on<ClearSpecialOffers>(_onClearSpecialOffers);
  }

  void _onClearSpecialOffers(ClearSpecialOffers event, Emitter<SpecialOfferState> emit) {
    emit(SpecialOfferInitial());
  }

  Future<void> _onFetchSpecialOffers(FetchSpecialOffers event, Emitter<SpecialOfferState> emit) async {
    emit(SpecialOfferLoading());
    try {
      final response = await repository.fetchSpecialOffers();
      
      if (response['success'] == true) {
        final specialOfferModel = SpecialOfferModel.fromJson(response);
        emit(SpecialOfferLoaded(specialOfferModel: specialOfferModel));
      } else {
        emit(SpecialOfferFailed(error: response['message'] ?? 'Failed to load special offers'));
      }
    } catch (e) {
      emit(SpecialOfferFailed(error: e.toString()));
    }
  }
}
