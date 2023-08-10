
import 'package:cloud_firestore/cloud_firestore.dart';
class ChatModel{
  String id,senderId,mediaType,message,receiverId,senderProfilePic,groupId;
  bool isRead,visible;
  int dateTime,count;
  //Timestamp timestamp;



  ChatModel.fromMap(Map<String,dynamic> map,String key)
      : id=key,
        senderId = map['senderId']??"",
        senderProfilePic = map['senderProfilePic']??"",
        mediaType = map['mediaType']??"",
        receiverId = map['receiverId']??"all",
        isRead = map['isRead']??false,
        visible = map['visible']??true,
        message = map['message']??"",
        groupId = map['groupId']??"",
        count = map['count']??0,
        //timestamp = map['serverTime'],
        dateTime = map['dateTime']??0;




  ChatModel.fromSnapshot(DocumentSnapshot snapshot )
      : this.fromMap(snapshot.data() as Map<String, dynamic>,snapshot.reference.id);
}