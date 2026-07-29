class SpecialOfferModel {
  bool? success;
  String? message;
  SpecialOfferApiData? data;

  SpecialOfferModel({this.success, this.message, this.data});

  SpecialOfferModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? SpecialOfferApiData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class SpecialOfferApiData {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;
  List<SpecialOfferBannerData>? data;

  SpecialOfferApiData(
      {this.currentPage, this.lastPage, this.perPage, this.total, this.data});

  SpecialOfferApiData.fromJson(Map<String, dynamic> json) {
    currentPage = _parseInt(json['current_page']);
    lastPage = _parseInt(json['last_page']);
    perPage = _parseInt(json['per_page']);
    total = _parseInt(json['total']);
    if (json['data'] != null) {
      data = <SpecialOfferBannerData>[];
      json['data'].forEach((v) {
        data!.add(SpecialOfferBannerData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['last_page'] = lastPage;
    data['per_page'] = perPage;
    data['total'] = total;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  int? _parseInt(dynamic value) {
    if (value == null || value == "") return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class SpecialOfferBannerData {
  int? id;
  String? bannerImage;
  String? status;
  String? createdAt;

  SpecialOfferBannerData({
    this.id,
    this.bannerImage,
    this.status,
    this.createdAt,
  });

  SpecialOfferBannerData.fromJson(Map<String, dynamic> json) {
    id = _parseInt(json['id']);
    bannerImage = json['banner_image'];
    status = json['status'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['banner_image'] = bannerImage;
    data['status'] = status;
    data['created_at'] = createdAt;
    return data;
  }

  int? _parseInt(dynamic value) {
    if (value == null || value == "") return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
