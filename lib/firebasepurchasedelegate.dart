part of masamune.purchase.firebase;

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
      PurchaseProduct product, PurchaseCore core) async {
    if (Config.isAndroid) {
      if (core.androidVerifierOptions == null ||
          isEmpty(core.androidRefreshToken) ||
          isEmpty(core.androidVerifierOptions.clientId) ||
          isEmpty(core.androidVerifierOptions.clientSecret) ||
          isEmpty(core.androidVerifierOptions.publicKey)) return false;
      if (!await verifyString(
          purchase.verificationData.localVerificationData,
          purchase.billingClientPurchase.signature,
          core.androidVerifierOptions.publicKey)) return false;
      switch (product.type) {
        case ProductType.consumable:
          FunctionsTask task = await FunctionsTask.call(
              core.androidVerifierOptions.consumableVerificationServer,
              postData: {
                "refreshToken": core.androidRefreshToken,
                "clientId": core.androidVerifierOptions.clientId,
                "clientSecret": core.androidVerifierOptions.clientSecret,
                "packageName": purchase.billingClientPurchase.packageName,
                "productId": purchase.productID,
                "purchaseToken": purchase.billingClientPurchase.purchaseToken,
                "path": product.targetPath?.applyTags(),
                "value": product.value,
                "user": core.userId
              });
          if (isEmpty(task.data)) return false;
          Map map = task.data as Map;
          if (map == null ||
              !map.containsKey("purchaseState") ||
              map["purchaseState"] != 0) return false;
          break;
        case ProductType.nonConsumable:
          FunctionsTask task = await FunctionsTask.call(
              core.androidVerifierOptions.nonconsumableVerificationServer,
              postData: {
                "refreshToken": core.androidRefreshToken,
                "clientId": core.androidVerifierOptions.clientId,
                "clientSecret": core.androidVerifierOptions.clientSecret,
                "packageName": purchase.billingClientPurchase.packageName,
                "productId": purchase.productID,
                "purchaseToken": purchase.billingClientPurchase.purchaseToken,
                "path": product.targetPath?.applyTags(),
                "user": core.userId
              });
          if (isEmpty(task.data)) return false;
          Map map = task.data as Map;
          if (map == null ||
              !map.containsKey("purchaseState") ||
              map["purchaseState"] != 0) return false;
          break;
        case ProductType.subscription:
          FunctionsTask task = await FunctionsTask.call(
              core.androidVerifierOptions.subscriptionVerificationServer,
              postData: {
                "refreshToken": core.androidRefreshToken,
                "clientId": core.androidVerifierOptions.clientId,
                "clientSecret": core.androidVerifierOptions.clientSecret,
                "packageName": purchase.billingClientPurchase.packageName,
                "productId": purchase.productID,
                "purchaseToken": purchase.billingClientPurchase.purchaseToken,
                "path": product.targetPath?.applyTags(),
                "user": core.userId,
                "expiryDateKey": core.subscribeOptions.expiryDateKey,
                "renewDuration":
                    core.subscribeOptions.renewDuration.inMilliseconds,
                "userIDKey": core.subscribeOptions.userIDKey,
                "tokenKey": core.subscribeOptions.tokenKey,
                "packageNameKey": core.subscribeOptions.packageNameKey,
                "orderIDKey": core.subscribeOptions.orderIDKey,
                "productIDKey": core.subscribeOptions.productIDKey,
                "expiredKey": core.subscribeOptions.expiredKey
              });
          if (isEmpty(task.data)) return false;
          Map map = task.data as Map;
          int startTimeMillis = int.tryParse(map["startTimeMillis"]);
          int expiryTimeMillis = int.tryParse(map["expiryTimeMillis"]);
          if (map == null ||
              startTimeMillis == null ||
              expiryTimeMillis == null ||
              startTimeMillis <= 0 ||
              expiryTimeMillis <= DateTime.now().toUtc().millisecondsSinceEpoch)
            return false;
          break;
      }
    } else if (Config.isIOS) {
      if (core.iosVerifierOptions == null ||
          isEmpty(core.iosVerifierOptions.sharedSecret)) return false;
      switch (product.type) {
        case ProductType.consumable:
          FunctionsTask task = await FunctionsTask.call(
              core.iosVerifierOptions.consumableVerificationServer,
              postData: {
                "receiptData": purchase.verificationData.serverVerificationData,
                "password": core.iosVerifierOptions.sharedSecret,
                "productId": purchase.productID,
                "path": product.targetPath?.applyTags(),
                "value": product.value,
                "user": core.userId
              });
          if (isEmpty(task.data)) return false;
          Map map = task.data as Map;
          if (map == null || !map.containsKey("status") || map["status"] != 0)
            return false;
          break;
        case ProductType.nonConsumable:
          FunctionsTask task = await FunctionsTask.call(
              core.iosVerifierOptions.nonconsumableVerificationServer,
              postData: {
                "receiptData": purchase.verificationData.serverVerificationData,
                "password": core.iosVerifierOptions.sharedSecret,
                "productId": purchase.productID,
                "path": product.targetPath?.applyTags(),
                "user": core.userId
              });
          if (isEmpty(task.data)) return false;
          Map map = task.data as Map;
          if (map == null || !map.containsKey("status") || map["status"] != 0)
            return false;
          break;
        case ProductType.subscription:
          FunctionsTask task = await FunctionsTask.call(
              core.iosVerifierOptions.subscriptionVerificationServer,
              postData: {
                "receiptData": purchase.verificationData.serverVerificationData,
                "password": core.iosVerifierOptions.sharedSecret,
                "productId": purchase.productID,
                "path": product.targetPath?.applyTags(),
                "user": core.userId,
                "expiryDateKey": core.subscribeOptions.expiryDateKey,
                "renewDuration":
                    core.subscribeOptions.renewDuration.inMilliseconds,
                "userIDKey": core.subscribeOptions.userIDKey,
                "tokenKey": core.subscribeOptions.tokenKey,
                "packageNameKey": core.subscribeOptions.packageNameKey,
                "orderIDKey": core.subscribeOptions.orderIDKey,
                "productIDKey": core.subscribeOptions.productIDKey,
                "expiredKey": core.subscribeOptions.expiredKey
              });
          if (isEmpty(task.data)) return false;
          Map map = task.data as Map;
          if (map == null || !map.containsKey("status") || map["status"] != 0)
            return false;
          int startTimeMillis = int.tryParse( map["latest_receipt_info"].first["purchase_date_ms"] );        
          int expiryTimeMillis = int.tryParse( map["latest_receipt_info"].first["expires_date_ms"] );
          if (map == null ||
              startTimeMillis == null ||
              expiryTimeMillis == null ||
              startTimeMillis <= 0 ||
              expiryTimeMillis <= DateTime.now().toUtc().millisecondsSinceEpoch)
            return false;
          break;
      }
    }
    return true;
  }
}
