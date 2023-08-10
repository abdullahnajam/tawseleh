
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawseleh/api/notification_api.dart';
import '../model/chat_head_model.dart';
import '../model/chat_model.dart';
import '../model/user_model.dart';
import '../provider/chat_provider.dart';
import '../provider/user_provider.dart';
import '../utils/constants.dart';

class MediaType{
  static String plainText="Text";
  static String image="Image";
  static String audio="Audio";
  static String video="Video";
  static String document="Document";
  static String location="Location";
}

class MessageType{
  static String social="Social";
  static String individual="Individual";
  static String group="Group";
}

String getId(ids,myId){
  String wantedId="";
  String user1 = ids.substring(0, ids.indexOf('_'));
  String user2 = ids.substring(ids.indexOf('_')+1);
  print("id1 : $user1, id2 : $user2");
  if(user1==myId){
    wantedId=user1;
  }
  if(user2==myId){
    wantedId=user2;
  }
  return wantedId;
}

String getRecieverId(ids){
  print('wanted');
  String wantedId="";
  String user1 = ids.substring(0, ids.indexOf('_'));
  print('wanted user 1 $user1');
  String user2 = ids.substring(ids.indexOf('_')+1);
  print("id1 : $user1, id2 : $user2");
  if(user1==FirebaseAuth.instance.currentUser!.uid){
    wantedId=user2;
  }
  if(user2==FirebaseAuth.instance.currentUser!.uid){
    wantedId=user1;
  }
  print('wanted id $wantedId');
  return wantedId;

}

bool checkIfChatExists(ids,myId,otherId){
  bool id1Exists=false;
  bool id2Exists=false;
  String user1 = ids.substring(0, ids.indexOf('_'));
  String user2 = ids.substring(ids.indexOf('_')+1);
  if(user1==myId || user1==otherId){
    id1Exists=true;
  }
  if(user2==myId || user2==otherId){
    id2Exists=true;
  }

  print("id1 : $user1, id2 : $user2");
  print("e1 : $id1Exists, e2 : $id2Exists");
  return id1Exists && id2Exists?true:false;
}

class DBApi{

  static Future<List<UserModel>> getAllUsers(String query)async{
    List<UserModel> users=[];
    await FirebaseFirestore.instance.collection('users').get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        UserModel model=UserModel.fromMap(data, doc.reference.id);
        if(model.userId!= FirebaseAuth.instance.currentUser!.uid && '${model.firstName} ${model.lastName}'.toString().toLowerCase().contains(query.toString().toLowerCase())){
          users.add(model);
        }
      });
    });

    return users;
  }

  static Future<List<UserModel>> getSearchedUsers(BuildContext context,String query)async{
    List<UserModel> users=[];
    List<UserModel> searchedUsers=[];
    List<ChatHeadModel> chats=[];
    chats=await getIndividualChats(context);
    for(int i=0;i<chats.length;i++){
      await getUserData(chats[i].user1==FirebaseAuth.instance.currentUser!.uid?chats[i].user2:chats[i].user1).then((value){
        users.add(value);
      });
    }
    for(int i=0;i<users.length;i++){
      if(users[i].userId!= FirebaseAuth.instance.currentUser!.uid && '${users[i].firstName} ${users[i].lastName}'.toString().toLowerCase().contains(query.toString().toLowerCase())){
        searchedUsers.add(users[i]);
      }
    }

    return searchedUsers;
  }

  static Future<List<ChatHeadModel>> getIndividualChats(BuildContext context)async{
    final provider = Provider.of<ChatProvider>(context, listen: false);
    provider.chatReset();
    List<ChatHeadModel> chats=[];
    List<SortChatHeadClass> sortList=[];
    await FirebaseFirestore.instance.collection('chat_head').get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

        if(getId(doc.reference.id,FirebaseAuth.instance.currentUser!.uid)!=""){
          chats.add(ChatHeadModel.fromMap(data, doc.reference.id));
          sortList.add(SortChatHeadClass(ChatHeadModel.fromMap(data, doc.reference.id).serverTime.toDate(), doc.reference.id));
        }
      });
    });
    print("chat length ${chats.length}");


    sortList.sort((a,b) {
      return a.date.compareTo(b.date);
    });

    List<ChatHeadModel> heads=[];
    for(int i=0;i<sortList.length;i++){
      chats.forEach((element) {
        if(sortList[i].chatHeadId==element.id){
          heads.add(element);
        }
      });
    }
    return heads.reversed.toList();
  }

  static Future<List<ChatModel>> getUnreadMessageCount(BuildContext context,chatHeadId)async{
    List<ChatModel> chats=[];
    await FirebaseFirestore.instance.collection('social_chat').where("groupId",isEqualTo: chatHeadId)
        .get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        ChatModel model=ChatModel.fromMap(data, doc.reference.id);
        if(!model.isRead && model.senderId!=FirebaseAuth.instance.currentUser!.uid){
          chats.add(model);
        }
      });
    });
    print("chat length ${chats.length}");
    return chats;
  }

  static Future<ChatModel?> getLastMessage(chatHeadId)async{
    List<ChatModel> chats=[];
    await FirebaseFirestore.instance.collection('social_chat').where("groupId",isEqualTo: chatHeadId).orderBy('count')
        .get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

        ChatModel model=ChatModel.fromMap(data, doc.reference.id);
        if(!model.visible){
          chats.add(model);
        }

      });
    });

    return chats.isEmpty?null:chats.last;
  }

  static Future<bool> getUnreadGroupMessage(BuildContext context,chatHeadId)async{
    bool hasUnreadMessages=false;
    await FirebaseFirestore.instance.collection('group_alert').doc('$chatHeadId-${FirebaseAuth.instance.currentUser!.uid}').get().then((DocumentSnapshot documentSnapshot) async{
      if (documentSnapshot.exists) {
        hasUnreadMessages=true;

      }

    });
    print("hasUnreadMessages $hasUnreadMessages");
    return hasUnreadMessages;
  }


  static Future changeMessageToRead(chatHeadId)async{
    await FirebaseFirestore.instance.collection('social_chat').where("groupId",isEqualTo: chatHeadId)
        .get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        ChatModel model=ChatModel.fromMap(data, doc.reference.id);
        if(!model.isRead){
          FirebaseFirestore.instance.collection('social_chat').doc(model.id).update({
            'isRead':true
          }).then((value){
            print('message ${model.id} is marked as read');
          });
        }
      });
    });
  }

  static Future changeGroupMessageToRead(BuildContext context,chatHeadId)async{
    await FirebaseFirestore.instance.collection('group_alert').doc('$chatHeadId-${FirebaseAuth.instance.currentUser!.uid}').delete();
  }
  static Future<int> getChatLastMessageCounter(String chatId)async{
    int counter=0;
    await FirebaseFirestore.instance.collection('chat_head').doc(chatId).get().then((DocumentSnapshot documentSnapshot) async{
      if (documentSnapshot.exists) {
        print('exists');
        Map<String, dynamic> data = documentSnapshot.data()! as Map<String, dynamic>;
        ChatHeadModel model=ChatHeadModel.fromMap(data,documentSnapshot.reference.id);
        counter=model.lastCounter;
        counter+=1;
        print('counter ${data}');

      }
    });
    return counter;
  }
  static Future<bool> checkIfBlocked(String id)async{
    bool blocked=false;
    print('block my id $id');
    await FirebaseFirestore.instance.collection('users').doc(id).get().then((DocumentSnapshot documentSnapshot) async{
      if (documentSnapshot.exists) {
        print('exists');
        Map<String, dynamic> data = documentSnapshot.data()! as Map<String, dynamic>;
        UserModel user=UserModel.fromMap(data,documentSnapshot.reference.id);
        print('user block list ${user.blockList}');
        if(user.blockList.contains(FirebaseAuth.instance.currentUser!.uid)){

          blocked=true;
        }
      }
    });
    return blocked;
  }

  static Future<String> storeChat(BuildContext context,String message,String groupId,mediaType,isRead)async{
    FieldValue time=FieldValue.serverTimestamp();
    bool visible=await checkIfBlocked(getRecieverId(groupId));
    int counter=await getChatLastMessageCounter(groupId);

    print('counter get $counter');
    print('groupId $groupId');
    final provider = Provider.of<UserDataProvider>(context, listen: false);
    var res=await FirebaseFirestore.instance.collection('social_chat').add({
      "senderId":FirebaseAuth.instance.currentUser!.uid,
      "senderProfilePic":provider.userData!.profilePic,
      "receiverId":'receiverId',
      "mediaType":mediaType,
      "isRead":isRead,
      "visible":visible,
      "message":message,
      "groupId":groupId,
      "count":counter,
      "dateTime":DateTime.now().toUtc().millisecondsSinceEpoch,
      "serverTime":time,
    });
    await FirebaseFirestore.instance.collection('chat_head').doc(groupId).update({
      'lastCounter':counter,
      "serverTime":time,
    });
    FirebaseFirestore.instance.collection('users').doc(getRecieverId(groupId)).get().then((DocumentSnapshot documentSnapshot) async{
      if (documentSnapshot.exists) {
        print('r id ${getRecieverId(groupId)}');
        Map<String, dynamic> data = documentSnapshot.data()! as Map<String, dynamic>;
        UserModel user=UserModel.fromMap(data,documentSnapshot.reference.id);
        print('user data ${data}');
        String body=message;
        if(mediaType==MediaType.audio){
          body='Audio Message';
        }
        else if(mediaType==MediaType.image){
          body='Image';
        }
        else if(mediaType==MediaType.location){
          body='Location';
        }
        if(!visible) {
          NotificationApi.sendNotification(user.token,'${provider.userData!.firstName} ${provider.userData!.lastName}', body, FirebaseAuth.instance.currentUser!.uid,groupId);
        }
        //NotificationApi.sendNotification(user.token,'${user.firstName} ${ user.lastName}', body, FirebaseAuth.instance.currentUser!.uid,groupId);

      }


    });


    print('res $res');
    return res.id;
  }

  static Future blockUser(List value)async{
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
      'blockList':value,
    });
  }
  static Future<String> forwardMessage(ChatModel chat,receiverId,messageType)async{
    var res=await FirebaseFirestore.instance.collection('social_chat').add({
      "senderId":FirebaseAuth.instance.currentUser!.uid,
      "receiverId":receiverId,
      "messageType":messageType,
      "forwarded":true,
      "mediaType":chat.mediaType,
      "isRead":false,
      "message":chat.message,
      "groupId":receiverId,
      "isReply":false,
      "replyId":"",
      "dateTime":DateTime.now().millisecondsSinceEpoch,
    });
    return res.id;
  }

  static Future<UserModel> getUserData(String id)async{
    UserModel? request;
    print('chatheadId $id');
    await FirebaseFirestore.instance.collection('users')
        .doc(id)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data()! as Map<String, dynamic>;
        request= UserModel.fromMap(data, documentSnapshot.reference.id);
      }
      else{
        print("no user found $id");
      }
    });
    return request!;
  }

  static Future<ChatModel> getSocialChat(String id)async{
    ChatModel? model;
    await FirebaseFirestore.instance.collection('social_chat')
        .doc(id)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data()! as Map<String, dynamic>;
        model= ChatModel.fromMap(data, documentSnapshot.reference.id);
      }
      else{
        print("no user found $id");
      }
    });
    return model!;
  }


}
class SortChatHeadClass{
  DateTime date;
  String chatHeadId;

  SortChatHeadClass(this.date,this.chatHeadId);
}

