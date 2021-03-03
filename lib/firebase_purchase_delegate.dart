part of masamune_purchase_firebase;

/// [PurchaseCore] is used as a callback for [onVerify] of [PurchaseCore].
///
/// The signature is verified and the receipt is verified by firebase.
class FirebasePurchaseDelegate {
  /// [PurchaseCore] is used as a callback for [onVerify] of [PurchaseCore].
  ///
  /// The signature is verified and the receipt is verified by firebase.
  ///
  /// [purchase]: PurchaseDetails.
  /// [product]: The purchased product.
  /// [core]: Purchase Core instance.
  static Future<bool> verifyAndDeliver(PurchaseDetails purchase,
      PurchaseProduct product, PurchaseModel core) async {
    if (Config.isAndroid) {
      switch (product.type) {
        case ProductType.consumable:
          final functions = readProvider(functionsProvider(
              core.androidVerifierOptions.consumableVerificationServer ?? ""));
          final data = functions.call(parameters: {
            "purchaseId": purchase.purchaseID,
            "packageName": purchase.billingClientPurchase?.packageName,
            "productId": purchase.productID,
            "purchaseToken": purchase.billingClientPurchase?.purchaseToken,
            "path": product.targetPath,
            "value": product.value,
            "user": core.userId
          });
          if (data is Map<String, dynamic>) return false;
          final map = data as Map<String, dynamic>;
          if (!map.containsKey("purchaseState") || map["purchaseState"] != 0) {
            return false;
          }
          break;
        case ProductType.nonConsumable:
          final functions = readProvider(functionsProvider(
              core.androidVerifierOptions.nonconsumableVerificationServer ??
                  ""));
          final data = functions.call(parameters: {
            "purchaseId": purchase.purchaseID,
            "packageName": purchase.billingClientPurchase?.packageName,
            "productId": purchase.productID,
            "purchaseToken": purchase.billingClientPurchase?.purchaseToken,
            "path": product.targetPath,
            "user": core.userId
          });
          if (data is Map<String, dynamic>) return false;
          final map = data as Map<String, dynamic>;
          if (!map.containsKey("purchaseState") || map["purchaseState"] != 0) {
            return false;
          }
          break;
        case ProductType.subscription:
          final functions = readProvider(functionsProvider(
              core.androidVerifierOptions.subscriptionVerificationServer ??
                  ""));
          final data = functions.call(parameters: {
            "purchaseId": purchase.purchaseID,
            "packageName": purchase.billingClientPurchase?.packageName,
            "productId": purchase.productID,
            "purchaseToken": purchase.billingClientPurchase?.purchaseToken,
            "path": product.targetPath,
            "user": core.userId
          });
          if (data is Map<String, dynamic>) return false;
          final map = data as Map<String, dynamic>;
          int startTimeMillis =
              int.tryParse(map.get<String>("startTimeMillis").def("0")) ?? 0;
          if (startTimeMillis <= 0) {
            return false;
          }
          break;
      }
    } else if (Config.isIOS) {
      // if (core.iosVerifierOptions == null ||
      //     isEmpty(core.iosVerifierOptions.sharedSecret)) return false;
      switch (product.type) {
        case ProductType.consumable:
          final functions = readProvider(functionsProvider(
              core.androidVerifierOptions.subscriptionVerificationServer ??
                  ""));
          final data = functions.call(parameters: {
            "receiptData": purchase.verificationData.serverVerificationData,
            "purchaseId": purchase.purchaseID,
            "productId": purchase.productID,
            "path": product.targetPath,
            "value": product.value,
            "user": core.userId
          });
          if (data is Map<String, dynamic>) return false;
          final map = data as Map<String, dynamic>;
          if (!map.containsKey("status") || map["status"] != 0) {
            return false;
          }
          break;
        case ProductType.nonConsumable:
          final functions = readProvider(functionsProvider(
              core.androidVerifierOptions.subscriptionVerificationServer ??
                  ""));
          final data = functions.call(parameters: {
            "receiptData": purchase.verificationData.serverVerificationData,
            "purchaseId": purchase.purchaseID,
            "productId": purchase.productID,
            "path": product.targetPath,
            "user": core.userId
          });
          if (data is Map<String, dynamic>) return false;
          final map = data as Map<String, dynamic>;
          if (!map.containsKey("status") || map["status"] != 0) {
            return false;
          }
          break;
        case ProductType.subscription:
          final functions = readProvider(functionsProvider(
              core.androidVerifierOptions.subscriptionVerificationServer ??
                  ""));
          final data = functions.call(parameters: {
            "receiptData": purchase.verificationData.serverVerificationData,
            "purchaseId": purchase.purchaseID,
            "productId": purchase.productID,
            "path": product.targetPath,
            "user": core.userId
          });
          if (data is Map<String, dynamic>) return false;
          final map = data as Map<String, dynamic>;
          if (!map.containsKey("status") || map["status"] != 0) {
            return false;
          }
          final latestReceiptInfo = map
                  .get<List<Map<String, dynamic>>>("latest_receipt_info")
                  ?.first ??
              {};
          int startTimeMillis = int.tryParse(
                  latestReceiptInfo.get<String>("purchase_date_ms").def("0")) ??
              0;
          if (startTimeMillis <= 0) {
            return false;
          }
          break;
      }
    }
    return true;
  }
}
