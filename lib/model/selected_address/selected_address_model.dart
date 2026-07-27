import 'package:hive_flutter/hive_flutter.dart';
import 'package:grofery_user/screens/address_list_page/model/get_address_list_model.dart';

part 'selected_address_model.g.dart';


@HiveType(typeId: 2)
class SelectedAddress extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  int? userId;

  @HiveField(2)
  String? addressLine1;

  @HiveField(3)
  String? addressLine2;

  @HiveField(4)
  String? city;

  @HiveField(5)
  String? landmark;

  @HiveField(6)
  String? state;

  @HiveField(7)
  String? zipcode;

  @HiveField(8)
  String? mobile;

  @HiveField(9)
  String? addressType;

  @HiveField(10)
  String? country;

  @HiveField(11)
  String? countryCode;

  @HiveField(12)
  String? latitude;

  @HiveField(13)
  String? longitude;

  @HiveField(14)
  String? createdAt;

  @HiveField(15)
  String? updatedAt;

  SelectedAddress({
    this.id,
    this.userId,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.landmark,
    this.state,
    this.zipcode,
    this.mobile,
    this.addressType,
    this.country,
    this.countryCode,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert from AddressListData to SelectedAddress
  factory SelectedAddress.fromAddressListData(dynamic addressListData) {
    return SelectedAddress(
      id: addressListData.id,
      userId: addressListData.userId,
      addressLine1: addressListData.addressLine1,
      addressLine2: addressListData.addressLine2,
      city: addressListData.city,
      landmark: addressListData.landmark,
      state: addressListData.state,
      zipcode: addressListData.zipcode,
      mobile: addressListData.mobile,
      addressType: addressListData.addressType,
      country: addressListData.country,
      countryCode: addressListData.countryCode,
      latitude: addressListData.latitude,
      longitude: addressListData.longitude,
      createdAt: addressListData.createdAt,
      updatedAt: addressListData.updatedAt,
    );
  }

  /// Convert to AddressListData
  AddressListData toAddressListData() {
    return AddressListData(
      id: id,
      userId: userId,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      landmark: landmark,
      state: state,
      zipcode: zipcode,
      mobile: mobile,
      addressType: addressType,
      country: country,
      countryCode: countryCode,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Get formatted address string
  String getFormattedAddress() {
    List<String> parts = [];
    
    if (addressLine1 != null && addressLine1!.isNotEmpty) {
      parts.add(addressLine1!);
    }
    if (zipcode != null && zipcode!.isNotEmpty) {
      parts.add(zipcode!);
    }

    return parts.join(', ');
  }

  /// Get formatted address with landmark
  String getFullAddress() {
    String address = getFormattedAddress();
    if (landmark != null && landmark!.isNotEmpty) {
      address = '$address (Near $landmark)';
    }
    return address;
  }
}

