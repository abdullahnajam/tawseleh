import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/chat_model.dart';


class ChatProvider extends ChangeNotifier {
  bool _showSend=false;
  bool _options=false;
  ChatModel? selectedChat;



  bool get showSend => _showSend;
  bool get option => _options;


  void setShowSend(bool value) {
    _showSend = value;
    notifyListeners();
  }

  void setSelectedChat(ChatModel? value) {
    selectedChat = value;
    notifyListeners();
  }
  void setOptions(bool value) {
    _options = value;
    notifyListeners();
  }





  ChatProvider(){
    initRecorder();
  }
  void chatReset(){
    _showSend=false;
    _options=false;
    isRecordReady=false;
    selectedChat=null;


    notifyListeners();
  }
  bool isRecordReady=false;
  final recorder=FlutterSoundRecorder();

  Future record()async{
    await recorder.startRecorder(toFile: 'audio');
    notifyListeners();

  }
  Future<File> stop()async{
    final path=await recorder.stopRecorder();
    notifyListeners();
    print("file path : $path");
    return File(path!);
  }
  Future initRecorder() async{
    final status= await Permission.microphone.request();
    if(status!=PermissionStatus.granted){
      throw 'permission not granted';
    }
    await recorder.openRecorder();
    isRecordReady=true;
    notifyListeners();
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));


  }


}
