// Copyright 2020 mathru. All rights reserved.

/// Masamune purchasing framework library with firebase.
///
/// To use, import `package:masamune_purchase_firebase/masamune_purchase_firebase.dart`.
///
/// [mathru.net]: https://mathru.net
/// [YouTube]: https://www.youtube.com/c/mathrunetchannel
library masamune.purchase.firebase;

import 'package:http/http.dart';
import 'package:masamune_firebase_mobile/masamune_firebase_mobile.dart';
import 'package:simple_rsa/simple_rsa.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:masamune_flutter/masamune_flutter.dart';
import 'package:masamune_purchase/masamune_purchase.dart';

export 'package:masamune_flutter/masamune_flutter.dart';
export 'package:masamune_purchase/masamune_purchase.dart';
export 'package:masamune_firebase/masamune_firebase.dart';
export 'package:masamune_firebase_mobile/masamune_firebase_mobile.dart';

part 'firebasepurchasedelegate.dart';
