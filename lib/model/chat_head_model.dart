import 'package:cloud_firestore/cloud_firestore.dart';
class ChatHeadModel{
  String id,user1,user2;
  int lastCounter;
  int timestamp;
  Timestamp serverTime;



  ChatHeadModel.fromMap(Map<String,dynamic> map,String key)
      : id=key,
        user1 = map['user1']??"",
        lastCounter = map['lastCounter']??-1,
        user2 = map['user2']??"",
        serverTime = map['serverTime'],

        timestamp = map['timestamp']??DateTime.now().millisecondsSinceEpoch;




  ChatHeadModel.fromSnapshot(DocumentSnapshot snapshot )
      : this.fromMap(snapshot.data() as Map<String, dynamic>,snapshot.reference.id);
}