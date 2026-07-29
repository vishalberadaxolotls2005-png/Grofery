import '../../model/special_offer_model.dart';

abstract class SpecialOfferState {}

class SpecialOfferInitial extends SpecialOfferState {}

class SpecialOfferLoading extends SpecialOfferState {}

class SpecialOfferLoaded extends SpecialOfferState {
  final SpecialOfferModel specialOfferModel;

  SpecialOfferLoaded({required this.specialOfferModel});
}

class SpecialOfferFailed extends SpecialOfferState {
  final String error;

  SpecialOfferFailed({required this.error});
}
