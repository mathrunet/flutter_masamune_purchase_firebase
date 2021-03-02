// Copyright 2021 mathru. All rights reserved.

/// Masamune purchasing framework library with firebase.
///
/// To use, import `package:masamune_purchase_firebase/masamune_purchase_firebase.dart`.
///
/// [mathru.net]: https://mathru.net
/// [YouTube]: https://www.youtube.com/c/mathrunetchannel
library masamune_purchase_firebase;

import 'package:http/http.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:masamune/masamune.dart';
import 'package:firebase_model_notifier/firebase_model_notifier.dart';
import 'package:masamune_purchase/masamune_purchase.dart';

export 'package:masamune/masamune.dart';
export 'package:masamune_purchase/masamune_purchase.dart';
export 'package:firebase_model_notifier/firebase_model_notifier.dart';

part 'firebase_purchase_delegate.dart';
