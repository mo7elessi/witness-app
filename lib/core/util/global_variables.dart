import 'package:flutter/material.dart';
import 'package:nice_shot/data/model/api/login_model.dart';

bool permissionsGranted = false;
String? myToken;
String? myId;

String? get token => myToken;

String? get userId => myId;
LoginModel? currentUserData;

LoginModel? get user => currentUserData;

String rawVideoId = "";

//int? statusCode;
ValueNotifier<int> statusCode = ValueNotifier<int>(300);
