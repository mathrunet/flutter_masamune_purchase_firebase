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
          final data = await functions.call(parameters: {
            "purchaseId": purchase.purchaseID,
            "packageName": purchase.billingClientPurchase?.packageName,
            "productId": purchase.productID,
            "purchaseToken": purchase.billingClientPurchase?.purchaseToken,
            "path": product.targetPath,
            "value": product.value,
            "user": core.userId
          });
          if (data is! Map) return false;
          if (!data.containsKey("purchaseState") ||
              data["purchaseState"] != 0) {
            return false;
          }
          break;
        case ProductType.nonConsumable:
          final functions = readProvider(functionsProvider(
              core.androidVerifierOptions.nonconsumableVerificationServer ??
                  ""));
          final data = await functions.call(parameters: {
            "purchaseId": purchase.purchaseID,
            "packageName": purchase.billingClientPurchase?.packageName,
            "productId": purchase.productID,
            "purchaseToken": purchase.billingClientPurchase?.purchaseToken,
            "path": product.targetPath,
            "user": core.userId
          });
          if (data is! Map) return false;
          if (!data.containsKey("purchaseState") ||
              data["purchaseState"] != 0) {
            return false;
          }
          break;
        case ProductType.subscription:
          final params =
              (await product.subscriptionData?.call(purchase, core)) ?? {};
          final functions = readProvider(functionsProvider(
              core.androidVerifierOptions.subscriptionVerificationServer ??
                  ""));
          final data = await functions.call(parameters: {
            "purchaseId": purchase.purchaseID,
            "packageName": purchase.billingClientPurchase?.packageName,
            "productId": purchase.productID,
            "purchaseToken": purchase.billingClientPurchase?.purchaseToken,
            "path": product.targetPath,
            "user": core.userId,
            "data": params,
          });
          if (data is! Map) return false;
          final now = DateTime.now();
          final startTimeMillis = data.containsKey("startTimeMillis")
              ? int.tryParse(data["startTimeMillis"]).def(0)
              : 0;
          final expiresTimeMillis = data.containsKey("expiryTimeMillis")
              ? int.tryParse(data["expiryTimeMillis"]).def(0)
              : 0;
          if (startTimeMillis <= 0) {
            return false;
          }
          if (expiresTimeMillis <= now.millisecondsSinceEpoch) {
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
              core.iosVerifierOptions.consumableVerificationServer ?? ""));
          final data = await functions.call(parameters: {
            "receiptData": purchase.verificationData.serverVerificationData,
            "purchaseId": purchase.purchaseID,
            "productId": purchase.productID,
            "path": product.targetPath,
            "value": product.value,
            "user": core.userId
          });
          if (data is! Map) return false;
          if (!data.containsKey("status") || data["status"] != 0) {
            return false;
          }
          break;
        case ProductType.nonConsumable:
          final functions = readProvider(functionsProvider(
              core.iosVerifierOptions.nonconsumableVerificationServer ?? ""));
          final data = await functions.call(parameters: {
            "receiptData": purchase.verificationData.serverVerificationData,
            "purchaseId": purchase.purchaseID,
            "productId": purchase.productID,
            "path": product.targetPath,
            "user": core.userId
          });
          if (data is! Map) return false;
          if (!data.containsKey("status") || data["status"] != 0) {
            return false;
          }
          break;
        case ProductType.subscription:
          final params =
              (await product.subscriptionData?.call(purchase, core)) ?? {};
          final functions = readProvider(functionsProvider(
              core.iosVerifierOptions.subscriptionVerificationServer ?? ""));
          final data = await functions.call(parameters: {
            "receiptData": purchase.verificationData.serverVerificationData,
            "purchaseId": purchase.purchaseID,
            "productId": purchase.productID,
            "path": product.targetPath,
            "user": core.userId,
            "data": params,
          });
          if (data is! Map) return false;
          if (!data.containsKey("status") || data["status"] != 0) {
            return false;
          }
          final now = DateTime.now();
          final latestReceiptInfo = data.containsKey("latest_receipt_info")
              ? (data["latest_receipt_info"] as List)
                  .cast<Map>()
                  .first
                  .cast<String, dynamic>()
              : const <String, dynamic>{};
          final startTimeMillis =
              int.tryParse(latestReceiptInfo.get("purchase_date_ms", "0"))
                  .def(0);
          final expiresTimeMillis =
              int.tryParse(latestReceiptInfo.get("expires_date_ms", "0"))
                  .def(0);
          if (startTimeMillis <= 0) {
            return false;
          }
          if (expiresTimeMillis <= now.millisecondsSinceEpoch) {
            return false;
          }
          break;
      }
    }
    return true;
  }
}
