import 'package:flutter/foundation.dart';
import 'package:grofery_user/config/api_routes.dart';
import 'package:grofery_user/config/constant.dart';
import 'package:grofery_user/config/api_base_helper.dart';

class TargetGiftHistoryRepository {
  Future<Map<String, dynamic>> fetchTargetGiftHistory() async {
    try {
      final response = await AppConstant.apiBaseHelper
          .getAPICall(ApiRoutes.targetGiftHistoryApi, {});
      debugPrint(
          '\x1B[35m🎁 TARGET GIFT HISTORY API RESPONSE: ${response.data}\x1B[0m');
      return response.data;
    } catch (e) {
      throw ApiException('Failed to fetch Target Gift History');
    }
  }

  Future<Map<String, dynamic>> claimTargetGift({
    required int targetId,
    int? addressId,
  }) async {
    try {
      final body = {
        'target_id': targetId,
        if (addressId != null) 'address_id': addressId,
      };
      final response = await AppConstant.apiBaseHelper
          .postAPICall(ApiRoutes.claimTargetGiftApi, body);
      debugPrint(
          '\x1B[35m🎁 CLAIM TARGET GIFT API RESPONSE: ${response.data}\x1B[0m');
      return response.data;
    } catch (e) {
      throw ApiException('Failed to claim gift: ${e.toString()}');
    }
  }
}
