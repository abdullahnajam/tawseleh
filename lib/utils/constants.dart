
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


const primaryColor=Colors.lightBlueAccent;
const secondaryColor=Colors.blueAccent;

const lightColor=Colors.black;

const bgColor=Color(0xfff6f7fb);

const whiteColor=Colors.white;
const meChatBubble= Color(0xffEFFFDE);
const textColor=Colors.blueGrey;
final df = new DateFormat('dd/MM/yy');
final tf = new DateFormat('hh:mm');
final dtf = new DateFormat('dd/MM/yy hh:mm');

List<String> languages = <String>['English', 'العربية'];

bool isEnglish(BuildContext context){
  return context.locale.languageCode=='ar'?false:true;
}

String prettyDuration(Duration d) {
  var min = d.inMinutes < 10 ? "0${d.inMinutes}" : d.inMinutes.toString();
  var sec = d.inSeconds < 10 ? "0${d.inSeconds}" : d.inSeconds.toString();
  return min + ":" + sec;
}

const kGoogleApiKey = "AIzaSyBhCef5WuAuPKRVoPuWQASD6avTs16x7uE";

const drawerHeadGradient=LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: <Color>[
    lightColor,
    primaryColor,

  ],
  tileMode: TileMode.repeated,
);

const stripeSecretKey="sk_test_51Fr7qiIgr6dOAyhFKFDRrH9jeHAED9YCwF9lq3aUcaXWSVybW1EeAeMB4Qnp2JogMat3fGyyPc6nii7zXQyseZLH007R0PvvHG";
const stripePublishKey="pk_test_8MrVkLk4OXfAB2ASmHJtfK7T00QgidJrLX";
const loremIpsum="Lorem ipsum dolor sit amet, consectetur adipiscing elit leo felis congue elit leo.";
const serverToken="AAAACfUoj6w:APA91bG8CBaXLESOehpvpFc6et30knT0ha9OrkKe3UK2FHQ3t5c8MeJdrpx9dRk8JCvMFuSEMO3oC5vDBMfzWQD955lRV63_dR308LHXavwLlkAUKYzuIcKX6_v_LYWKcttuGWjc1iCp";



const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

String getMessageFromErrorCode(errorCode) {
  switch (errorCode) {
    case "ERROR_EMAIL_ALREADY_IN_USE":
    case "account-exists-with-different-credential":
    case "email-already-in-use":
      return "Email already used. Go to login page.";
      break;
    case "ERROR_WRONG_PASSWORD":
    case "wrong-password":
      return "Wrong email/password combination.";
      break;
    case "ERROR_USER_NOT_FOUND":
    case "user-not-found":
      return "No user found with this email.";
      break;
    case "ERROR_USER_DISABLED":
    case "user-disabled":
      return "User disabled.";
      break;
    case "ERROR_TOO_MANY_REQUESTS":
    case "operation-not-allowed":
      return "Too many requests to log into this account.";
      break;
    case "ERROR_OPERATION_NOT_ALLOWED":
    case "operation-not-allowed":
      return "Server error, please try again later.";
      break;
    case "ERROR_INVALID_EMAIL":
    case "invalid-email":
      return "Email address is invalid.";
      break;
    default:
      return "Login failed. Please try again.";
      break;
  }
}