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
      FunctionsTask task = await FunctionsTask.call(
          core.androidVerifierOptions.verificationServer,
          postData: {
            "refreshToken": core.androidRefreshToken,
            "clientId": core.androidVerifierOptions.clientId,
            "clientSecret": core.androidVerifierOptions.clientSecret,
            "packageName": purchase.billingClientPurchase.packageName,
            "productId": purchase.productID,
            "purchaseToken": purchase.billingClientPurchase.purchaseToken,
            "path": core.deliverOptions.path?.applyTags(),
            "value": product.value,
            "user": core.userId
          });
      Log.msg(task.data);
      if (isEmpty(task.data)) return false;
      Map map = task.data as Map;
      if (map == null ||
          !map.containsKey("purchaseState") ||
          map["purchaseState"] != 0) return false;
    } else if (Config.isIOS) {
      if (core.iosVerifierOptions == null ||
          isEmpty(core.iosVerifierOptions.sharedSecret)) return false;
      FunctionsTask task = await FunctionsTask.call(
          core.iosVerifierOptions.verificationServer,
          postData: {
            "receiptData": purchase.verificationData.serverVerificationData,
            "password": core.iosVerifierOptions.sharedSecret,
            "productId": purchase.productID,
            "path": core.deliverOptions.path?.applyTags(),
            "value": product.value,
            "user": core.userId
          });
      Log.msg(task.data);
      if (isEmpty(task.data)) return false;
      Map map = task.data as Map;
    }
    return true;
  }
}
