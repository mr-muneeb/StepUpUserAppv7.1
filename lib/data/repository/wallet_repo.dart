import 'package:flutter_grocery/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_grocery/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_grocery/data/model/response/base/api_response.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletRepo {
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;

  WalletRepo({required this.dioClient, required this.sharedPreferences,});

  Future<ApiResponse> getWalletTransactionList(String offset, String type) async {
    try {
      final response = await dioClient!.get('${AppConstants.walletTransactionUrl}?offset=$offset&limit=10&transaction_type=$type');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getLoyaltyTransactionList(String offset, String type) async {
    try {
      final response = await dioClient!.get('${AppConstants.loyaltyTransactionUrl}?offset=$offset&limit=10&type=$type');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> pointToWallet({int? point}) async {
    try {
      final response = await dioClient!.post(AppConstants.loyaltyPointTransferUrl, data: {'point' : point});
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getWalletBonusList() async {
    try {
      final response = await dioClient!.get(AppConstants.walletBonusListUrl);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


}