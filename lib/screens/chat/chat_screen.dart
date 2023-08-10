import 'dart:async';
import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocode/geocode.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tawseleh/api/image_api.dart';
import 'package:tawseleh/widgets/profile_image.dart';
import 'package:whatsapp_camera/camera/camera_whatsapp.dart';

import '../../api/db_api.dart';
import '../../api/location.dart';
import '../../model/chat_model.dart';
import '../../model/user_model.dart';
import '../../provider/chat_provider.dart';
import '../../provider/user_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/chat_widgets.dart';

class ChatScreen extends StatefulWidget {
  String chatheadId;

  ChatScreen(this.chatheadId);

  @override
  State<ChatScreen> createState() => _IndividualChatState();
}

class _IndividualChatState extends State<ChatScreen> {

  final TextEditingController inputController = new TextEditingController();
  ScrollController _scrollController = new ScrollController();







  Future<File> _chooseCamera() async{
    File file;
    final image=await ImagePicker().pickImage(source: ImageSource.camera);
    return File(image!.path);
  }


  _scroll(){
    print('scroll before');
    Timer(Duration(seconds: 3), () {
      print('scroll after');
      //_scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      print("This line is execute after 5 seconds");
    });

  }

  late final _focusNode = FocusNode(
    onKey: (FocusNode node, RawKeyEvent evt) {
      if (!evt.isShiftPressed && evt.logicalKey.keyLabel == 'Enter') {
        if (evt is RawKeyDownEvent) {
          //_sendMessage();
        }
        return KeyEventResult.handled;
      }
      else {
        return KeyEventResult.ignored;
      }
    },
  );
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final provider = Provider.of<ChatProvider>(context, listen: false);
      provider.chatReset();
      print('header ${widget.chatheadId}');
    });
  }


  @override
  Widget build(BuildContext context) {



    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: Image.asset('assets/images/logo.png',color: primaryColor.shade200,opacity:  AlwaysStoppedAnimation(.5),),
              ),
            ),
            Column(
              children: [
                FutureBuilder<UserModel>(
                    future: DBApi.getUserData(getRecieverId(widget.chatheadId)),
                    builder: (context, AsyncSnapshot<UserModel> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          alignment: Alignment.center,
                          child: CupertinoActivityIndicator(),
                        );
                      }
                      else {
                        if (snapshot.hasError) {
                          print("error ${snapshot.error}");
                          return Container(
                            color: primaryColor,
                            child: Center(
                              child: Text("something went wrong"),
                            ),
                          );
                        }


                        else {
                          return Consumer<ChatProvider>(
                            builder: (context, chat, child) {
                              return Container(
                                padding: EdgeInsets.only(top: 5,bottom: 5),
                                color: primaryColor,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: (){
                                            Navigator.pop(context);
                                          },
                                          icon: Icon(Icons.arrow_back,color: Colors.white,),
                                        ),
                                        ProfilePicture(url: snapshot.data!.profilePic),
                                        SizedBox(width: 10,),
                                        Text('${snapshot.data!.firstName} ${snapshot.data!.lastName}', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        if(chat.selectedChat!=null)
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: ()async{
                                                  await FirebaseFirestore.instance.collection('social_chat').doc(chat.selectedChat!.id).delete().then((value){
                                                    chat.setSelectedChat(null);
                                                  });

                                                },
                                                child: Icon(Icons.delete,color: Colors.white,),
                                              ),
                                              SizedBox(width: 20,),
                                              InkWell(
                                                onTap: ()async{
                                                  FlutterClipboard.copy(chat.selectedChat!.message).then(( value ){
                                                    Fluttertoast.showToast(
                                                      msg: "Copied",
                                                      toastLength: Toast.LENGTH_SHORT,
                                                      gravity: ToastGravity.BOTTOM,
                                                    );
                                                    chat.setSelectedChat(null);
                                                  });

                                                },
                                                child: Icon(Icons.copy,color: Colors.white,),
                                              ),
                                              SizedBox(width: 15,),
                                            ],
                                          ),
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if(value=='block'){
                                              final provider = Provider.of<UserDataProvider>(context, listen: false);
                                              if(!provider.userData!.blockList.contains(getRecieverId(widget.chatheadId))){
                                                provider.addBlockedUser(getRecieverId(widget.chatheadId));
                                                DBApi.blockUser(provider.userData!.blockList);
                                              }

                                            }
                                          },
                                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                            PopupMenuItem<String>(
                                              value: 'block',
                                              child: Text('Block User'.tr()),
                                            ),
                                          ],
                                          child: Icon(Icons.more_vert,color: Colors.white,),
                                        )
                                      ],
                                    )

                                  ],
                                ),
                              );
                            },
                          );

                        }
                      }
                    }
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('social_chat')
                              .where("groupId",isEqualTo: widget.chatheadId)
                              .where("visible",isEqualTo: false)
                              .orderBy('count',descending: true).snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  children: [
                                    const Text("Something Went Wrong",style: TextStyle(color: Colors.black))

                                  ],
                                ),
                              );
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.data!.size==0){
                              return Center(
                                  child: Text('No Data Found'.tr(),style: TextStyle(color: Colors.black))
                              );

                            }

                            return ListView(
                              shrinkWrap: true,
                              reverse: true,
                              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                                print('serverTime ${document.reference.id} ${data['serverTime']}');
                                ChatModel model=ChatModel.fromMap(data,document.reference.id);
                                return Consumer<ChatProvider>(
                                  builder: (context,chat,child){
                                    return GestureDetector(
                                      onLongPress: (){
                                        chat.setSelectedChat(model);
                                      },

                                        child: model.message=="uploading"?
                                        ChatWidget.loader(context, model.senderId==FirebaseAuth.instance.currentUser!.uid?true:false, model.senderId)
                                            :
                                        buildListItemView(context,model)
                                    );
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                      Consumer<UserDataProvider>(
                        builder: (context, provider, child) {
                          return Column(
                            children: [
                              if(provider.userData!.blockList.contains(getRecieverId(widget.chatheadId)))
                                blockedUser()
                              else
                                messageBar()
                            ],
                          );
                        },
                      )

                    ],
                  ),
                )
              ],
            ),
          ],
        )
      ),
    );
  }

  Widget messageBar(){
    return Consumer<ChatProvider>(
      builder: (context,chat,child){
        return Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            alignment: Alignment.centerLeft,
            child: Column(
              children: [

                Container(
                  child: Row(
                    children: <Widget>[
                      if(chat.recorder.isRecording)
                        InkWell(
                          onTap: ()async{
                            if(chat.recorder.isRecording){
                              await chat.stop();
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.delete,color: Colors.white,),
                          ),
                        )
                      else
                        InkWell(
                          onTap: ()async{
                            //File imageFile=await _chooseCamera();
                            List<File>? res = await Navigator.push(
                              context, MaterialPageRoute(
                              builder: (context) => const WhatsappCamera(),
                            ),
                            );

                            for(int i=0; i<res!.length;i++){
                              await DBApi.storeChat(
                                context,
                                "uploading",
                                widget.chatheadId,
                                MediaType.image,
                                false,
                              ).then((value){

                                ImageHandler.uploadFileToFirebase(context, res[i],value);
                              });
                            }

                          },
                          child:  CircleAvatar(
                            backgroundColor: primaryColor,
                            child: Icon(Icons.camera_alt,color: Colors.white,),
                          ),
                        ),
                      if(chat.recorder.isRecording)
                        Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: StreamBuilder<RecordingDisposition>(
                                stream: chat.recorder.onProgress,
                                builder: (context,AsyncSnapshot<RecordingDisposition> snapshot){
                                  final duration=snapshot.hasData?snapshot.data!.duration:Duration.zero;
                                  if(snapshot.hasError){
                                    return Text("error ${snapshot.error.toString()}");
                                  }
                                  return Text(prettyDuration(duration));
                                },
                              ),
                            )
                        )
                      else
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: TextField(
                              controller: inputController,
                              maxLines: null,
                              minLines: 1,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              decoration:const InputDecoration.collapsed(
                                  hintText: 'Message'
                              ),
                              onChanged: (value){
                                print('value llll ${value.length}');
                                if(value.trim().isEmpty){
                                  chat.setShowSend(false);
                                }
                                else{
                                  chat.setShowSend(true);
                                }

                              },
                            ),
                          ),
                        ),
                      if(chat.showSend)
                        IconButton(
                            icon: Icon( Icons.send, color: Colors.blue),

                            onPressed: () async{
                              sendMessage(widget.chatheadId);
                            }
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if(!chat.recorder.isRecording)
                              IconButton(
                                icon: Icon(Icons.place, color: Colors.blue),

                                onPressed: () async{
                                  List coordinates=await getUserCurrentCoordinates();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlacePicker(
                                        apiKey: kGoogleApiKey,
                                        onPlacePicked: (result) async{
                                          String formattedAddress="${coordinates[0]}:${coordinates[1]}+${result.formattedAddress}";

                                          await DBApi.storeChat(
                                              context,
                                              formattedAddress,
                                              widget.chatheadId,
                                              MediaType.location,
                                              false
                                          );


                                          Navigator.of(context).pop();
                                        },
                                        initialPosition: LatLng(coordinates[0], coordinates[1]),
                                        useCurrentLocation: true,
                                      ),
                                    ),
                                  );
                                  /*List<double> coordinates=await getUserCurrentCoordinates();
                                                    GeoCode geoCode = GeoCode();
                                                    Address address=await geoCode.reverseGeocoding(latitude: coordinates[0], longitude: coordinates[1]);
                                                    String formattedAddress="${coordinates[0]}:${coordinates[1]}+${address.streetAddress}, ${address.city}, ${address.countryName}, ${address.postal}";
                                                    setState(() {
                                                      print('formattedAddress $formattedAddress');
                                                    });*/



                                },
                              ),

                            IconButton(
                                icon: Icon(chat.recorder.isRecording?Icons.stop:Icons.mic, color: chat.recorder.isRecording?Colors.redAccent:Colors.blue),

                                onPressed: () async{
                                  if(chat.recorder.isRecording){
                                    File audioFile=await chat.stop();

                                    await DBApi.storeChat(
                                        context,
                                        "uploading",
                                        widget.chatheadId,
                                        MediaType.audio,
                                        false
                                    ).then((value){
                                      ImageHandler.uploadFileToFirebase(context, audioFile,value);
                                    });
                                    //uploadFileToFirebase(context, audioFile, widget.chatheadId,MediaType.audio,chat.reply,chat.selectedModel==null?"":chat.selectedModel.id);
                                  }
                                  else{
                                    await chat.record();
                                  }

                                }
                            ),
                          ],
                        ),



                    ],
                  ),
                ),
              ],
            )
        );
      },
    );
  }

  Widget blockedUser(){
    final provider = Provider.of<UserDataProvider>(context, listen: false);
    return InkWell(
      onTap: (){
        if(provider.userData!.blockList.contains(getRecieverId(widget.chatheadId))){
          provider.removeBlockedUser(getRecieverId(widget.chatheadId));
          DBApi.blockUser(provider.userData!.blockList);
        }
      },
      child: Container(
        color: primaryColor,
        height: 50,
        child: Center(
          child: Text('You have blocked this user. Tap to unblock'.tr(),style: TextStyle(color: Colors.white),),
        ),
      ),
    );
  }

  void sendMessage(groupId)async{

    final provider = Provider.of<ChatProvider>(context, listen: false);
    String message = inputController.text;
    inputController.clear();
    provider.setShowSend(false);
    await DBApi.storeChat(
      context,
        message,
        groupId,
        MediaType.plainText,
        false
    );
    _scroll();
  }
  void selectMediaAndUpload(String mediaType,reply,replyId,replyMessage,replyType,replyDateTime,List<String> extensions)async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
    );
    //chat.setReply(false);
    if (result != null) {
      File file = File(result.files.single.path!);
      final provider = Provider.of<UserDataProvider>(context, listen: false);
      await DBApi.storeChat(
        context,
          "uploading",
          widget.chatheadId,
          mediaType,
          false
      ).then((value){
        //chat.setReply(false);
        print('media primary key $value');
        ImageHandler.uploadFileToFirebase(context,file,value);
      });
      Navigator.pop(context);

    };
  }



  Widget buildListItemView(BuildContext context,ChatModel item){
    bool isMe = item.senderId==FirebaseAuth.instance.currentUser!.uid?true:false;
    final provider = Provider.of<ChatProvider>(context, listen: false);
    bool selected=provider.selectedChat!=null && provider.selectedChat!.id==item.id?true:false;
    return Container(
      color: selected?Colors.grey:Colors.transparent,
      child: Wrap(
        alignment: isMe ? WrapAlignment.end : WrapAlignment.start,
        children: <Widget>[
          isMe ? Container(): Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child:CircleAvatar(
              backgroundImage: NetworkImage(item.senderProfilePic),
              maxRadius: 20,
              minRadius: 20,
            )
          ),

          if(item.mediaType=="Text")
            ChatWidget.showText(isMe, item.message, item.dateTime)
          else if(item.mediaType=="Audio")
            ChatWidget.showAudio(isMe, item.message, item.dateTime)
          else if(item.mediaType==MediaType.location)
            ChatWidget.showLocation(isMe, item.message, item.dateTime)
          else if(item.mediaType=="Image")
              ChatWidget.showImage(context,isMe, item.message)






        ],
      ),
    );
  }





}
