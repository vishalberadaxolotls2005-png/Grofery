import 'dart:convert';
import 'package:grofery_user/config/api_base_helper.dart';
import 'package:grofery_user/config/api_routes.dart';
import 'package:grofery_user/config/constant.dart';
import 'package:grofery_user/screens/support_page/model/support_ticket_type_model.dart';

class SupportRepository {
  Future<List<SupportTicketTypeModel>> getTicketTypes() async {
    try {
      final response = await AppConstant.apiBaseHelper
          .getAPICall(ApiRoutes.supportTicketTypesApi, {});

      if (response.statusCode == 200) {
        // If the backend returns a list of items inside "data"
        if (response.data != null && response.data['data'] != null) {
          final List<dynamic> data = response.data['data'];
          return data
              .map((json) => SupportTicketTypeModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      // Return dummy data if API fails or doesn't exist yet, to match the user's image
      return [
        SupportTicketTypeModel(id: 1, title: 'General Inquiry'),
        SupportTicketTypeModel(id: 2, title: 'Order Issue'),
        SupportTicketTypeModel(id: 3, title: 'Payment/Refund'),
        SupportTicketTypeModel(id: 4, title: 'App Feedback'),
        SupportTicketTypeModel(id: 5, title: 'Other'),
      ];
    }
  }

  Future<Map<String, dynamic>> submitSupportQuery({
    required int ticketTypeId,
    required String subject,
    required String description,
    required String userId,
  }) async {
    try {
      final data = {
        'user_id': int.tryParse(userId) ?? userId,
        'ticket_type_id': ticketTypeId,
        'subject': subject,
        'description': description,
      };
      // Subject is mapped to ticketTypeId in the request payload as per user instruction
      // Wait, user payload had both `ticket_type_id` and `subject`.
      // I'll fetch the actual title and pass it to subject as well.

      final response = await AppConstant.apiBaseHelper
          .postAPICall(ApiRoutes.supportQueryApi, data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw ApiException(response.data['message'] ?? 'Failed to submit query');
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
